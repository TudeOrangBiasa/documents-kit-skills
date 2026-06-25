#!/usr/bin/env bash
# detection-audit.sh — Audit a draft for AI-detection patterns.
# Usage: ./detection-audit.sh <draft.md>
# Exits 0 if all checks pass.
# Exits 1 if any check fails.
# Exits 2 if wrong usage.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <draft.md>"
  exit 2
fi

DRAFT="$1"

if [[ ! -f "$DRAFT" ]]; then
  echo "Error: $DRAFT not found"
  exit 2
fi

WORD_COUNT=$(wc -w < "$DRAFT")
EM_DASH_LIMIT=$((WORD_COUNT / 500))
[[ $EM_DASH_LIMIT -lt 1 ]] && EM_DASH_LIMIT=1

FAIL=0

# Helper: count matches without polluting variable
count_matches() {
  local pattern="$1"
  local file="$2"
  local count
  count=$(grep -cE "$pattern" "$file" 2>/dev/null) || count=0
  # Strip whitespace
  count=$(echo "$count" | tr -d '[:space:]')
  echo "${count:-0}"
}

echo "=== Audit: $DRAFT ==="
echo "Word count: $WORD_COUNT"
echo "Em-dash limit: $EM_DASH_LIMIT (1 per 500 words)"
echo

# Check 1: Em dashes
EM_DASH_COUNT=$(count_matches "—" "$DRAFT")
if [[ $EM_DASH_COUNT -gt $EM_DASH_LIMIT ]]; then
  echo "FAIL: Em dashes: $EM_DASH_COUNT (limit: $EM_DASH_LIMIT)"
  FAIL=1
else
  echo "PASS: Em dashes: $EM_DASH_COUNT (limit: $EM_DASH_LIMIT)"
fi

# Check 2: Tier 1 banned vocabulary
TIER1_HITS=$(grep -oiE "delve|tapestry|pivotal|underscore|nuance|comprehensive|leverage|robust|utilize|intricate|meticulous|testament|embark|foster|crucial" "$DRAFT" 2>/dev/null | sort | uniq -c || true)
if [[ -n "$TIER1_HITS" ]]; then
  echo "FAIL: Tier 1 vocabulary found:"
  echo "$TIER1_HITS" | sed 's/^/  /'
  FAIL=1
else
  echo "PASS: No Tier 1 vocabulary"
fi

# Check 3: Banned transitions
TRANSITION_COUNT=$(count_matches "Furthermore|Moreover|Additionally|In conclusion|In summary|It is important to note|It is worth noting" "$DRAFT")
if [[ $TRANSITION_COUNT -gt 0 ]]; then
  echo "FAIL: Banned transitions: $TRANSITION_COUNT"
  grep -inE "Furthermore|Moreover|Additionally|In conclusion|In summary|It is important to note|It is worth noting" "$DRAFT" | sed 's/^/  /'
  FAIL=1
else
  echo "PASS: No banned transitions"
fi

# Check 4: Negative parallelisms
NEGPAR_COUNT=$(count_matches "not just|not only.*but also" "$DRAFT")
if [[ $NEGPAR_COUNT -gt 0 ]]; then
  echo "FAIL: Negative parallelisms: $NEGPAR_COUNT"
  grep -inE "not just|not only.*but also" "$DRAFT" | sed 's/^/  /'
  FAIL=1
else
  echo "PASS: No negative parallelisms"
fi

# Check 5: Formulaic openers
OPENER_COUNT=$(count_matches "in an era|in today's|in the realm" "$DRAFT")
if [[ $OPENER_COUNT -gt 0 ]]; then
  echo "FAIL: Formulaic openers: $OPENER_COUNT"
  grep -inE "in an era|in today's|in the realm" "$DRAFT" | sed 's/^/  /'
  FAIL=1
else
  echo "PASS: No formulaic openers"
fi

# Check 6: Self-reference
SELFREF_COUNT=$(count_matches "this (paper|article|guide|essay|proposal|document) (explores|presents|examines|discusses)" "$DRAFT")
if [[ $SELFREF_COUNT -gt 0 ]]; then
  echo "FAIL: Self-reference: $SELFREF_COUNT"
  grep -inE "this (paper|article|guide|essay|proposal|document) (explores|presents|examines|discusses)" "$DRAFT" | sed 's/^/  /'
  FAIL=1
else
  echo "PASS: No self-reference"
fi

# Check 7: Duplicate sentences
DUPES=$(sed 's/[.!?]/\n/g' "$DRAFT" 2>/dev/null | sort | uniq -d | grep -v '^[[:space:]]*$' || true)
if [[ -n "$DUPES" ]]; then
  echo "FAIL: Duplicate sentences found:"
  echo "$DUPES" | sed 's/^/  /'
  FAIL=1
else
  echo "PASS: No duplicate sentences"
fi

# Check 8: Sentence length variance (CoV > 30%)
SENTENCE_STATS=$(awk 'BEGIN{RS="[.!?]"} NF>0{n++; sum+=NF; sumsq+=NF*NF} END{if(n==0) print "0 0 0 0"; else {mean=sum/n; var=sumsq/n - mean*mean; stddev=sqrt(var<0?0:var); cov=(mean>0)?(stddev/mean)*100:0; printf "%.1f %.1f %.1f %d\n", mean, stddev, cov, n}}' "$DRAFT")
MEAN=$(echo "$SENTENCE_STATS" | awk '{print $1}')
STDDEV=$(echo "$SENTENCE_STATS" | awk '{print $2}')
COV=$(echo "$SENTENCE_STATS" | awk '{print $3}')
SENT_COUNT=$(echo "$SENTENCE_STATS" | awk '{print $4}')
echo "INFO: Sentence length — mean: $MEAN, stddev: $STDDEV, CoV: $COV%, n: $SENT_COUNT"

COV_OK=$(awk -v cov="$COV" 'BEGIN{print (cov+0 > 30) ? 1 : 0}')
if [[ "$COV_OK" -eq 1 ]]; then
  echo "PASS: Burstiness CoV > 30%"
else
  echo "FAIL: Burstiness CoV < 30% (low sentence length variance)"
  FAIL=1
fi

echo
if [[ $FAIL -eq 0 ]]; then
  echo "=== ALL CHECKS PASSED ==="
  exit 0
else
  echo "=== CHECKS FAILED — see above ==="
  exit 1
fi
