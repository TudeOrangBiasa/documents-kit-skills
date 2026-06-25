#!/usr/bin/env bash
# install.sh — Install documents-kit-skills to ~/.config/opencode/skills/
# Usage:
#   ./install.sh           # symlink install (default, for development)
#   ./install.sh --copy    # copy install (for production)
#   ./install.sh --target /path/to/skills  # custom target
#   ./install.sh --dry-run # show what would happen

set -euo pipefail

# Defaults
MODE="symlink"
TARGET="${HOME}/.config/opencode/skills"
DRY_RUN=false

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --copy) MODE="copy" ;;
    --symlink) MODE="symlink" ;;
    --target) TARGET="$2"; shift ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      echo "Usage: $0 [--copy|--symlink] [--target PATH] [--dry-run]"
      exit 0
      ;;
    *) echo "Unknown flag: $1"; exit 2 ;;
  esac
  shift
done

# Find this script's dir (works for both direct execution and symlink)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Skills to install
SKILLS=(
  "document-writing"
  "drawio"
  "humanizer"
  "officecli"
)

echo "=== Install documents-kit-skills ==="
echo "Mode: $MODE"
echo "Target: $TARGET"
echo "Dry run: $DRY_RUN"
echo

# Check target dir
if [[ ! -d "$TARGET" ]]; then
  echo "Creating target directory: $TARGET"
  [[ "$DRY_RUN" == "true" ]] || mkdir -p "$TARGET"
fi

# Check each skill
for skill in "${SKILLS[@]}"; do
  SRC="$SCRIPT_DIR/skills/$skill"
  DEST="$TARGET/$skill"

  if [[ ! -d "$SRC" ]]; then
    echo "[SKIP] $skill — source not found at $SRC"
    continue
  fi

  if [[ -L "$DEST" ]]; then
    echo "[EXISTS] $skill — already symlinked"
    continue
  fi

  if [[ -d "$DEST" ]]; then
    echo "[EXISTS] $skill — directory exists (use --copy to overwrite)"
    continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY-RUN] Would $MODE: $SRC → $DEST"
  else
    case "$MODE" in
      symlink)
        ln -s "$SRC" "$DEST"
        echo "[INSTALLED] $skill — symlinked to $SRC"
        ;;
      copy)
        cp -r "$SRC" "$DEST"
        echo "[INSTALLED] $skill — copied to $DEST"
        ;;
    esac
  fi
done

# Optional: copy tools, presets, templates to a separate location
echo
echo "=== Optional assets ==="
echo "Tools (audit, fix, scan): $SCRIPT_DIR/tools/"
echo "Presets (design tokens): $SCRIPT_DIR/presets/"
echo "Templates (format files): $SCRIPT_DIR/templates/"
echo
echo "These are referenced by skills; copy or symlink as needed."
echo
echo "=== Done ==="
echo "Restart OpenCode to pick up the new skills."
