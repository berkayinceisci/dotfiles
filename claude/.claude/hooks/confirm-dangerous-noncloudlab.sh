#!/bin/bash
# Require confirmation for dangerous commands on non-cloudlab machines
set -euo pipefail

# Only apply on non-cloudlab machines
if [[ "$(hostname -f 2>/dev/null || hostname)" == *.cloudlab.us ]]; then
    exit 0
fi

ask_permission() {
    local reason="$1"
    jq -n --arg reason "$reason" '{
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": $reason
        }
    }'
    exit 0
}

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)

if [[ "$tool_name" == "Bash" ]]; then
    command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

    # sudo anywhere in command
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])sudo([^a-zA-Z0-9_]|$) ]]; then
        ask_permission "sudo requires your approval"
    fi

    # rm -rf
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f|rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r ]]; then
        ask_permission "rm -rf requires your approval"
    fi

    # mkfs
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])mkfs ]]; then
        ask_permission "mkfs requires your approval"
    fi

    # dd
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])dd([^a-zA-Z0-9_]|$) ]]; then
        ask_permission "dd requires your approval"
    fi

    # chmod -R
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])chmod[[:space:]]+-[a-zA-Z]*R ]]; then
        ask_permission "chmod -R requires your approval"
    fi

    # chown -R
    if [[ "$command" =~ (^|[^a-zA-Z0-9_])chown[[:space:]]+-[a-zA-Z]*R ]]; then
        ask_permission "chown -R requires your approval"
    fi
fi

exit 0
