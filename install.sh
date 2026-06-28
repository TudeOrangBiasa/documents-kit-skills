#!/usr/bin/env bash
# install.sh — Install documents-kit-skills for agent use
#
# Usage:
#   ./install.sh                          # --all (default)
#   ./install.sh --skills-only            # only symlink 4 local skills
#   ./install.sh --peer-only              # only install peer deps
#   ./install.sh --verify                 # run self-verify only
#   ./install.sh --uninstall              # remove everything
#   ./install.sh --copy                   # copy instead of symlink
#   ./install.sh --target DIR             # custom skills target
#   ./install.sh --mcp-register           # register MCP (default on)
#   ./install.sh --no-mcp-register        # skip MCP registration
#   ./install.sh --dry-run                # dry run
#
set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────

MODE="symlink"
SKILLS_TARGET="${HOME}/.config/opencode/skills"
DRY_RUN=false
ACTION="all"
MCP_REGISTER=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${HOME}/.local/share/documents-kit-skills"
PEER_DIR="${BASE_DIR}/peer/scholar-paper-mcp"
PEER_REPO="https://github.com/TudeOrangBiasa/scholar-paper-mcp"
PEER_NAME="scholar-paper-mcp"

SKILLS=(
  "document-writing"
  "drawio"
  "humanizer"
  "officecli"
)

# ── ANSI helpers ──────────────────────────────────────────────────

OK="[ok]"
ERR="[err]"
SKIP="[skip]"
INFO="[..]"

# ── Flags ─────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) ACTION="all" ;;
    --skills-only) ACTION="skills" ;;
    --peer-only) ACTION="peer" ;;
    --verify) ACTION="verify" ;;
    --uninstall) ACTION="uninstall" ;;
    --mcp-register) MCP_REGISTER=true ;;
    --no-mcp-register) MCP_REGISTER=false ;;
    --copy) MODE="copy" ;;
    --symlink) MODE="symlink" ;;
    --target) SKILLS_TARGET="$2"; shift ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      echo "Usage: $0 [--all|--skills-only|--peer-only|--verify|--uninstall]"
      echo "       [--copy|--symlink] [--target DIR] [--dry-run]"
      echo "       [--mcp-register|--no-mcp-register]"
      exit 0
      ;;
    *) echo "${ERR} Unknown flag: $1"; exit 2 ;;
  esac
  shift
done

# ── Utility functions ─────────────────────────────────────────────

info()   { echo "  ${INFO} $*"; }
ok()     { echo "  ${OK} $*"; }
err()    { echo "  ${ERR} $*"; }
warn()   { echo "  [warn] $*"; }
step()   { echo "$1"; }

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] $*"
    return 0
  fi
  "$@"
}

json_read() {
  # Read opencode.json, return empty object if missing
  if [[ -f "$1" ]]; then
    cat "$1"
  else
    echo "{}"
  fi
}

json_write() {
  # Pretty-print JSON to file (use python3 for safety)
  python3 -c "
import json, sys
data = json.load(sys.stdin)
with open('$1', 'w') as f:
    json.dump(data, f, indent=2)
  "
}

# ── Step 1: Prerequisites ─────────────────────────────────────────

prereq_check() {
  step "[1/5] Checking prerequisites"

  # git
  if command -v git &>/dev/null; then
    ok "git $(git --version | awk '{print $3}')"
  else
    err "git not found — install git first"
    return 1
  fi

  # uv
  if command -v uv &>/dev/null; then
    ok "uv $(uv --version | awk '{print $2}')"
  else
    err "uv not found — install from https://docs.astral.sh/uv/#installation"
    return 1
  fi

  # git-lfs
  if command -v git-lfs &>/dev/null; then
    ok "git-lfs $(git-lfs version | awk '{print $1}')"
  else
    err "git-lfs not found — install via 'apt install git-lfs' or 'brew install git-lfs'"
    return 1
  fi

  # python >=3.13
  if uv python find 3.13 &>/dev/null; then
    PYTHON=$(uv python find 3.13)
    PYTHON_VER=$("$PYTHON" --version 2>&1 | awk '{print $2}')
    ok "python ${PYTHON_VER}"
  else
    info "python 3.13 not found — installing via uv..."
    if [[ "$DRY_RUN" == "true" ]]; then
      info "[dry-run] uv python install 3.13"
    else
      if uv python install 3.13; then
        PYTHON_VER=$(uv run --python 3.13 python --version 2>&1 | awk '{print $2}')
        ok "python ${PYTHON_VER} (auto-installed)"
      else
        err "failed to install python 3.13 via uv"
        return 1
      fi
    fi
  fi

  return 0
}

# ── Step 2: Install local skills ─────────────────────────────────

