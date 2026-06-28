#!/usr/bin/env bash
# detection-audit.sh — Audit a draft for AI-detection patterns.
# Usage: ./detection-audit.sh [--target <bcp47>] <draft.md>
# Exits 0 if all checks pass.
# Exits 1 if any check fails.
# Exits 2 if wrong usage.

set -euo pipefail

# Parse --target flag
TARGET=""
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ -z "${2:-}" ]] && { echo "Error: --target requires a value"; exit 2; }
      TARGET="$2"
      shift 2
      ;;
    --target=*)
      TARGET="${1#*=}"
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--target <bcp47>] <draft.md>"
      exit 0
      ;;
    -*)
      echo "Error: unknown option $1"
      exit 2
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 [--target <bcp47>] <draft.md>"
  exit 2
fi

DRAFT="$1"

if [[ ! -f "$DRAFT" ]]; then
  echo "Error: $DRAFT not found"
  exit 2
fi

# Auto-detect target from frontmatter if not provided via --target
if [[ -z "$TARGET" ]]; then
  TARGET=$(awk '/^---$/{c++;next} c==1 && /^lang:/{print $2; exit}' "$DRAFT")
fi

# Default target if still empty
if [[ -z "$TARGET" ]]; then
  echo "Warning: no target specified, defaulting to en" >&2
  TARGET="en"
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

# Check 9: Script intrusion detection
# Detect non-Latin scripts in Latin-target documents
check_script_intrusion() {
  local file="$1"
  local target="$2"
  local LATIN_LANGS=("id" "en" "ms" "fr" "de" "es" "pt" "it" "nl" "vi")
  local is_latin=0
  local lang

  for lang in "${LATIN_LANGS[@]}"; do
    if [[ "$lang" == "$target" ]]; then
      is_latin=1
      break
    fi
  done

  # Unmapped target: warn, treat as latin-like
  if [[ $is_latin -eq 0 ]]; then
    if [[ "$target" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
      echo "Warning: target '$target' not in v0.4 latin scope, defaulting to latin (inverse detection deferred to v0.5)" >&2
      is_latin=1
    else
      echo "Skip: $file target=$target (non-latin detection deferred to v0.5)"
      return 0
    fi
  fi

  # Check dependencies
  if ! command -v pandoc &>/dev/null; then
    echo "Error: pandoc required for check #9 (apt install pandoc)"
    return 2
  fi
  if ! command -v perl &>/dev/null; then
    echo "Error: perl required for check #9 (apt install perl)"
    return 2
  fi

  # Pre-process: strip code blocks and inline code, normalize with pandoc
  local plain_text
  plain_text=$(perl -0777 -pe '
    s/```.*?```//sg;
    s/~~~.*?~~~//sg;
    s/`[^`]+`//g;
  ' "$file" 2>/dev/null | pandoc --to plain 2>/dev/null) || {
    echo "Error: pandoc failed on $file"
    return 2
  }

  # Detect non-Latin Unicode blocks in plain text
  local detections
  detections=$(echo "$plain_text" | perl -CS -ne '
    s{https?://\S+}{}g;
    if (m/([\x{4e00}-\x{9fff}\x{3400}-\x{4dbf}\x{f900}-\x{faff}]+)/) {
      my $s = substr($1, 0, 50); print "CJK\t$.\t$s\n"; next;
    }
    if (m/([\x{3040}-\x{309f}]+)/) {
      my $s = substr($1, 0, 50); print "Hiragana\t$.\t$s\n"; next;
    }
    if (m/([\x{30a0}-\x{30ff}]+)/) {
      my $s = substr($1, 0, 50); print "Katakana\t$.\t$s\n"; next;
    }
    if (m/([\x{ac00}-\x{d7af}\x{1100}-\x{11ff}]+)/) {
      my $s = substr($1, 0, 50); print "Hangul\t$.\t$s\n"; next;
    }
    if (m/([\x{0600}-\x{06ff}\x{0750}-\x{077f}\x{08a0}-\x{08ff}]+)/) {
      my $s = substr($1, 0, 50); print "Arabic\t$.\t$s\n"; next;
    }
    if (m/([\x{0400}-\x{04ff}]+)/) {
      my $s = substr($1, 0, 50); print "Cyrillic\t$.\t$s\n"; next;
    }
    if (m/([\x{0e00}-\x{0e7f}]+)/) {
      my $s = substr($1, 0, 50); print "Thai\t$.\t$s\n"; next;
    }
    if (m/([\x{0900}-\x{097f}]+)/) {
      my $s = substr($1, 0, 50); print "Devanagari\t$.\t$s\n"; next;
    }
  ') || true

  if [[ -z "$detections" ]]; then
    echo "Pass: $file clean (target=$target)"
    return 0
  fi

  echo "FAIL: Script intrusion (target=$target):"
  while IFS=$'\t' read -r script_type line sample; do
    echo "  Error: $file:$line contains $script_type text: \"$sample\""
  done <<< "$detections"
  return 1
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

# Check 9: Script intrusion
echo
echo "--- Check 9: Script Intrusion ---"
check_script_intrusion "$DRAFT" "$TARGET" && rc=0 || rc=$?
case $rc in
  0) ;; # pass
  1) FAIL=1 ;;
  2) echo "Error: fatal — check #9 failed"; exit 2 ;;
esac

echo
if [[ $FAIL -eq 0 ]]; then
  echo "=== ALL CHECKS PASSED ==="
  exit 0
else
  echo "=== CHECKS FAILED — see above ==="
  exit 1
fi
