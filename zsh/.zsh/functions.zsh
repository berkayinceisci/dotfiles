# --- FZF & Atuin & History Logic ---
(( $+commands[fzf] )) && HAS_FZF=1 || HAS_FZF=0
(( $+commands[atuin] )) && HAS_ATUIN=1 || HAS_ATUIN=0

function history {
    # If arguments are passed (e.g., history -d 10), always use builtin
    if [[ $# -gt 0 ]]; then
        builtin history "$@"
        return
    fi

    # Case: Interactive Terminal
    if [[ -t 1 ]]; then
        if (( HAS_ATUIN && HAS_FZF )); then
            local selected=$(atuin history list --cmd-only | awk '!seen[$0]++' | fzf --tac)
            [[ -n "$selected" ]] && print -z "$selected"
        elif (( HAS_ATUIN )); then
            # If Atuin exists but no FZF, Atuin's own search is better than a raw list
            atuin search -i
        elif (( HAS_FZF )); then
            local selected=$(builtin history 1 | fzf --tac)
            [[ -n "$selected" ]] && print -z "$selected"
        else
            builtin history 1
        fi
    # Case: Piping (e.g., history | grep "ls")
    else
        if (( HAS_ATUIN )); then
            atuin history list --cmd-only | awk '!seen[$0]++'
        else
            builtin history 1
        fi
    fi
}

bcd() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cd "$(xclip -o -selection clipboard)"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        cd "$(pbpaste)"
    fi
}

rcd() {
    sudo -i bash -c "cd \"$1\" && exec bash"
}

mkcd() {
    mkdir -p "$1" && cd "$1"
}

open() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        command open "$@"
    else
        xopen "$@"
    fi
}

ssht() {
    ssh -t "$@" "tmux attach"
}

# Pull the latest environment from the tmux server into the current shell.
# When tmux's update-environment list refreshes on attach, NEW panes inherit
# the new values, but EXISTING shells keep whatever they captured at startup.
# `refresh-env` patches that — call it manually after re-attaching from a
# fresh X session, or let the precmd hook below run it on every prompt.
#
# We merge tmux's global and session environments (read global first, then
# session, so the per-attach session values win). Two important rules:
#   - Skip `-VAR` unset markers. A marker only means "the last client to
#     attach lacked this var" (e.g. a plain `ssh … tmux attach` with no
#     DISPLAY) — NOT that the var should be empty. Honoring it would wipe a
#     perfectly good DISPLAY=:1 from the global env on every prompt, which is
#     exactly the bug this avoids. We never unset, only fill/refresh.
#   - Only touch the managed list, never blanket-export everything from the
#     global env (which holds PATH/HOME/… and would clobber shell-local edits).
refresh-env() {
    [[ -z "${TMUX:-}" ]] && return
    local -a managed=(DISPLAY WAYLAND_DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS \
                      SSH_CONNECTION SSH_CLIENT SSH_TTY LC_OPEN_HOST)
    local -A _env
    local line var
    while IFS= read -r line; do
        # `VAR=value` lines only; `-VAR` unset markers don't match and are dropped.
        [[ "$line" == *=* ]] && _env[${line%%=*}]=${line#*=}
    done < <(tmux show-environment -g 2>/dev/null; tmux show-environment 2>/dev/null)
    for var in $managed; do
        [[ -n "${_env[$var]:-}" ]] && export "$var=${_env[$var]}"
    done
}

# Auto-refresh tmux-managed env vars on every prompt so DISPLAY, WAYLAND_DISPLAY,
# DBUS_SESSION_BUS_ADDRESS, etc. always reflect the most recently attached client.
# Cost is one (local, sub-ms) tmux roundtrip per prompt.
autoload -Uz add-zsh-hook
add-zsh-hook precmd refresh-env