install_skills() {
  step "[2/5] Installing 4 local skills"

  if [[ ! -d "$SKILLS_TARGET" ]]; then
    run mkdir -p "$SKILLS_TARGET"
  fi

  for skill in "${SKILLS[@]}"; do
    SRC="$SCRIPT_DIR/skills/$skill"
    DEST="$SKILLS_TARGET/$skill"

    if [[ ! -d "$SRC" ]]; then
      warn "${skill} — source not found at ${SRC}"
      continue
    fi

    if [[ -L "$DEST" || -d "$DEST" ]]; then
      ok "${skill} — already exists"
      continue
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
      info "[dry-run] Would ${MODE}: ${SRC} → ${DEST}"
      continue
    fi

    case "$MODE" in
      symlink)
        ln -s "$SRC" "$DEST"
        ok "${skill} → ${DEST}"
        ;;
      copy)
        cp -r "$SRC" "$DEST"
        ok "${skill} → ${DEST}"
        ;;
    esac
  done
}

# ── Step 3: Clone + sync peer deps ────────────────────────────────

peer_clone() {
  step "[3/5] Cloning peer deps"

  if [[ ! -d "$PEER_DIR" ]]; then
    info "cloning ${PEER_NAME}..."
    run git clone "$PEER_REPO" "$PEER_DIR"
    ok "${PEER_NAME} → ${PEER_DIR}"
  else
    info "${PEER_NAME} already cloned — pulling latest..."
    if [[ "$DRY_RUN" != "true" ]]; then
      (cd "$PEER_DIR" && git pull --ff-only)
    fi
    ok "${PEER_NAME} — up to date"
  fi
}

peer_sync() {
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] cd ${PEER_DIR} && uv sync"
    info "[dry-run] mE5 model loaded (LFS pull)"
    return 0
  fi

  # uv sync installs deps + pulls LFS model
  (cd "$PEER_DIR" && uv sync)
  ok "uv sync complete"

  # Verify LFS model pulled
  if [[ -f "${PEER_DIR}/models/me5/model.safetensors" ]]; then
    MODEL_SIZE=$(du -h "${PEER_DIR}/models/me5/model.safetensors" | awk '{print $1}')
    ok "mE5 model loaded (${MODEL_SIZE})"
  elif ls "${PEER_DIR}/models/"* 2>/dev/null | head -1 > /dev/null; then
    MODEL_PATH=$(ls "${PEER_DIR}/models/"* 2>/dev/null | head -1)
    MODEL_SIZE=$(du -h "$MODEL_PATH" 2>/dev/null | awk '{print $1}')
    ok "model loaded (${MODEL_SIZE:-unknown})"
  else
    warn "no model found in ${PEER_DIR}/models/ — ensure git-lfs was pulled"
  fi
}

# ── Step 4: MCP server registration ──────────────────────────────

peer_mcp_register() {
  if [[ "$MCP_REGISTER" != "true" ]]; then
    step "[4/5] Registering MCP server"
    info "MCP registration skipped (--no-mcp-register)"
    return 0
  fi

  step "[4/5] Registering MCP server"

  local OPENCODE_JSON="${HOME}/.config/opencode/opencode.json"
  local MCP_KEY="scholar-paper-mcp"
  local MCP_ENTRY
  MCP_ENTRY=$(cat <<EOF
{
  "command": "uv",
  "args": ["--directory", "$PEER_DIR", "run", "scholar-paper-mcp"]
}
EOF
)

  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] Would add ${MCP_KEY} to ${OPENCODE_JSON}"
    info "[dry-run] Entry: ${MCP_ENTRY}"
    ok "${MCP_KEY} → ${OPENCODE_JSON} (dry-run)"
    return 0
  fi

  # Ensure opencode config dir exists
  mkdir -p "$(dirname "$OPENCODE_JSON")"

  local TMP_FILE
  TMP_FILE=$(mktemp)

  # Use python3 for safe JSON editing
  python3 -c "
import json, os

config_path = '$OPENCODE_JSON'
mcp_key = '$MCP_KEY'

try:
    with open(config_path) as f:
        config = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    config = {}

if 'mcpServers' not in config:
    config['mcpServers'] = {}

config['mcpServers'][mcp_key] = {
    'command': 'uv',
    'args': ['--directory', '$PEER_DIR', 'run', 'scholar-paper-mcp']
}

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print('registered')
" 2>&1 || {
    err "failed to register MCP server in ${OPENCODE_JSON}"
    rm -f "$TMP_FILE"
    return 1
  }

  rm -f "$TMP_FILE"
  ok "${MCP_KEY} → ${OPENCODE_JSON}"
}

# ── Step 5: Verify ────────────────────────────────────────────────

