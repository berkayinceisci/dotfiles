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
#
# macOS ships no `setsid` executable, so there a foreground python helper forks,
# the child calls os.setsid() and execs the renderer, and the helper exits only
# once that exec has happened (a close-on-exec pipe reaches EOF). Backgrounding
# a python helper instead would leave it in the hook's process group for the
# ~tens of ms python takes to start, so an immediate group reap would kill it.
# Either way the renderer leads its own session and survives the reap.
#
# -v / --verbose: log the chosen detach method and the exact command to stderr
# (also forwarded to the renderer, whose output is discarded once detached).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENDERER="${HERE}/log-session.py"

verbose=0
for arg in "$@"; do
    if [[ "$arg" == "-v" || "$arg" == "--verbose" ]]; then
        verbose=1
    fi
done

vlog() {
    if [[ $verbose -eq 1 ]]; then
        echo "[log-session.sh] $*" >&2
    fi
}

payload="$(cat)"   # the Stop-hook JSON on stdin

# Pull the fields we need out of the payload (robust to spaces; paths can't hold
# newlines). Done synchronously so the detached renderer needs no stdin.
tpath="$(printf '%s' "$payload" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("transcript_path",""))' 2>/dev/null)"
cwd="$(printf '%s' "$payload" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)"

[ -n "$tpath" ] || exit 0

# Detached, args-based render: setsid + </dev/null so it outlives this hook and
# is not reaped; --delay lets the transcript flush the final message first.
if command -v setsid >/dev/null 2>&1; then
    vlog "detach: setsid executable ($(command -v setsid))"
    vlog "cmd: setsid python3 $RENDERER --transcript $tpath --cwd $cwd --delay 1.0 $*"
    setsid python3 "$RENDERER" --transcript "$tpath" --cwd "$cwd" --delay 1.0 "$@" \
        </dev/null >/dev/null 2>&1 &
else
    vlog "detach: python3 fork+os.setsid() fallback (no setsid in PATH)"
    vlog "cmd: python3 -c <fork-setsid-exec> python3 $RENDERER --transcript $tpath --cwd $cwd --delay 1.0 $*"
    # Foreground on purpose: returns as soon as the detached renderer has exec'd.
    python3 -c '
import os, sys
r, w = os.pipe()
if os.fork() == 0:
    os.close(r)
    os.setsid()
    os.set_inheritable(w, False)  # closes on exec -> parent read() sees EOF
    try:
        os.execvp(sys.argv[1], sys.argv[1:])
    finally:
        os._exit(127)
os.close(w)
os.read(r, 1)
' python3 "$RENDERER" --transcript "$tpath" --cwd "$cwd" --delay 1.0 "$@" \
        </dev/null >/dev/null 2>&1
fi

exit 0
