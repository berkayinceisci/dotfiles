HISTFILE=$HOME/.zsh_history

HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# --- FZF & Atuin & History Logic ---
if command -v fzf >/dev/null 2>&1; then
    FZF_ALT_C_COMMAND=
    FZF_CTRL_T_COMMAND=
    source <(fzf --zsh)
fi

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow)"

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

bindkey '^[[1;5D' backward-word # ctrl-leftarrow
bindkey '^[[1;5C' forward-word  # ctrl-rightarrow
bindkey '^H' backward-kill-word # ctrl-backspace
setopt interactive_comments

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# case insensitive autocompletion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"

export PATH="$HOME/.local/go/bin:$PATH"
export GOROOT="$HOME/.local/go"
export GOPATH="$HOME/go"
export PATH="$HOME/go/bin:$PATH"

. "$HOME/.cargo/env"

export MANPAGER="less -R --use-color -Dd+r -Du+b"

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

alias e="exit"
alias v="nvim"
alias tmux="tmux -f ~/.config/tmux/tmux.conf"
alias lgit="lazygit --use-config-dir ~/.config/lazygit/"
alias ldoc="lazydocker"
alias img="wezterm imgcat"
alias glow="glow -p"
alias tldr='tldr -c'

alias dotfiles="cd ~/dotfiles/; nvim .; cd - > /dev/null"

if [[ -e ~/.cargo/bin/eza ]]; then
    alias ls="eza"
    alias ll="eza -l"
    alias la="eza -a"
    alias lla="eza -la"
else
    alias ll="ls -l"
    alias la="ls -a"
    alias lla="ls -la"
fi

if [[ -e ~/.cargo/bin/bat ]]; then
    alias less="bat --paging=always"
    alias cat="bat -pp"
fi

if [[ -e ~/.cargo/bin/zoxide ]]; then
    eval "$(zoxide init zsh)"
    alias cd=z
fi

bcd() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cd "$(xclip -o -selection clipboard)"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        cd "$(pbpaste)"
    fi
}

clip2png() {
    local filename="${1:-clipboard_$(date +%Y%m%d_%H%M%S).png}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xclip -selection clipboard -t image/png -o > "$filename" 2>/dev/null && echo "Saved: $filename" || echo "No image in clipboard"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        pngpaste "$filename" 2>/dev/null && echo "Saved: $filename" || echo "No image in clipboard (requires: brew install pngpaste)"
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

# --- Ask Claude from shell ---
# Usage: ?? what is the capital of France
_ask_claude() {
    if [[ -z "$*" ]]; then
        echo "Usage: ?? <your question>"
        return 1
    fi
    claude -p --no-session-persistence "$*"
}
alias '??'='_ask_claude'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # node is installed through brew in mac, therefore nvm does not exist
    # nvm installation script does not add the following lines if they already exist
    export NVM_DIR="$HOME/.nvm"
    export PATH="$HOME/.nvm/versions/node/*/bin:$PATH"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
    export WLR_DRM_NO_MODIFIERS=1
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"   # for compiling kernel on mac
    export PATH="$(brew --prefix llvm)/bin/:$PATH"              # for compiling kernel on mac
fi
