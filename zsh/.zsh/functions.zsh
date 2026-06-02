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
# Handles `tmux show-environment`'s two output shapes: `VAR=value` for set,
# and `-VAR` for "this variable was unset since the last attach".
refresh-env() {
    [[ -z "${TMUX:-}" ]] && return
    local line
    while IFS= read -r line; do
        case "$line" in
            -*)  unset "${line#-}" ;;
            *=*) export "$line" ;;
        esac
    done < <(tmux show-environment 2>/dev/null)
}

# Auto-refresh tmux-managed env vars on every prompt so DISPLAY, WAYLAND_DISPLAY,
# DBUS_SESSION_BUS_ADDRESS, etc. always reflect the most recently attached client.
# Cost is one (local, sub-ms) tmux roundtrip per prompt.
autoload -Uz add-zsh-hook
add-zsh-hook precmd refresh-env
