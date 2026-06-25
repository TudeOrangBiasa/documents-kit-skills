#!/usr/bin/env bash
# pdf-from-docx.sh — Convert .docx to PDF with proper styling.
# Usage: ./pdf-from-docx.sh <input.docx> [output.pdf]
#
# Uses pandoc with LaTeX engine (or LibreOffice as fallback).
# Requires: pandoc, xelatex OR libreoffice
#
# Exit 0 on success, 1 on failure.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <input.docx> [output.pdf]"
  exit 2
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.docx}.pdf}"

[[ ! -f "$INPUT" ]] && { echo "Error: $INPUT not found"; exit 2; }

echo "=== Convert $INPUT → $OUTPUT ==="

# Try pandoc with xelatex (best for styled docs)
if command -v pandoc &>/dev/null && command -v xelatex &>/dev/null; then
  echo "Using pandoc + xelatex..."
  pandoc "$INPUT" \
    -o "$OUTPUT" \
    --pdf-engine=xelatex \
    -V geometry:margin=1in \
    -V mainfont="DejaVu Serif" \
    -V monofont="DejaVu Sans Mono" \
    --toc
  echo "Done: $OUTPUT"
  exit 0
fi

# Fallback: LibreOffice headless
if command -v libreoffice &>/dev/null; then
  echo "Using LibreOffice (pandoc+xelatex not available)..."
  libreoffice --headless --convert-to pdf --outdir "$(dirname "$OUTPUT")" "$INPUT"
  echo "Done: $OUTPUT"
  exit 0
fi

# No converter available
echo "Error: Neither pandoc+xelatex nor libreoffice is installed."
echo "Install one of:"
echo "  sudo apt install pandoc texlive-xetex  # Linux"
echo "  brew install pandoc                     # macOS"
exit 1
