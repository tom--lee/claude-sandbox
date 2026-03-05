#!/usr/bin/env bash
set -euo pipefail

podman build -t claude-sandbox "$(dirname "$0")"
