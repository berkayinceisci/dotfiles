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

bindkey '^[[1;5D' backward-word # ctrl-leftarrow
bindkey '^[[1;5C' forward-word  # ctrl-rightarrow
bindkey '^H' backward-kill-word # ctrl-backspace
setopt interactive_comments

if command -v fzf >/dev/null 2>&1; then
    FZF_ALT_C_COMMAND=
    FZF_CTRL_T_COMMAND=
    source <(fzf --zsh)
fi

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow)"

precmd() {
  # Reset terminal modes that may leak from SSH/vim/tmux
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?25h\e[?1l'
  # Exit alternate screen buffer only outside tmux (causes redraw issues inside tmux)
  [[ -z "$TMUX" ]] && printf '\e[?1049l'
  print -Pn "\e]0;%1~\a"
}

preexec() {
  print -Pn "\e]0;$1\a"
}

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

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

export EDITOR="nvim"
export MANPAGER="less -R --use-color -Dd+r -Du+b"

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

source ~/.zsh/functions.zsh
source ~/.zsh/aliases.zsh
