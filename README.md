# claude-sandbox

Launches Claude Code in a rootless Podman container with the current directory mounted, persisted in a named tmux session.

## Setup

```sh
# Build the container image (re-run after Claude Code updates)
./build-sandbox-container.sh

# Symlink the launcher into your PATH
ln -s ~/work/claude-sandbox/claude-sandbox ~/bin/claude-sandbox
```

## Usage

```sh
cd ~/some/project
claude-sandbox <identifier>
```

- Creates tmux session `claude-sandbox-<identifier>` and attaches to it
- If the session already exists, reattaches (safe to run after SSH reconnect)
- Detach with `Ctrl-b d`

## What gets mounted

| Host | Container |
|------|-----------|
| `$(pwd)` | `/workspace` |
| `~/.claude` | `/root/.claude` (auth tokens & settings) |
| `~/.claude.json` | `/root/.claude.json` (main config file) |
| `ANTHROPIC_API_KEY` env var | passed through |

## Permissions

The container runs with `--dangerously-skip-permissions`, so Claude Code requires no confirmations. This is intentional — the container has no access to sensitive host data beyond the mounted project directory.
