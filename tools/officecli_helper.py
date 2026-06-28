#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# ///

"""Glue tool: officecli operations (validate, screenshot, pandoc-fix).

Usage:
  uv run tools/officecli_helper.py validate <file>
  uv run tools/officecli_helper.py screenshot <file> <output.png>
  uv run tools/officecli_helper.py fix <file> [--fix <name> ...]
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

# ── helpers ──────────────────────────────────────────────────────

OFFICECLI_MSG = (
    "officecli not found — install via curl -fsSL https://d.officecli.ai/install.sh | bash"
)

FIX_MAP: dict[str, str] = {
    "curly-quotes": "--curly-quotes",
    "code-spacing": "--code-spacing",
    "first-line-indent": "--first-line-indent",
}

SCRIPT_DIR = Path(__file__).resolve().parent.parent
FIX_SCRIPT = SCRIPT_DIR / "skills" / "document-writing" / "scripts" / "fix-pandoc-leaks.sh"


def _check_input(path: Path) -> None:
    """Raise FileNotFoundError if path does not exist."""
    if not path.exists():
        raise FileNotFoundError(f"input file not found: {path}")


def _run_officecli(args: list[str], **kwargs: object) -> subprocess.CompletedProcess:
    """Run officecli with args. Raises FileNotFoundError if binary missing, RuntimeError on timeout."""
    try:
        return subprocess.run(
            ["officecli", *args],
            check=False,
            capture_output=True,
            timeout=30,
            text=True,
            **kwargs,
        )
    except FileNotFoundError:
        raise FileNotFoundError(OFFICECLI_MSG)
    except subprocess.TimeoutExpired:
        raise RuntimeError("officecli timeout after 30s")


def _check_result(result: subprocess.CompletedProcess[str], label: str) -> None:
    """Raise RuntimeError if subprocess returned non-zero."""
    if result.returncode != 0:
        msg = result.stderr.strip() or result.stdout.strip() or "unknown error"
        raise RuntimeError(f"{label} failed (exit code {result.returncode}): {msg}")


# ── Public API ───────────────────────────────────────────────────


def validate_docx(path: Path) -> bool:
    """Validate docx via officecli. Returns True if valid, False otherwise."""
    _check_input(path)
    result = _run_officecli(["validate", str(path)])
    return result.returncode == 0


def screenshot_docx(path: Path, output: Path) -> None:
    """Render docx screenshot via officecli."""
    _check_input(path)
    result = _run_officecli(["view", str(path), "screenshot", "-o", str(output)])
    _check_result(result, "screenshot")


def apply_pandoc_fixes(path: Path, *, fixes: list[str] | None = None) -> None:
    """Apply pandoc leak fixes via fix-pandoc-leaks.sh.

    Default fixes: curly-quotes, code-spacing, first-line-indent.
    Pass explicit list to select specific fixes.
    """
    _check_input(path)
    cmd = [str(FIX_SCRIPT), str(path)]
    if fixes is None:
        cmd.extend(["--curly-quotes", "--code-spacing", "--first-line-indent"])
    else:
        for fix in fixes:
            flag = FIX_MAP.get(fix)
            if flag:
                cmd.append(flag)
    try:
        result = subprocess.run(
            cmd,
            check=False,
            capture_output=True,
            timeout=30,
            text=True,
        )
    except subprocess.TimeoutExpired:
        raise RuntimeError("fix-pandoc-leaks timeout after 30s")
    _check_result(result, "fix")


# ── CLI ──────────────────────────────────────────────────────────


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Office document helper — validate, screenshot, and fix .docx files",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    vp = sub.add_parser("validate", help="Validate .docx file")
    vp.add_argument("file", type=Path, help="Path to .docx file")

    sp = sub.add_parser("screenshot", help="Render .docx to screenshot image")
    sp.add_argument("file", type=Path, help="Path to .docx file")
    sp.add_argument("output", type=Path, help="Output image path (.png)")

    fp = sub.add_parser("fix", help="Apply pandoc leak fixes to .docx")
    fp.add_argument("file", type=Path, help="Path to .docx file")
    fp.add_argument(
        "--fix",
        action="append",
        dest="fixes",
        choices=list(FIX_MAP),
        help="Specific fix to apply (may repeat). Default: all.",
    )

    return parser


def main(argv: list[str] | None = None) -> None:
    """CLI entry point. Accepts optional argv for testing."""
    parser = _build_parser()
    args = parser.parse_args(argv)

    if args.command == "validate":
        ok = validate_docx(args.file)
        print(f"{'Valid' if ok else 'Invalid'}: {args.file}")
        sys.exit(0 if ok else 1)

    elif args.command == "screenshot":
        screenshot_docx(args.file, args.output)
        print(f"Screenshot saved to {args.output}")

    elif args.command == "fix":
        apply_pandoc_fixes(args.file, fixes=args.fixes)
        print(f"Fix applied to {args.file}")


if __name__ == "__main__":
    main()
