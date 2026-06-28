#!/usr/bin/env bash
# test_install_fresh.sh — Docker-based integration test for install.sh
#
# Builds a python:3.13-slim image with git, git-lfs, uv, jq.
# Mounts repo and runs install.sh --all, then verifies all AC.
# Cleanup via trap — no leaked containers or images.
#
# Usage:
#   ./tools/tests/integration/test_install_fresh.sh
#
# Environment:
#   SKIP_DOCKER_PULL=1   skip docker pull (use cached image)
#   TEST_IMAGE_TAG=tag    override image tag (default: doc-kit-test-<PID>)

set -euo pipefail

OK="[ok]"
ERR="[err]"
SKP="[skip]"

# ── Skip if Docker unavailable ─────────────────────────────────────

if ! command -v docker &>/dev/null; then
  echo "${SKP} docker not found — integration test requires Docker"
  exit 0
fi

# ── Paths ──────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TAG="${TEST_IMAGE_TAG:-doc-kit-test-$$}"
CONTAINER="test-install-$$"

# ── Cleanup ────────────────────────────────────────────────────────

cleanup() {
  docker rm -f "${CONTAINER}" &>/dev/null || true
  docker rmi -f "${TAG}" &>/dev/null || true
}
trap cleanup EXIT

# ── Build image ────────────────────────────────────────────────────

echo "[..] building test image (${TAG}) ..."
docker build -t "${TAG}" - <<'DOCKERFILE' 2>&1
FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git git-lfs ca-certificates curl jq && \
    rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv

RUN git lfs install
DOCKERFILE

echo "${OK} image built"

# ── Run install + verify ───────────────────────────────────────────

echo "[..] running install.sh --all in container ..."

docker run --name "${CONTAINER}" \
  -v "${REPO_DIR}:/repo" -w /repo \
  "${TAG}" \
  bash -c '
set -euo pipefail

HOME=/root

# Step 1: install
./install.sh --all

# Step 2: 4 skills symlinked in ~/.config/opencode/skills/
for s in document-writing drawio humanizer officecli; do
  target="${HOME}/.config/opencode/skills/${s}"
  if [ -L "$target" ]; then
    echo "  [ok] skill symlink: ${s}"
  else
    echo "  [err] missing skill symlink: ${s}"
    exit 1
  fi
done

# Step 3: peer .git/HEAD exists
peer_git="${HOME}/.local/share/documents-kit-skills/peer/scholar-paper-mcp/.git/HEAD"
if [ -f "$peer_git" ]; then
  echo "  [ok] peer .git/HEAD"
else
  echo "  [err] peer .git/HEAD missing: ${peer_git}"
  exit 1
fi

# Step 4: mE5 model > 1MB (real model, not LFS pointer)
model="${HOME}/.local/share/documents-kit-skills/peer/scholar-paper-mcp/models/model_quantized.onnx"
if [ -f "$model" ]; then
  size=$(stat -c%s "$model")
  if [ "$size" -gt 1000000 ]; then
    echo "  [ok] mE5 model ($(( size / 1024 / 1024 )) MB)"
  else
    echo "  [err] mE5 model too small: ${size} bytes (LFS pointer?)"
    exit 1
  fi
else
  echo "  [err] mE5 model file missing: ${model}"
  exit 1
fi

# Step 5: opencode.json has mcpServers.scholar-paper-mcp
config="${HOME}/.config/opencode/opencode.json"
if jq -e ".mcpServers[\"scholar-paper-mcp\"]" "$config" >/dev/null 2>&1; then
  echo "  [ok] mcpServers.scholar-paper-mcp in opencode.json"
else
  echo "  [err] mcpServers.scholar-paper-mcp missing in ${config}"
  exit 1
fi

# Step 6: install.sh --verify exits 0
echo "  [..] running install.sh --verify ..."
./install.sh --verify
echo "  [ok] install.sh --verify passed"

echo ""
echo "${OK} all assertions passed"
'

echo "  ${OK} docker integration test complete"
