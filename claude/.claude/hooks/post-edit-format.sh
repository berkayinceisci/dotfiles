#!/bin/bash
# Post-edit hook: auto-format edited files using the format script.

set -euo pipefail

if [[ -f "$CLAUDE_FILE_PATH" ]]; then
  format "$CLAUDE_FILE_PATH" 2>&1
fi
