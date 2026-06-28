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
  local tmpfile
  tmpfile=$(mktemp --suffix=.md)
  cp "${FIXTURES}/${fixture}" "$tmpfile"
  local args=("$tmpfile")
  [[ -n "$target" ]] && args+=("--target" "$target")
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

echo "[ok] all 10 tests passed"
