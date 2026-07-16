#!/usr/bin/env bash
# Claude Code `Stop` hook: render the current session transcript to a markdown
# log. Registered in both ~/.claude and ~/.claude-moatlab settings.json.
#
# The hook is handed the session's transcript path + cwd on stdin (no
# before/after .jsonl diffing like the old cc-with-session-logging wrapper). It
# fires every turn, so the log survives crashes/kills.
#
# Two timing subtleties, both handled here:
#   1. A render detached with a bare `printf | setsid python &` (stdin tied to
#      the pipe) can be reaped before it finishes -> stale log. We instead parse
#      the payload up front and launch the renderer via ARGS with stdin from
#      /dev/null under setsid, which survives the hook returning and adds no
#      per-turn latency.
#   2. When the Stop hook fires, Claude may not have flushed THIS turn's final
#      assistant message to the transcript yet -> the render would miss the last
#      message. `--delay` lets it land first (cheap, since the render is
#      detached and off the turn's critical path).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENDERER="${HERE}/log-session.py"

payload="$(cat)"   # the Stop-hook JSON on stdin

# Pull the fields we need out of the payload (robust to spaces; paths can't hold
# newlines). Done synchronously so the detached renderer needs no stdin.
tpath="$(printf '%s' "$payload" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("transcript_path",""))' 2>/dev/null)"
cwd="$(printf '%s' "$payload" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)"

[ -n "$tpath" ] || exit 0

# Detached, args-based render: setsid + </dev/null so it outlives this hook and
# is not reaped; --delay lets the transcript flush the final message first.
setsid python3 "$RENDERER" --transcript "$tpath" --cwd "$cwd" --delay 1.0 "$@" \
    </dev/null >/dev/null 2>&1 &

exit 0
