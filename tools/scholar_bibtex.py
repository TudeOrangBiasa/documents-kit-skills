#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = ["mcp[cli]>=1.0"]
# ///
"""Glue tool: spawn scholar-paper-mcp via stdio, call BibTeX/paper operations.

Usage:
  uv run tools/scholar_bibtex.py export <session_id> <output.bib>
  uv run tools/scholar_bibtex.py add <session_id> <paper_id>
  uv run tools/scholar_bibtex.py list <session_id>
"""

from __future__ import annotations

import argparse
import asyncio
import json
import sys
from pathlib import Path
from typing import Any

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
from mcp.types import TextContent

PEER_DIR = Path.home() / ".local/share/documents-kit-skills/peer/scholar-paper-mcp"

MCP_TIMEOUT_SECONDS = 30


# ── MCP helpers ────────────────────────────────────────────────────


def _parse_response(result: Any) -> Any:
    """Extract data field from ToolResponse JSON envelope {data, meta}.
    Raises RuntimeError on MCP error result (isError=True)."""
    if getattr(result, "isError", False):
        error_text = result.content[0].text if result.content else "unknown error"
        raise RuntimeError(f"MCP tool error: {error_text}")

    if not result.content:
        raise RuntimeError("MCP tool returned empty content")
    tc = result.content[0]
    if not isinstance(tc, TextContent):
        raise RuntimeError(f"unexpected content type: {type(tc).__name__}")
    try:
        body = json.loads(tc.text)
    except json.JSONDecodeError as e:
        raise RuntimeError(f"MCP tool returned malformed JSON: {e}\nRaw: {tc.text[:200]}")
    if "data" not in body:
        raise RuntimeError(f"MCP tool response missing 'data' key: {tc.text[:200]}")
    return body["data"]


def _peer_check() -> None:
    """Raise ConnectionError if PEER_DIR does not exist."""
    if not PEER_DIR.exists():
        raise ConnectionError(
            f"scholar-paper-mcp not installed at {PEER_DIR}. "
            f"Run './install.sh --all' first."
        )


async def _call_with_timeout(
    session: Any, tool_name: str, arguments: dict
) -> Any:
    """Call MCP tool with 30s timeout. Raises ConnectionError on timeout."""
    try:
        return await asyncio.wait_for(
            session.call_tool(tool_name, arguments=arguments),
            timeout=MCP_TIMEOUT_SECONDS,
        )
    except asyncio.TimeoutError:
        raise ConnectionError(
            f"MCP server timeout after {MCP_TIMEOUT_SECONDS}s on {tool_name}"
        )


# ── Public API ─────────────────────────────────────────────────────


async def export_bibtex(session_id: str, output_path: Path) -> int:
    """Spawn scholar-paper-mcp, call export_session_bibtex, write .bib file.

    Returns number of BibTeX entries written. Returns 0 on empty session.
    Raises ConnectionError on spawn failure or timeout.
    """
    _peer_check()
    server_params = StdioServerParameters(
        command="uv",
        args=["--directory", str(PEER_DIR), "run", "scholar-paper-mcp"],
    )
    try:
        async with stdio_client(server_params) as (read, write):
            async with ClientSession(read, write) as session:
                await session.initialize()
                result = await _call_with_timeout(
                    session,
                    "export_session_bibtex",
                    arguments={"session_id": session_id},
                )
    except ConnectionError:
        raise
    except Exception as e:
        raise ConnectionError(f"failed to connect to scholar-paper-mcp: {e}") from e

    papers = _parse_response(result)
    if not isinstance(papers, list):
        raise ValueError(f"expected list of papers, got {type(papers).__name__}")

    entries = []
    for p in papers:
        bibtex = p.get("bibtex", "")
        if bibtex:
            entries.append(bibtex.strip())

    output_path.write_text("\n\n".join(entries) + ("\n" if entries else ""))
    return len(entries)


