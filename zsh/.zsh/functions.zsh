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

open() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        command open "$@"
    else
        local file="$1"

        if [[ -z "$file" ]]; then
            echo "Usage: open <file|url>"
            return 1
        fi

        # Handle URLs
        if [[ "$file" =~ ^https?:// ]]; then
            if command -v zen >/dev/null 2>&1; then
                zen "$file"
            else
                echo "Zen Browser not found"
                return 1
            fi
            return
        fi

        if [[ -d "$file" ]]; then
            if command -v thunar >/dev/null 2>&1; then
                thunar "$file"
            elif command -v nautilus >/dev/null 2>&1; then
                nautilus "$file"
            else
                xdg-open "$file"
            fi
            return
        fi

        case "${file:l}" in
            *.pdf)
                if command -v zathura >/dev/null 2>&1; then
                    zathura "$file" &>/dev/null
                else
                    echo "Install zathura"
                    return 1
                fi
                ;;
            *)
                xdg-open "$file" &>/dev/null
                ;;
        esac
    fi
}

# cp with progress bar (requires: brew install progress)
cpv() {
    cp "$@" &
    local pid=$!
    progress -wp $pid
    wait $pid
}
