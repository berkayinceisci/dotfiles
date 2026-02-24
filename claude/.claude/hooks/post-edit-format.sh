#!/bin/bash
# Post-edit hook: auto-format edited files using the format script.

set -eo pipefail

if [[ -n "${CLAUDE_FILE_PATH:-}" ]] && [[ -f "$CLAUDE_FILE_PATH" ]]; then
	format "$CLAUDE_FILE_PATH" >/dev/null 2>&1
fi
