#!/bin/bash
# Block dangerous commands on non-cloudlab machines
set -euo pipefail

# Only apply on non-cloudlab machines
if [[ "$(hostname -f 2>/dev/null || hostname)" == *.cloudlab.us ]]; then
    exit 0
fi

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)

if [[ "$tool_name" == "Bash" ]]; then
    command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

    # Block sudo anywhere in command
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])sudo([^a-zA-Z0-9_]|$) ]]; then
        echo "BLOCKED: sudo is not allowed on this machine"
        exit 2
    fi

    # Block rm -rf
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f|rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r ]]; then
        echo "BLOCKED: rm -rf is not allowed on this machine"
        exit 2
    fi

    # Block mkfs
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])mkfs ]]; then
        echo "BLOCKED: mkfs is not allowed on this machine"
        exit 2
    fi

    # Block dd
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])dd([^a-zA-Z0-9_]|$) ]]; then
        echo "BLOCKED: dd is not allowed on this machine"
        exit 2
    fi

    # Block chmod -R
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])chmod[[:space:]]+-[a-zA-Z]*R ]]; then
        echo "BLOCKED: chmod -R is not allowed on this machine"
        exit 2
    fi

    # Block chown -R
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])chown[[:space:]]+-[a-zA-Z]*R ]]; then
        echo "BLOCKED: chown -R is not allowed on this machine"
        exit 2
    fi
fi

exit 0
