HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
alias history="history 1"
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# case insensitive autocompletion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

export PATH=$PATH:~/.cargo/bin/

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

alias tmux="tmux -f ~/.config/tmux/tmux.conf"
alias lazygit="lazygit --use-config-dir ~/.config/lazygit/"
alias lgit="lazygit --use-config-dir ~/.config/lazygit/"
alias ldoc="lazydocker"
alias img="wezterm imgcat"
alias glow="glow -p"
alias rgf='rg --files | rg'

alias dotfiles="cd ~/repos/dotfiles/; nvim .; cd - > /dev/null"

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
    alias cat="bat"
fi

if [[ -e ~/.cargo/bin/zoxide ]]; then
    eval "$(zoxide init zsh)"
    alias cd="z"
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

    export WLR_DRM_NO_MODIFIERS=1
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"   # for compiling kernel on mac
    export PATH="$(brew --prefix llvm)/bin/:$PATH"              # for compiling kernel on mac
fi

source "$HOME/.export_api_keys.sh"
