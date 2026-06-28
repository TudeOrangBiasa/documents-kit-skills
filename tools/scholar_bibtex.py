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


# ── MCP helpers ────────────────────────────────────────────────────


def _parse_response(result: Any) -> Any:
    """Extract data field from ToolResponse JSON envelope {data, meta}."""
    if not result.content:
        raise ValueError("empty response: server returned no content")
    tc = result.content[0]
    if not isinstance(tc, TextContent):
        raise ValueError(f"unexpected content type: {type(tc).__name__}")
    try:
        body = json.loads(tc.text)
    except json.JSONDecodeError as e:
        raise ValueError(f"malformed JSON response: {e}") from e
    if "data" not in body:
        raise ValueError(f"response missing data key: {body}")
    return body["data"]


# ── Public API ─────────────────────────────────────────────────────


async def export_bibtex(session_id: str, output_path: Path) -> int:
    """Spawn scholar-paper-mcp, call export_session_bibtex, write .bib file.

    Returns number of BibTeX entries written. Returns 0 on empty session.
    """
    server_params = StdioServerParameters(
        command="uv",
        args=["--directory", str(PEER_DIR), "run", "scholar-paper-mcp"],
    )
    try:
        async with stdio_client(server_params) as (read, write):
            async with ClientSession(read, write) as session:
                await session.initialize()
                result = await session.call_tool(
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
    """Call add_paper_to_session. Raises on error."""
    server_params = StdioServerParameters(
        command="uv",
        args=["--directory", str(PEER_DIR), "run", "scholar-paper-mcp"],
    )
    try:
        async with stdio_client(server_params) as (read, write):
            async with ClientSession(read, write) as session:
                await session.initialize()
                await session.call_tool(
                    "add_paper_to_session",
                    arguments={"session_id": session_id, "paper_id": paper_id},
                )
    except Exception as e:
        raise RuntimeError(f"add_paper failed: {e}") from e


async def list_papers(session_id: str) -> list[dict]:
    """Call list_session_papers_tool. Returns list of paper dicts."""
    server_params = StdioServerParameters(
        command="uv",
        args=["--directory", str(PEER_DIR), "run", "scholar-paper-mcp"],
    )
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            result = await session.call_tool(
                "list_session_papers_tool",
                arguments={"session_id": session_id},
            )
    papers = _parse_response(result)
    if not isinstance(papers, list):
        raise ValueError(f"expected list, got {type(papers).__name__}")
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

    return parser


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


def main() -> None:
    asyncio.run(_main())


if __name__ == "__main__":
    main()
