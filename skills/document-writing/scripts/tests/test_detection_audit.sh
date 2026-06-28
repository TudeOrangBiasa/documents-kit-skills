#!/usr/bin/env bash
# Test runner for detection-audit.sh check #9 (script intrusion)
set -euo pipefail

command -v pandoc &>/dev/null || { echo "[skip] pandoc required"; exit 0; }
command -v perl &>/dev/null || { echo "[skip] perl required"; exit 0; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES="${SCRIPT_DIR}/../../tests/fixtures/detection"
AUDIT="${SCRIPT_DIR}/../detection-audit.sh"

run_test() {
  local fixture="$1"
  local expected_exit="$2"
  local target="${3:-}"
  local use_equals="${4:-}"  # "equals" to use --target=value syntax
  local tmpfile
  tmpfile=$(mktemp --suffix=.md)
  cp "${FIXTURES}/${fixture}" "$tmpfile"
  local args=("$tmpfile")
  if [[ -n "$target" ]]; then
    if [[ "$use_equals" == "equals" ]]; then
      args+=("--target=$target")
    else
      args+=("--target" "$target")
    fi
  fi
  set +e
  "$AUDIT" "${args[@]}" >/dev/null 2>&1
  local actual=$?
  set -e
  rm -f "$tmpfile"
  if [[ "$actual" -eq "$expected_exit" ]]; then
    echo "  [ok] $fixture (exit=$actual)"
  else
    echo "  [err] $fixture expected=$expected_exit actual=$actual"
    exit 1
  fi
}

echo "=== Script intrusion detection tests ==="

run_test pure-en.md 0 en
run_test pure-id.md 0 id
run_test zh-in-en.md 1 en
run_test ja-in-en.md 1 en
run_test ko-in-en.md 1 en
run_test code-block-with-zh.md 0 en
run_test url-idn.md 0 en
run_test emoji-mixed.md 0 en
run_test inline-code-zh.md 0 en
run_test mixed-id-en-loanwords.md 0 id
run_test pure-en.md 0 en equals  # test --target=value syntax

echo "[ok] all 11 tests passed"
