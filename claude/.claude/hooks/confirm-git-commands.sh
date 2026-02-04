#!/bin/bash
# Require user confirmation for git commit/push
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)

if [[ "$tool_name" == "Bash" ]]; then
    command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

    if [[ "$command" =~ (^|[^a-zA-Z0-9_])git[[:space:]]+(commit|push) ]]; then
        jq -n '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": "Git commit/push requires your approval"
            }
        }'
        exit 0
    fi
fi

exit 0
