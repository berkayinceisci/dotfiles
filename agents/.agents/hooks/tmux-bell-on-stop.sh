#!/usr/bin/env bash
# Claude Code `Stop` hook: ring the tmux bell for this pane, so the window
# highlights in the status bar exactly once -- when the agent finishes its
# response. Registered in both ~/.claude and ~/.claude-moatlab settings.json.
#
# Why the bell and not monitor-activity: activity fires on ANY output, i.e. on
# every spinner tick and tool result, so a background agent window is lit up
# permanently and the highlight carries no information. The bell is an explicit
# one-shot attention request, it is styled separately
# (window-status-bell-style), and tmux clears it by itself when the window is
# next selected. tmux.conf therefore runs with monitor-activity off and
# monitor-bell on.
#
# The BEL goes to the pane's tty rather than this process's stdout, which the
# hook runner captures. wezterm.lua sets audible_bell = "Disabled" so this is a
# status-bar highlight only, never a noise.
#
# Silent no-op outside tmux (plain terminal, ssh, CI) -- never fail a turn over
# a cosmetic alert, hence no `set -e`.
set -uo pipefail

verbose=0
if [[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]]; then
    verbose=1
fi
log() {
    if [[ $verbose -eq 1 ]]; then
        printf 'tmux-bell-on-stop: %s\n' "$1" >&2
    fi
}

if [[ -z "${TMUX_PANE:-}" ]]; then
    log "TMUX_PANE unset -- not running inside tmux, nothing to ring"
    exit 0
fi
log "TMUX_PANE=${TMUX_PANE} TMUX=${TMUX:-unset}"

# Query: tmux exits non-zero if the server is gone or the pane has since died.
if ! pane_tty="$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)"; then
    log "tmux display-message failed (server or pane gone) -- skipping"
    exit 0
fi
if [[ -z "$pane_tty" || ! -w "$pane_tty" ]]; then
    log "pane tty '${pane_tty}' missing or not writable -- skipping"
    exit 0
fi

log "writing BEL to ${pane_tty}"
printf '\a' >"$pane_tty"