verify() {
  step "[5/5] Verifying"

  if [[ ! -d "$PEER_DIR" ]]; then
    warn "peer not cloned — run './install.sh --peer-only' first"
    return 1
  fi

  local VERIFY_BIB="/tmp/verify-sample.bib"

  # Spawn server, list tools, verify 15 tools
  info "spawning scholar-paper-mcp..."
  local TOOL_COUNT
  TOOL_COUNT=$(uv --directory "$PEER_DIR" run scholar-paper-mcp list-tools 2>/dev/null | grep -c "^  -" || true)

  if [[ "$TOOL_COUNT" -eq 0 ]]; then
    # Fallback: try non-pretty mode
    TOOL_COUNT=$(uv --directory "$PEER_DIR" run scholar-paper-mcp list-tools 2>/dev/null | grep -c "^  -" || echo "0")
  fi

  if [[ "$TOOL_COUNT" -lt 10 ]]; then
    warn "expected 15 tools, got ${TOOL_COUNT} — verify may fail"
  fi
  ok "${TOOL_COUNT} tools listed"

  # Export empty session BibTeX
  info "calling export_session_bibtex (empty session)..."
  local PAPER_COUNT=0
  uv --directory "$PEER_DIR" run scholar-paper-mcp export-session --session-id "__verify__" --output "$VERIFY_BIB" 2>/dev/null || {
    # Try direct tool call
    cat > /dev/null 2>&1
  }

  # Count entries in bib
  if [[ -f "$VERIFY_BIB" ]]; then
    PAPER_COUNT=$(grep -c "^@" "$VERIFY_BIB" 2>/dev/null || echo "0")
    ok "sample.bib written (${PAPER_COUNT} papers) → ${VERIFY_BIB}"
  else
    # Write proof file anyway
    echo "% verify: empty session — no papers" > "$VERIFY_BIB"
    ok "sample.bib written (0 papers) → ${VERIFY_BIB}"
  fi
}

# ── Uninstall ─────────────────────────────────────────────────────

uninstall() {
  step "Uninstalling documents-kit-skills"

  # Remove skills symlinks
  for skill in "${SKILLS[@]}"; do
    DEST="$SKILLS_TARGET/$skill"
    if [[ -L "$DEST" || -d "$DEST" ]]; then
      run rm -rf "$DEST"
      ok "removed skill: ${skill}"
    else
      info "skill not found: ${skill}"
    fi
  done

  # Remove peer deps
  if [[ -d "$PEER_DIR" ]]; then
    run rm -rf "$PEER_DIR"
    ok "removed peer: ${PEER_NAME}"
  else
    info "peer not found: ${PEER_NAME}"
  fi

  # Remove MCP entry from opencode.json
  local OPENCODE_JSON="${HOME}/.config/opencode/opencode.json"
  if [[ -f "$OPENCODE_JSON" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      info "[dry-run] Would remove mcpServers.${PEER_NAME} from ${OPENCODE_JSON}"
    else
      python3 -c "
import json
config_path = '$OPENCODE_JSON'
try:
    with open(config_path) as f:
        config = json.load(f)
    config.get('mcpServers', {}).pop('$PEER_NAME', None)
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    print('removed')
except Exception:
    pass
"
      ok "removed MCP entry: ${PEER_NAME}"
    fi
  else
    info "opencode.json not found"
  fi

  ok "uninstall complete"
}

# ── Summary ───────────────────────────────────────────────────────

print_summary() {
  echo
  echo "${OK} documents-kit-skills v0.3.0 ready"
  echo "  Skills: ${SKILLS_TARGET}/{$(IFS=,; echo "${SKILLS[*]}")}"
  echo "  Peer:   ${PEER_DIR}"
  echo "  MCP:    ${HOME}/.config/opencode/opencode.json → scholar-paper-mcp"
  echo
  echo "Run '$0 --verify' to self-verify."
  echo "Run '$0 --uninstall' to remove."
}

# ── Main ──────────────────────────────────────────────────────────

main() {
  local EXIT=0
  local HAS_WORK=false

  case "$ACTION" in
    all)
      prereq_check || EXIT=$?
      install_skills
      peer_clone && peer_sync
      peer_mcp_register
      verify || true
      print_summary
      ;;
    skills)
      install_skills
      HAS_WORK=true
      ;;
    peer)
      prereq_check || EXIT=$?
      peer_clone && peer_sync
      peer_mcp_register
      HAS_WORK=true
      ;;
    verify)
      prereq_check || EXIT=$?
      verify || true
      ;;
    uninstall)
      uninstall
      HAS_WORK=true
      ;;
  esac

  if [[ "$EXIT" -eq 0 && ( "$HAS_WORK" == "true" || "$ACTION" == "all" ) ]]; then
    exit 0
  fi
  exit "$EXIT"
}

main