async def add_paper(session_id: str, paper_id: str) -> None:
    """Call add_paper_to_session. Raises ConnectionError on spawn/timeout, RuntimeError on MCP error."""
    _peer_check()
    server_params = StdioServerParameters(
        command="uv",
        args=["--directory", str(PEER_DIR), "run", "scholar-paper-mcp"],
    )
    try:
        async with stdio_client(server_params) as (read, write):
            async with ClientSession(read, write) as session:
                await session.initialize()
                result = await _call_with_timeout(
                    session,
                    "add_paper_to_session",
                    arguments={"session_id": session_id, "paper_id": paper_id},
                )
    except ConnectionError:
        raise
    except Exception as e:
        raise ConnectionError(f"add_paper failed: {e}") from e
    # Surface MCP tool errors (isError=True)
    _parse_response(result)


async def list_papers(session_id: str) -> list[dict]:
    """Call list_session_papers_tool. Returns list of paper dicts.
    Raises ConnectionError on spawn failure or timeout."""
    _peer_check()
    server_params = StdioServerParameters(
        command="uv",
        args=["--directory", str(PEER_DIR), "run", "scholar-paper-mcp"],
    )
    try:
        async with stdio_client(server_params) as (read, write):
            async with ClientSession(read, write) as session:
                await session.initialize()
                result = await _call_with_timeout(
                    session,
                    "list_session_papers_tool",
                    arguments={"session_id": session_id},
                )
    except ConnectionError:
        raise
    except Exception as e:
        raise ConnectionError(f"list_papers failed: {e}") from e
    papers = _parse_response(result)
    if not isinstance(papers, list):
        raise RuntimeError(f"expected list, got {type(papers).__name__}")
    return papers


# ── CLI ──────────────────────────────────────────────────────────────


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Scholar BibTeX tool — export, add, and list papers via scholar-paper-mcp",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    # export
    export_p = sub.add_parser("export", help="Export session papers to .bib file")
    export_p.add_argument("session_id", help="Session identifier")
    export_p.add_argument("output", type=Path, help="Output .bib file path")

    # add
    add_p = sub.add_parser("add", help="Add paper to session")
    add_p.add_argument("session_id", help="Session identifier")
    add_p.add_argument("paper_id", help="Paper ID (DOI, arXiv ID, or Semantic Scholar ID)")

    # list
    list_p = sub.add_parser("list", help="List papers in session")
    list_p.add_argument("session_id", help="Session identifier")

    # Internal: used by install.sh --verify (hidden from --help)
    sub.add_parser("__list_tools__", help=argparse.SUPPRESS)

    return parser


async def _list_tools_only() -> int:
    """Internal: print all available MCP tools, one per line."""
    _peer_check()
    server_params = StdioServerParameters(
        command="uv",
        args=["--directory", str(PEER_DIR), "run", "scholar-paper-mcp"],
    )
    try:
        async with stdio_client(server_params) as (read, write):
            async with ClientSession(read, write) as session:
                await session.initialize()
                result = await session.list_tools()
                for tool in result.tools:
                    print(f"[tool] {tool.name}")
                return 0
    except Exception as e:
        print(f"Error listing tools: {e}", file=sys.stderr)
        return 1


async def _main() -> None:
    parser = _build_parser()
    args = parser.parse_args()

    if args.command == "export":
        count = await export_bibtex(args.session_id, args.output)
        print(f"Wrote {count} entries to {args.output}")
    elif args.command == "add":
        await add_paper(args.session_id, args.paper_id)
        print(f"Added {args.paper_id} to session {args.session_id}")
    elif args.command == "list":
        papers = await list_papers(args.session_id)
        print(json.dumps(papers, indent=2, default=str))
    elif args.command == "__list_tools__":
        sys.exit(await _list_tools_only())


def main() -> None:
    asyncio.run(_main())


if __name__ == "__main__":
    main()
