alias e="exit"
alias v="nvim"
alias tmux="tmux -f ~/.config/tmux/tmux.conf"
alias lgit="lazygit --use-config-dir ~/.config/lazygit/"
alias ldoc="lazydocker"
alias img="wezterm imgcat"
alias glow="glow -p"
alias tldr='tldr -c'
alias ccn='~/.local/scripts-private/cc-with-session-logging'
alias ccd='~/.local/scripts-private/cc-with-session-logging --dangerously-skip-permissions'

alias dotfiles="cd ~/dotfiles/; nvim .; cd - > /dev/null"

if [[ "$(uname)" == "Darwin" ]]; then
    alias psa="ps -eo lstart,user,pid,%cpu,%mem,stat,command | tail -n +2 | sort -k5,5n -k2,2M -k3,3n -k4,4"
else
    alias psa="ps aux --sort=start_time | grep -v ' \[.*\]$'"
fi

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

if [[ -e ~/.cargo/bin/zoxide ]] && [[ $- == *i* ]]; then
    eval "$(zoxide init zsh)"
    alias cd=z
fi

# --- Ask Claude from shell ---
alias '??'='~/.local/scripts-private/ask-claude'
