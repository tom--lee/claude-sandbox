# claude-sandbox

Launches Claude Code in a rootless Podman container with the current directory mounted, persisted in a named tmux session.

## Dependencies

- [Podman](https://podman.io/) (rootless)
- [tmux](https://github.com/tmux/tmux)

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
| `~/.claude` | `/home/node/.claude` (auth tokens & settings) |
| `~/.claude.json` | `/home/node/.claude.json` (main config file) |
| `ANTHROPIC_API_KEY` env var | passed through |

## Testing

```sh
./test-sandbox.sh
```

Runs Claude Code non-interactively in the container and verifies it starts and can authenticate.

## Permissions

The container runs with `--dangerously-skip-permissions`, so Claude Code requires no confirmations. This is intentional — the container has no access to sensitive host data beyond the mounted project directory.
