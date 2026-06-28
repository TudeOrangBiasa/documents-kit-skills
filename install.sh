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

  local clone_ok=false

  if [[ -d "$PEER_DIR/.git" ]] && [[ -f "$PEER_DIR/.git/HEAD" ]]; then
    # Healthy clone exists — update
    info "peer dir exists, pulling latest"
    if [[ "$DRY_RUN" != "true" ]] && (cd "$PEER_DIR" && git pull --ff-only 2>&1); then
      clone_ok=true
      # After pull, try to pull LFS objects
      if command -v git-lfs &>/dev/null; then
        (cd "$PEER_DIR" && git lfs pull 2>&1) || warn "git lfs pull failed after pull"
      else
        warn "git-lfs not installed — model will be missing"
      fi
    elif [[ "$DRY_RUN" != "true" ]]; then
      warn "git pull failed, recloning"
      rm -rf "$PEER_DIR"
    fi
  else
    # Missing or broken — clean and clone fresh
    [[ -d "$PEER_DIR" ]] && rm -rf "$PEER_DIR"
  fi

  if [[ "$clone_ok" != "true" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      info "[dry-run] git clone ${PEER_REPO} ${PEER_DIR}"
    else
      info "cloning ${PEER_NAME}..."
      if ! git clone "$PEER_REPO" "$PEER_DIR" 2>&1; then
        err "git clone failed"
        return 1
      fi
      # Pull LFS objects after clone
      if command -v git-lfs &>/dev/null; then
        (cd "$PEER_DIR" && git lfs pull 2>&1) || warn "git lfs pull failed after clone"
      else
        warn "git-lfs not installed — model will be missing"
      fi
    fi
    ok "${PEER_NAME} → ${PEER_DIR}"
  else
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
  if [[ -f "${PEER_DIR}/models/model_quantized.onnx" ]]; then
    # Check if it's an LFS pointer (small) or actual file (large)
    MODEL_SIZE_BYTES=$(stat -c%s "${PEER_DIR}/models/model_quantized.onnx" 2>/dev/null || echo "0")
    if [[ "$MODEL_SIZE_BYTES" -lt 1000 ]]; then
      warn "mE5 model is LFS pointer (${MODEL_SIZE_BYTES} bytes) — git lfs pull may have failed"
    else
      MODEL_SIZE=$(du -h "${PEER_DIR}/models/model_quantized.onnx" | awk '{print $1}')
      ok "mE5 model loaded (${MODEL_SIZE})"
    fi
  elif [[ -f "${PEER_DIR}/models/tokenizer.json" ]]; then
    warn "mE5 model missing but tokenizer present — git lfs pull may have failed"
  else
    warn "no model files in ${PEER_DIR}/models/ — ensure git-lfs was installed and pulled"
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

  # Use python3 for safe JSON editing with atomic write + backup
  python3 -c "
import json, os, sys, tempfile

config_path = '$OPENCODE_JSON'
mcp_key = '$MCP_KEY'
peer_dir = '$PEER_DIR'

# Read existing config with backup
if os.path.exists(config_path):
    with open(config_path) as f:
        config = json.load(f)
    backup_path = config_path + '.bak'
    with open(config_path) as orig, open(backup_path, 'w') as bak:
        bak.write(orig.read())
else:
    config = {}
    os.makedirs(os.path.dirname(config_path), exist_ok=True)

# Modify
config.setdefault('mcpServers', {})[mcp_key] = {
    'command': 'uv',
    'args': ['--directory', peer_dir, 'run', 'scholar-paper-mcp']
}

# Atomic write via tempfile in same dir
dir_name = os.path.dirname(config_path)
fd, tmp_path = tempfile.mkstemp(dir=dir_name, suffix='.json')
try:
    with os.fdopen(fd, 'w') as f:
        json.dump(config, f, indent=2)
        f.write('\n')
    os.replace(tmp_path, config_path)
except Exception:
    if os.path.exists(tmp_path):
        os.unlink(tmp_path)
    raise

print('registered')
" 2>&1 || {
    err "failed to register MCP server in ${OPENCODE_JSON}"
    return 1
  }

  ok "${MCP_KEY} → ${OPENCODE_JSON}"
}

# ── Step 5: Verify ────────────────────────────────────────────────

verify() {
  if [[ "$DRY_RUN" == "true" ]]; then
    step "[5/5] Verifying (dry-run)"
    info "[dry-run] would spawn scholar-paper-mcp via glue tool"
    info "[dry-run] would list MCP tools and call export_session_bibtex"
    ok "verify skipped (dry-run)"
    return 0
  fi

  step "[5/5] Verifying"

  local glue="$SCRIPT_DIR/tools/scholar_bibtex.py"
  local verify_bib="/tmp/verify-sample-$$.bib"

  # 1. Check peer dir exists and has .git
  if [[ ! -d "$PEER_DIR/.git" ]]; then
    err "peer dir missing or incomplete at ${PEER_DIR} — run './install.sh --peer-only' first"
    return 1
  fi

  # 2. List MCP tools via glue tool's __list_tools__ command
  info "spawning scholar-paper-mcp via glue tool..."
  local tools_output
  if ! tools_output=$(uv run --directory "$SCRIPT_DIR" "$glue" __list_tools__ 2>&1); then
    err "MCP server not responsive: ${tools_output}"
    return 1
  fi

  # 3. Verify expected tools present
  local tool_count
  tool_count=$(echo "$tools_output" | grep -c "^\[tool\]" || true)
  if [[ "$tool_count" -lt 15 ]]; then
    err "expected at least 15 tools, got ${tool_count}"
    return 1
  fi
  ok "${tool_count} tools listed"

  # 4. Call export with verify session
  info "calling export_session_bibtex (verify session)..."
  if ! uv run --directory "$SCRIPT_DIR" "$glue" export __verify_session__ "$verify_bib" 2>&1; then
    err "export_session_bibtex failed"
    rm -f "$verify_bib"
    return 1
  fi

  if [[ ! -f "$verify_bib" ]]; then
    err "output .bib not written"
    return 1
  fi

  local paper_count
  paper_count=$(grep -c "^@" "$verify_bib" 2>/dev/null || echo "0")
  rm -f "$verify_bib"
  ok "sample.bib written (${paper_count} papers)"
  return 0
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
      print_summary
      # Run verify LAST, after summary, so failure is clearly visible
      if ! verify; then
        EXIT=1
        err "self-verify failed — install completed but not all components working"
        err "run './install.sh --verify' to see details"
      fi
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
      if ! verify; then
        EXIT=1
      fi
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
