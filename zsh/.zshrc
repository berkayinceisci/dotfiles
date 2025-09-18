HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
alias history="history 1"
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^H' backward-kill-word # ctrl-backspace
setopt interactive_comments

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# case insensitive autocompletion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/go/bin:$PATH"
export GOROOT="$HOME/.local/go"
export GOPATH="$HOME/go"
export PATH="$HOME/go/bin:$PATH"

. "$HOME/.cargo/env"
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow)"

export MANPAGER="less -R --use-color -Dd+r -Du+b"

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

alias v="nvim"
alias tmux="tmux -f ~/.config/tmux/tmux.conf"
alias lgit="lazygit --use-config-dir ~/.config/lazygit/"
alias ldoc="lazydocker"
alias img="wezterm imgcat"
alias glow="glow -p"
alias tldr='tldr -c'

alias dotfiles="cd ~/dotfiles/; nvim .; cd - > /dev/null"
alias vpn="/opt/pulsesecure/bin/pulseUI"

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
fi

bcd() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cd "$(xclip -o -selection clipboard)"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        cd "$(pbpaste)"
    fi
}

if command -v fzf 2>&1 >/dev/null; then
    FZF_ALT_C_COMMAND=
    FZF_CTRL_T_COMMAND=
    source <(fzf --zsh)
    alias history="history 1 | fzf --tac"
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # node is installed through brew in mac, therefore nvm does not exist
    # nvm installation script does not add the following lines if they already exist
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
    export WLR_DRM_NO_MODIFIERS=1
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"   # for compiling kernel on mac
    export PATH="$(brew --prefix llvm)/bin/:$PATH"              # for compiling kernel on mac
fi
