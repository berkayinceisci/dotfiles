#!/bin/bash
# restore-on-start.sh: run tmux-resurrect's restore once, right after the tmux
# server starts. Launched from tmux.conf with `run-shell -b`; replaces
# tmux-continuum's auto-restore.
#
# Continuum skips the restore when `ps` lists other `tmux` processes besides
# the server, and it counts while tpm is still spawning `tmux set-option`
# calls, so a transient hit can skip the restore silently. Its auto-restore is
# switched off with the halt file ~/tmux_no_auto_restore; continuum stays for
# its periodic save.
#
# tmux.conf is sourced again on reloads (`tmux source-file`), which runs this
# script again. Restoring then would resurrect windows closed since, so the
# script only acts when the server started a few seconds ago.
#
# Usage: restore-on-start.sh [-v|--verbose]
# Decisions are appended to <resurrect-dir>/restore-on-start.log either way;
# -v mirrors them to stderr.
set -uo pipefail

verbose=0
if [[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]]; then
  verbose=1
fi

# The log lives in the resurrect dir, which is a tmux option, so resolve it
# first (same fallback as save-on-close.sh).
resurrect_dir="$(tmux show-options -gqv @resurrect-dir 2>/dev/null)"
resurrect_dir="${resurrect_dir/#\~/$HOME}"
[[ -n "$resurrect_dir" ]] || resurrect_dir="$HOME/.config/tmux/resurrect"
mkdir -p "$resurrect_dir"
log_file="$resurrect_dir/restore-on-start.log"

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" >>"$log_file"
  if [[ $verbose -eq 1 ]]; then
    echo "restore-on-start: $*" >&2
  fi
}

# Only a fresh server qualifies. #{start_time} is the server's epoch start.
max_age=15
start_time="$(tmux display-message -p '#{start_time}' 2>/dev/null)"
if [[ -z "$start_time" ]]; then
  log "cannot query the tmux server; giving up"
  exit 1
fi
age=$(( $(date +%s) - start_time ))
if (( age > max_age )); then
  log "server started ${age}s ago (> ${max_age}s): config reload, not a start; skipping"
  exit 0
fi

if [[ ! -f "$HOME/tmux_no_auto_restore" ]]; then
  log "WARNING: ~/tmux_no_auto_restore is missing, continuum may restore as well (re-stow the tmux package)"
fi

# tpm loads the plugins asynchronously (`run -b`). Wait until tmux-resurrect
# has registered its restore script and tmux-assistant-resurrect its
# post-restore hook (the one that relaunches claude); without the latter the
# restore would bring back the panes but not the agents.
restore_script=""
post_hook=""
for _ in $(seq 1 60); do
  restore_script="$(tmux show-options -gqv @resurrect-restore-script-path 2>/dev/null)"
  post_hook="$(tmux show-options -gqv @resurrect-hook-post-restore-all 2>/dev/null)"
  if [[ -n "$restore_script" && -n "$post_hook" ]]; then
    break
  fi
  sleep 0.5
done
if [[ -z "$restore_script" || -z "$post_hook" ]]; then
  log "plugins not loaded after 30s (restore script: '$restore_script', post-restore hook: '$post_hook'); giving up"
  exit 1
fi
# Same grace continuum gives tpm to finish the remaining plugins.
sleep 1

if [[ ! -e "$resurrect_dir/last" ]]; then
  log "no $resurrect_dir/last: nothing to restore"
  exit 0
fi

# Query: no match is the expected case. The pattern never appears in this
# script's own command line, so pgrep cannot self-match.
if pgrep -f 'tmux-resurrect/scripts/restore\.sh' >/dev/null 2>&1; then
  log "a resurrect restore is already running; skipping"
  exit 0
fi

log "restoring $(readlink "$resurrect_dir/last") into a server with $(tmux list-panes -a 2>/dev/null | wc -l | tr -d ' ') pane(s) via $restore_script"
"$restore_script"
ec=$?
log "restore finished (exit $ec)"
exit "$ec"
