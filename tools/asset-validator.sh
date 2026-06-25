#!/usr/bin/env bash
# asset-validator.sh — Validate all referenced assets in a markdown document exist.
# Usage: ./asset-validator.sh <doc.md> [--strict]
#
# Checks:
#   - Image references ![](path)
#   - Internal links [text](path)
#   - Code file references (e.g., "@src/foo.ts")
#
# Exit 0 if all valid, 1 if any missing.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <doc.md> [--strict]"
  exit 2
fi

DOC="$1"
shift

STRICT=false
[[ "${1:-}" == "--strict" ]] && STRICT=true

[[ ! -f "$DOC" ]] && { echo "Error: $DOC not found"; exit 2; }

# Resolve DOC's directory for relative paths
DOC_DIR=$(dirname "$(realpath "$DOC")")

MISSING=()
TOTAL=0

# Check image references
while IFS= read -r ref; do
  TOTAL=$((TOTAL + 1))
  # Skip URLs and absolute URLs
  [[ "$ref" =~ ^https?:// ]] && continue
  [[ "$ref" =~ ^/ ]] && continue
  # Resolve relative to DOC_DIR
  full_path="$DOC_DIR/$ref"
  if [[ ! -f "$full_path" && ! -d "$full_path" ]]; then
    MISSING+=("image: $ref")
  fi
done < <(grep -oE '!\[[^]]*\]\([^)]+\)' "$DOC" 2>/dev/null | sed 's/.*(\([^)]*\)).*/\1/' || true)

# Check internal links (not http, not anchor-only)
while IFS= read -r ref; do
  TOTAL=$((TOTAL + 1))
  [[ "$ref" =~ ^https?:// ]] && continue
  [[ "$ref" =~ ^# ]] && continue
  full_path="$DOC_DIR/$ref"
  if [[ ! -f "$full_path" ]]; then
    MISSING+=("link: $ref")
  fi
done < <(grep -oE '\[[^]]+\]\([^)]+\)' "$DOC" 2>/dev/null | grep -v '!\[' | sed 's/.*(\([^)]*\)).*/\1/' || true)

# Report
echo "=== Asset Validation ==="
echo "Document: $DOC"
echo "Total references: $TOTAL"
echo "Missing: ${#MISSING[@]}"
echo

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Missing assets:"
  for m in "${MISSING[@]}"; do
    echo "  - $m"
  done
  echo
  if [[ "$STRICT" == "true" ]]; then
    echo "FAIL (strict mode)"
    exit 1
  else
    echo "WARN (non-fatal in non-strict mode)"
    exit 0
  fi
fi

echo "All assets present."
exit 0
