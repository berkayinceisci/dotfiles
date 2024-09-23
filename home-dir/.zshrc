source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# case insensitive autocompletion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

alias tmux="tmux -f ~/.config/tmux/tmux.conf"
alias lazygit="lazygit --use-config-dir ~/.config/lazygit/"
alias lgit="lazygit --use-config-dir ~/.config/lazygit/"
alias ldoc="lazydocker"

alias zshconfig="cd ~; nvim ~/.zshrc; cd - > /dev/null"
alias dotfiles="cd ~/.config/; nvim ~/.config/; cd - > /dev/null"

if [[ ":$PATH:" == *":$HOME/.cargo/bin:"* && -e ~/.cargo/bin/eza ]]; then
    alias ls="eza"
    alias ll="eza -l"
    alias la="eza -a"
    alias lla="eza -la"
else
    alias ll="ls -l"
    alias la="ls -a"
    alias lla="ls -la"
fi

bcd() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cd $(xclip -o -selection clipboard)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        cd $(pbpaste)
    fi
}

# node is installed through brew in mac, therefore nvm does not exist
# nvm installation script does not add the following lines if they already exist
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
fi

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/go/bin
