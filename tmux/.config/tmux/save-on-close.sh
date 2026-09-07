#!/bin/bash
# window-unlinked hook helper: keep the resurrect snapshot in sync with
# deliberate window closes.
#
# - Windows remain  -> run tmux-resurrect's save (snapshot without the closed
#   window), so continuum's restore reflects what is actually open.
# - No windows left -> the user deliberately closed everything: REMOVE the
#   `last` symlink instead of saving. An empty snapshot is poison: restore.sh
#   "restores from scratch" onto fresh session 0, restores nothing, then
#   kills session 0 (handle_session_0) -> exit-empty shuts the server down,
#   making a fresh `tmux` exit immediately. With `last` missing, restore
#   aborts cleanly at check_saved_session_exists. Timestamped snapshots are
#   kept on disk for manual recovery (re-point `last` at one).
set -uo pipefail

verbose=0
if [[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]]; then
  verbose=1
fi

log() {
  if [[ $verbose -eq 1 ]]; then
    echo "save-on-close: $*" >&2
  fi
}

save_script="$HOME/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"

# Query: non-zero exit / empty output are expected states, not errors
if windows="$(tmux list-windows -a 2>/dev/null)" && [[ -n "$windows" ]]; then
  log "windows remain; running $save_script quiet"
  exec "$save_script" quiet
else
  resurrect_dir="$(tmux show-options -gqv @resurrect-dir 2>/dev/null)"
  resurrect_dir="${resurrect_dir/#\~/$HOME}"
  [[ -n "$resurrect_dir" ]] || resurrect_dir="$HOME/.config/tmux/resurrect"
  log "no windows left; removing $resurrect_dir/last"
  rm -f "$resurrect_dir/last"
fi
