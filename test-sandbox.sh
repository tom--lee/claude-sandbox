#!/usr/bin/env bash
set -euo pipefail

IMAGE="claude-sandbox:latest"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; ((PASS++)); }
fail() { echo "FAIL: $1"; ((FAIL++)); }

TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# Test 1: container starts and Claude authenticates
echo "Test 1: container starts and Claude authenticates..."
podman run --rm \
    --userns=keep-id \
    -v "${HOME}/.claude:/home/node/.claude:z" \
    -v "${HOME}/.claude.json:/home/node/.claude.json:z" \
    -e ANTHROPIC_API_KEY \
    "$IMAGE" \
    -p "Reply with only the word READY"
pass "container starts and Claude authenticates"

# Helper: create a mock tmux that records its arguments and stubs out
# has-session (returns 0 = session exists) and the attach/switch commands.
make_mock_tmux() {
    local stub_has_session="$1"  # 0 = exists, 1 = not found
    cat > "$TMPDIR/tmux" <<EOF
#!/usr/bin/env bash
echo "\$@" >> "$TMPDIR/tmux.log"
case "\$1" in
    has-session) exit $stub_has_session ;;
    set-option)  exit 0 ;;
    new-session) exit 0 ;;
    attach-session|switch-client) exit 0 ;;
esac
EOF
    chmod +x "$TMPDIR/tmux"
    > "$TMPDIR/tmux.log"
}

SCRIPT="$(dirname "$0")/claude-sandbox"

# Test 2: session exists, outside tmux → should use attach-session
echo "Test 2: reattach outside tmux uses attach-session..."
make_mock_tmux 0
if PATH="$TMPDIR:$PATH" TMUX="" bash "$SCRIPT" testid 2>/dev/null; then
    if grep -q "^attach-session" "$TMPDIR/tmux.log"; then
        pass "reattach outside tmux uses attach-session"
    else
        fail "reattach outside tmux: expected attach-session, got: $(cat "$TMPDIR/tmux.log")"
    fi
else
    fail "reattach outside tmux: script exited non-zero"
fi

# Test 3: session exists, inside tmux → should use switch-client
echo "Test 3: reattach inside tmux uses switch-client..."
make_mock_tmux 0
if PATH="$TMPDIR:$PATH" TMUX="/tmp/tmux-fake,0,0" bash "$SCRIPT" testid 2>/dev/null; then
    if grep -q "^switch-client" "$TMPDIR/tmux.log"; then
        pass "reattach inside tmux uses switch-client"
    else
        fail "reattach inside tmux: expected switch-client, got: $(cat "$TMPDIR/tmux.log")"
    fi
else
    fail "reattach inside tmux: script exited non-zero"
fi

# Test 4: reattach works from any directory
echo "Test 4: reattach works from a different directory..."
make_mock_tmux 0
if (cd /tmp && PATH="$TMPDIR:$PATH" TMUX="" bash "$SCRIPT" testid 2>/dev/null); then
    if grep -q "^attach-session" "$TMPDIR/tmux.log"; then
        pass "reattach works from a different directory"
    else
        fail "reattach from different dir: expected attach-session, got: $(cat "$TMPDIR/tmux.log")"
    fi
else
    fail "reattach from different dir: script exited non-zero"
fi

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed."
[ "$FAIL" -eq 0 ]
