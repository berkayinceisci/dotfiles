#!/bin/bash
# Test harness for confirm-dangerous-local.sh
# Bypasses the *.cloudlab.us hostname guard via a fake `hostname` on PATH.
set -u

HOOK="$(cd "$(dirname "$0")/.." && pwd)/confirm-dangerous-local.sh"
[[ -x "$HOOK" ]] || { echo "hook not executable: $HOOK"; exit 2; }

TMPDIR="$(mktemp -d -t confirm-dangerous-tests.XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT

# Fake `hostname` returning a non-cloudlab name (default test environment).
mkdir -p "$TMPDIR/bin-nocloud"
cat > "$TMPDIR/bin-nocloud/hostname" <<'EOF'
#!/bin/bash
echo "test-host.local"
EOF
chmod +x "$TMPDIR/bin-nocloud/hostname"

# Fake `hostname` returning a cloudlab name (for the short-circuit test).
mkdir -p "$TMPDIR/bin-cloud"
cat > "$TMPDIR/bin-cloud/hostname" <<'EOF'
#!/bin/bash
echo "node-0.example.cloudlab.us"
EOF
chmod +x "$TMPDIR/bin-cloud/hostname"

FAILS=0
TOTAL=0

# assert_decision NAME EXPECTED COMMAND [TOOL_NAME]
# EXPECTED: "allow", "ask", or "" (empty = no decision / silent exit 0)
assert_decision() {
    local name="$1"
    local expected="$2"
    local cmd="$3"
    local tool="${4:-Bash}"

    TOTAL=$((TOTAL+1))
    local input
    input=$(jq -n --arg tool "$tool" --arg cmd "$cmd" \
        '{tool_name:$tool, tool_input:{command:$cmd}}')

    local out ec
    out=$(printf '%s' "$input" | PATH="$TMPDIR/bin-nocloud:$PATH" "$HOOK" 2>&1)
    ec=$?

    if [[ $ec -ne 0 ]]; then
        printf 'FAIL: %s (hook exited %d)\n' "$name" "$ec"
        printf '  output: %s\n' "$out"
        FAILS=$((FAILS+1))
        return
    fi

    local actual=""
    if [[ -n "$out" ]]; then
        actual=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null || true)
    fi

    if [[ "$actual" == "$expected" ]]; then
        printf 'PASS: %s (decision=%q)\n' "$name" "$actual"
    else
        printf 'FAIL: %s\n' "$name"
        printf '  expected: %q\n' "$expected"
        printf '  actual:   %q\n' "$actual"
        printf '  raw output: %s\n' "$out"
        FAILS=$((FAILS+1))
    fi
}

# -- Cases --

# 1. Plain command, no danger
assert_decision "ls -la" "" "ls -la"

# 2. sudo
assert_decision "sudo whoami" "ask" "sudo whoami"

# 3. rm -rf
assert_decision "rm -rf /tmp/foo" "ask" "rm -rf /tmp/foo"

# 4. mkfs
assert_decision "mkfs.ext4 /dev/sda1" "ask" "mkfs.ext4 /dev/sda1"

# 5. ssh to cloudlab, sudo inside single-quoted remote script
assert_decision "ssh cloudlab + remote sudo (single-line)" "allow" \
    "ssh user@node-0.experiment.cloudlab.us 'sudo reboot'"

# 6. ssh to cloudlab with multi-line quoted remote script
ml_cmd=$(printf '%s\n' \
    'ssh user@node-0.experiment.cloudlab.us "$(cat <<'"'"'EOF'"'"'' \
    'sudo reboot' \
    'EOF' \
    ')"')
assert_decision "ssh cloudlab + remote sudo (multi-line)" "allow" "$ml_cmd"

# 7. ssh to localhost with no sourced wrapper -> not classifiable as trusted
assert_decision "ssh -p localhost sudo (no wrapper file)" "ask" \
    "ssh -p 2222 root@localhost 'sudo X'"

# 8. Port-forward VM wrapper script
WRAPPER="$TMPDIR/vm-ssh.sh"
cat > "$WRAPPER" <<'EOF'
#!/bin/bash
ssh -p 2222 user@localhost "$@"
EOF
chmod +x "$WRAPPER"
assert_decision "vm-ssh.sh wrapper (port-forward VM)" "allow" \
    "bash $WRAPPER 'sudo X'"

# 9. source ./cloudlab-env.sh && rm -rf /tmp/x
#    The rm runs locally; sourcing an env file does not redirect it to
#    the remote. The hook should still ask, even though REMOTE_TRUSTED=1.
ENVFILE="$TMPDIR/cloudlab-env.sh"
cat > "$ENVFILE" <<'EOF'
export REMOTE_HOST=node-0.experiment.cloudlab.us
EOF
assert_decision "source cloudlab-env then local rm -rf" "ask" \
    "source $ENVFILE && rm -rf /tmp/x"

# 10. bash < setup.sh where setup contains a cloudlab ssh
SETUP="$TMPDIR/setup.sh"
cat > "$SETUP" <<'EOF'
ssh user@node-0.experiment.cloudlab.us 'echo hi'
EOF
assert_decision "bash < setup.sh (cloudlab inside)" "allow" "bash < $SETUP"

# 11. bash < setup.sh where setup.sh mixes a cloudlab ssh (the trust marker)
#     with a locally-dangerous rm -rf. The outer command has no danger
#     token, but the file's contents are inspected per-line: the ssh line
#     is exempt, the rm -rf line is not -> ask.
SETUP_MIX="$TMPDIR/setup-mixed.sh"
cat > "$SETUP_MIX" <<'EOF'
ssh user@node-0.experiment.cloudlab.us 'echo ok'
rm -rf /home/someuser/important
EOF
assert_decision "bash < setup.sh (cloudlab ssh + local rm)" "ask" \
    "bash < $SETUP_MIX"

# 12. Plain command with no redirections / source / path / danger tokens
assert_decision "innocuous echo" "" "echo hello world"

# 13. Tool other than Bash with a dangerous command string
assert_decision "Read tool with rm -rf command" "" "rm -rf /" "Read"

# 14. Cloudlab-host short-circuit: hostname -f returns cloudlab name; hook
#     exits 0 silently even for a clearly dangerous command.
TOTAL=$((TOTAL+1))
cloud_in=$(jq -n '{tool_name:"Bash", tool_input:{command:"sudo rm -rf /"}}')
cloud_out=$(printf '%s' "$cloud_in" | PATH="$TMPDIR/bin-cloud:$PATH" "$HOOK" 2>&1)
cloud_ec=$?
if [[ $cloud_ec -eq 0 && -z "$cloud_out" ]]; then
    printf 'PASS: cloudlab-host short-circuit (exit 0, no output)\n'
else
    printf 'FAIL: cloudlab-host short-circuit\n'
    printf '  expected: exit 0, empty output\n'
    printf '  actual:   exit %d, output: %s\n' "$cloud_ec" "$cloud_out"
    FAILS=$((FAILS+1))
fi

printf '\n=== %d/%d passed (%d failed) ===\n' "$((TOTAL-FAILS))" "$TOTAL" "$FAILS"
exit $(( FAILS > 0 ? 1 : 0 ))
