#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# ///
"""Glue tool: pandoc --citeproc + fix-pandoc-leaks + officecli validation.

Usage:
  uv run tools/pandoc_citeproc.py build <md> <bib> -o <docx> [--reference <reference.docx>]
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent.parent
FIX_SCRIPT = SCRIPT_DIR / "skills" / "document-writing" / "scripts" / "fix-pandoc-leaks.sh"
PANDOC_MSG = "pandoc not found — install via apt install pandoc or brew install pandoc"
FIX_SCRIPT_MSG = "fix-pandoc-leaks.sh not found — is the document-writing skill installed?"


# ── helpers ──────────────────────────────────────────────────────


def _check_input(path: Path, label: str = "input") -> None:
    """Raise FileNotFoundError if path does not exist."""
    if not path.exists():
        raise FileNotFoundError(f"{label} file not found: {path}")


def _run_pandoc(
    md_path: Path, bib_path: Path, output: Path, *, reference_doc: Path | None = None
) -> None:
    """Run pandoc with --citeproc and --bibliography. Raises FileNotFoundError or RuntimeError."""
    cmd = [
        "pandoc",
        str(md_path),
        "-o",
        str(output),
        "--citeproc",
        f"--bibliography={bib_path}",
    ]
    if reference_doc is not None:
        cmd.append(f"--reference-doc={reference_doc}")
    try:
        result = subprocess.run(
            cmd, check=False, capture_output=True, timeout=30, text=True
        )
    except FileNotFoundError:
        raise FileNotFoundError(PANDOC_MSG)
    except subprocess.TimeoutExpired:
        raise RuntimeError("pandoc timeout after 30s")
    if result.returncode != 0:
        msg = result.stderr.strip() or result.stdout.strip() or "unknown error"
        raise RuntimeError(f"pandoc failed (exit code {result.returncode}): {msg}")


def _run_fixes(output: Path) -> None:
    """Run fix-pandoc-leaks.sh --all. Raises RuntimeError."""
    cmd = [str(FIX_SCRIPT), str(output), "--all"]
    try:
        result = subprocess.run(
            cmd, check=False, capture_output=True, timeout=30, text=True
        )
    except FileNotFoundError:
        raise FileNotFoundError(FIX_SCRIPT_MSG)
    except subprocess.TimeoutExpired:
        raise RuntimeError("fix-pandoc-leaks timeout after 30s")
    if result.returncode != 0:
        msg = result.stderr.strip() or result.stdout.strip() or "unknown error"
        raise RuntimeError(f"fix-pandoc-leaks failed (exit code {result.returncode}): {msg}")


def _validate_output(output: Path) -> None:
    """Validate docx via officecli_helper. Warnings to stderr only."""
    from tools.officecli_helper import validate_docx

    try:
        if not validate_docx(output):
            print(f"Warning: officecli validation reported issues for {output}", file=sys.stderr)
    except Exception as e:
        print(f"Warning: officecli validation failed: {e}", file=sys.stderr)


# ── Public API ───────────────────────────────────────────────────


def build_docx(
    md_path: Path,
    bib_path: Path,
    output: Path,
    *,
    reference_doc: Path | None = None,
) -> None:
    """Build docx from markdown with citation processing.

    Steps: validate inputs → pandoc --citeproc → fix-pandoc-leaks → validate.
    """
    _check_input(md_path, "markdown")
    _check_input(bib_path, "bibliography")
    _run_pandoc(md_path, bib_path, output, reference_doc=reference_doc)
    _run_fixes(output)
    _validate_output(output)


# ── CLI ──────────────────────────────────────────────────────────


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Build docx from markdown with pandoc --citeproc, fix leaks, and validate",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    bp = sub.add_parser("build", help="Build docx from markdown with citation processing")
    bp.add_argument("md", type=Path, help="Input markdown file")
    bp.add_argument("bib", type=Path, help="BibTeX bibliography file")
    bp.add_argument("-o", "--output", type=Path, required=True, help="Output .docx file")
    bp.add_argument("--reference", type=Path, default=None, help="Reference docx template")

    return parser


def main(argv: list[str] | None = None) -> None:
    """CLI entry point. Accepts optional argv for testing."""
    parser = _build_parser()
    args = parser.parse_args(argv)

    if args.command == "build":
        build_docx(args.md, args.bib, args.output, reference_doc=args.reference)
        print(f"docx built: {args.output}")


if __name__ == "__main__":
    main()
