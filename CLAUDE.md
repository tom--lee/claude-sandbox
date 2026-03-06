# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A shell tool that launches Claude Code inside a rootless Podman container, persisted in a named tmux session. The core components are:

- `claude-sandbox` — the launcher script (bash)
- `Containerfile` — builds the container image from `node:lts-slim` with `@anthropic-ai/claude-code` installed globally
- `build-sandbox-container.sh` — builds the image as `claude-sandbox:latest`
- `test-sandbox.sh` — integration tests using a mock tmux

## Commands

```sh
# Build the container image
./build-sandbox-container.sh

# Run tests (requires a built image and authenticated Claude on the host)
./test-sandbox.sh
```

## Architecture

`claude-sandbox <identifier>` maps to tmux session `claude-sandbox-<identifier>`. If the session exists, it reattaches (using `switch-client` if already inside tmux, `attach-session` otherwise). If not, it creates a new tmux session running `podman run`.

The container mounts:
- `$(pwd)` → `/workspace` (the project directory)
- `~/.claude` and `~/.claude.json` → equivalent paths under `/home/node/` (auth tokens)
- `ANTHROPIC_API_KEY` env var is passed through

`claude-sandbox` with no argument lists existing sandbox sessions by querying tmux.

`test-sandbox.sh` uses a mock `tmux` binary injected via `PATH` to unit-test the attach/switch-client logic without requiring a real tmux session. Test 1 actually runs the container and requires network access and valid auth.
