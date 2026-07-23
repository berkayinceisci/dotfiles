alias e="exit"
alias v="nvim"
alias tmux="tmux -f ~/.config/tmux/tmux.conf"
alias t="tmux"
alias lgit="lazygit --use-config-dir ~/.config/lazygit/"
alias ldoc="lazydocker"
alias glow="glow -p"
alias tldr='tldr -c'
# Session logging is a Claude Code `Stop` hook now (~/.agents/hooks/log-session.sh),
# not a launch wrapper — it runs no matter how claude starts (incl. the tmux
# resurrect plugin's bare `claude --resume`), so these call the claude binary directly.
# Personal account. `env -u` REMOVES CLAUDE_CONFIG_DIR rather than leaving it to
# chance: bare `claude` silently picks up an inherited CLAUDE_CONFIG_DIR, and the
# tmux server's global environment is inherited from whatever started it -- so a
# server first spawned from inside a moatlab session (e.g. an agent running
# `tmux new-session` when no server was up) makes every pane's `ccn` open the
# business account.
# Do NOT "fix" this by pinning CLAUDE_CONFIG_DIR=$HOME/.claude instead: the
# default profile's config/state file is the home-root ~/.claude.json, but
# setting the var moves that lookup to $CLAUDE_CONFIG_DIR/.claude.json
# (~/.claude/.claude.json), which is empty -> claude sees a fresh install and
# prompts for login. Only the *absence* of the var reproduces default behavior.
alias ccn='env -u CLAUDE_CONFIG_DIR claude'
alias ccd='env -u CLAUDE_CONFIG_DIR claude --dangerously-skip-permissions'
# Business (moatlab) account: separate CLAUDE_CONFIG_DIR isolates creds/projects/settings.
# `claude` is a real command (not an alias), so it IS reached after the env-var assignment.
alias ccnm='CLAUDE_CONFIG_DIR=$HOME/.claude-moatlab claude'
alias ccdm='CLAUDE_CONFIG_DIR=$HOME/.claude-moatlab claude --dangerously-skip-permissions'
alias cxn='~/.local/scripts-private/codex-with-untracked-state'
alias cxd='~/.local/scripts-private/codex-with-untracked-state --dangerously-bypass-approvals-and-sandbox'
alias ocn='~/.local/scripts-private/opencode-with-session-logging'

alias dotfiles="cd ~/dotfiles/; nvim .; cd - > /dev/null"
alias scp="scp -p"

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

if [[ "$(uname)" == "Darwin" ]]; then
    psa() { ps -eo lstart,user,pid,%cpu,%mem,stat,command | tail -n +2 | sort -k5,5n -k2,2M -k3,3n -k4,4 | grcat conf.ps; }
else
    psa() { ps aux --sort=start_time | grep -v ' \[.*\]$' | grcat conf.ps; }
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
