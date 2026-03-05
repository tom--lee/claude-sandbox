#!/usr/bin/env bash
set -euo pipefail

IMAGE="claude-sandbox:latest"

echo "Testing claude-sandbox container..."

podman run --rm \
    --userns=keep-id \
    -v "${HOME}/.claude:/home/node/.claude:z" \
    -v "${HOME}/.claude.json:/home/node/.claude.json:z" \
    -e ANTHROPIC_API_KEY \
    "$IMAGE" \
    -p "Reply with only the word READY"

echo "Test passed."
