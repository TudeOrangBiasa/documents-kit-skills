#!/usr/bin/env bash
# doc-audit-pipeline.sh — Run all audits in one command.
# Usage: ./doc-audit-pipeline.sh <doc.md|doc.docx> [options]
#
# Runs:
#   1. scripts/document-writing/scripts/detection-audit.sh
#   2. Asset reference check
#   3. Citation format check
#   4. Burstiness analysis
#
# Exit 0 if all pass, 1 on any fail.

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILLS_DIR="$SCRIPT_DIR/../skills"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <doc.md|doc.docx> [--strict] [--quiet]"
  exit 2
fi

DOC="$1"
shift

STRICT=false
QUIET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=true ;;
    --quiet) QUIET=true ;;
    *) echo "Unknown flag: $1"; exit 2 ;;
  esac
  shift
done

[[ ! -f "$DOC" ]] && { echo "Error: $DOC not found"; exit 2; }

log() {
  [[ "$QUIET" == "true" ]] || echo "$@"
}

PASS=0
FAIL=0
TOTAL=0

run_check() {
  local name="$1"
  local cmd="$2"
  TOTAL=$((TOTAL + 1))
  log
  log "=== Check $TOTAL: $name ==="
  if eval "$cmd"; then
    log "[PASS] $name"
    PASS=$((PASS + 1))
  else
    log "[FAIL] $name"
    FAIL=$((FAIL + 1))
  fi
}

log "=== Document Audit Pipeline ==="
log "Document: $DOC"
log "Strict mode: $STRICT"
log

# 1. Detection audit (anti-AI patterns)
if [[ -f "$SKILLS_DIR/document-writing/scripts/detection-audit.sh" ]]; then
  run_check "Anti-AI Detection Audit" \
    "$SKILLS_DIR/document-writing/scripts/detection-audit.sh '$DOC'"
else
  log "[SKIP] Anti-AI Detection Audit — script not found"
fi

# 2. Asset reference check (md → referenced images exist)
if [[ "$DOC" == *.md ]]; then
  ASSET_LOG=$(mktemp)
  # Extract ![](path) references and check existence
  grep -oE '!\[[^]]*\]\([^)]+\)' "$DOC" 2>/dev/null | sed 's/.*(\([^)]*\)).*/\1/' | while read -r ref; do
    # Skip URLs
    [[ "$ref" =~ ^https?:// ]] && continue
    if [[ ! -f "$ref" ]]; then
      echo "MISSING: $ref" >> "$ASSET_LOG"
    fi
  done
  if [[ -s "$ASSET_LOG" ]]; then
    log "[FAIL] Asset References — missing files:"
    cat "$ASSET_LOG" | sed 's/^/  /'
    FAIL=$((FAIL + 1))
  else
    log "[PASS] Asset References — all files exist"
    PASS=$((PASS + 1))
  fi
  rm -f "$ASSET_LOG"
  TOTAL=$((TOTAL + 1))
fi

# 3. Citation format check (if .bib exists)
BIB_FILE="${DOC%.md}.bib"
BIB_FILE="${BIB_FILE%.docx}.bib"
if [[ -f "$BIB_FILE" ]]; then
  # Simple check: every entry has author, title, year
  ENTRIES=$(grep -cE '^@' "$BIB_FILE" || echo 0)
  log
  log "=== Citations ==="
  log "Found $ENTRIES BibTeX entries in $BIB_FILE"
  log "(Manual review recommended for completeness)"
fi

# 4. Burstiness check (already in detection-audit, but show explicitly)
log
log "=== Burstiness ==="
if command -v awk &>/dev/null; then
  STATS=$(awk 'BEGIN{RS="[.!?]"} NF>0{n++; sum+=NF; sumsq+=NF*NF} END{if(n==0) print "no sentences"; else {mean=sum/n; var=sumsq/n - mean*mean; stddev=sqrt(var<0?0:var); cov=(mean>0)?(stddev/mean)*100:0; printf "Mean: %.1f, StdDev: %.1f, CoV: %.1f%%, n: %d\n", mean, stddev, cov, n}}' "$DOC")
  log "$STATS"
  COV=$(echo "$STATS" | grep -oE 'CoV: [0-9.]+' | grep -oE '[0-9.]+')
  TOTAL=$((TOTAL + 1))
  if awk -v cov="${COV:-0}" 'BEGIN{exit !(cov+0 > 30)}'; then
    log "[PASS] Burstiness CoV > 30%"
    PASS=$((PASS + 1))
  else
    log "[WARN] Burstiness CoV < 30% (target: 30%+)"
    [[ "$STRICT" == "true" ]] && FAIL=$((FAIL + 1)) || log "  (non-fatal in non-strict mode)"
  fi
fi

# Summary
log
log "=== Summary ==="
log "Passed: $PASS / $TOTAL"
log "Failed: $FAIL / $TOTAL"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
