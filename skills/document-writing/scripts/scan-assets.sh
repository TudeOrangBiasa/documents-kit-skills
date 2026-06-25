#!/usr/bin/env bash
# scan-assets.sh — Scan for existing visual/data/code assets in a project.
# Usage: ./scan-assets.sh [project_root]
# Emits JSON manifest to stdout. Use to populate Phase 0 asset inventory.
# Exit 0 always (informational tool).

set -euo pipefail

ROOT="${1:-.}"

# Initialize counters
img_count=0
bib_count=0
code_count=0
ref_count=0

# Build arrays
images=()
bibs=()
code=()
refs=()

# Scan image locations
for dir in docs/diagrams docs/figures docs/images assets/images assets/figures images; do
  if [[ -d "$ROOT/$dir" ]]; then
    while IFS= read -r f; do
      images+=("{\"path\":\"$f\",\"type\":\"${f##*.}\"}")
      img_count=$((img_count + 1))
    done < <(find "$ROOT/$dir" -maxdepth 2 -type f \( -name "*.png" -o -name "*.svg" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.pdf" \) 2>/dev/null)
  fi
done

# Scan bibliography
while IFS= read -r f; do
  bibs+=("{\"path\":\"$f\"}")
  bib_count=$((bib_count + 1))
done < <(find "$ROOT" -maxdepth 2 -type f \( -name "*.bib" -o -name "references.bib" -o -name "refs.bib" \) 2>/dev/null)

# Scan code snippets
for dir in docs/snippets docs/code docs/examples; do
  if [[ -d "$ROOT/$dir" ]]; then
    while IFS= read -r f; do
      code+=("{\"path\":\"$f\",\"language\":\"${f##*.}\"}")
      code_count=$((code_count + 1))
    done < <(find "$ROOT/$dir" -maxdepth 2 -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.sql" \) 2>/dev/null)
  fi
done

# Scan reference docs
for dir in docs/references docs/specs docs/prds; do
  if [[ -d "$ROOT/$dir" ]]; then
    while IFS= read -r f; do
      refs+=("{\"path\":\"$f\"}")
      ref_count=$((ref_count + 1))
    done < <(find "$ROOT/$dir" -maxdepth 2 -type f -name "*.md" 2>/dev/null)
  fi
done

# Join arrays with commas
join_by() { local d="$1"; shift; local f="$1"; shift; printf "%s" "$f"; printf "%s$d" "${@/#/$d}"; }

img_json="[$(IFS=,; echo "${images[*]}")]"
bib_json="[$(IFS=,; echo "${bibs[*]}")]"
code_json="[$(IFS=,; echo "${code[*]}")]"
ref_json="[$(IFS=,; echo "${refs[*]}")]"

cat <<EOF
{
  "scanned_root": "$ROOT",
  "summary": {
    "images": $img_count,
    "bibliography": $bib_count,
    "code_snippets": $code_count,
    "reference_docs": $ref_count
  },
  "images": $img_json,
  "bibliography": $bib_json,
  "code_snippets": $code_json,
  "reference_docs": $ref_json
}
EOF
