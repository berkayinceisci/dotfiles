bindkey -e
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

setopt NO_BG_NICE

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
  [[ -z "$TMUX" && -z "$TERMIUS" && "$TERM_PROGRAM" != "Apple_Terminal" ]] && printf '\e[?1049l'
  print -Pn "\e]0;%1~\a"
  # Auto-heal the Claude Code settings.json stow symlink: Claude's atomic write
  # replaces it with a plain file, silently diverging from the dotfiles repo.
  # Cheap no-op while the link is intact; captures + re-stows when it is broken.
  # EVERY profile must be tested: the heal script itself covers personal and
  # all moatlab accounts, but a guard naming only ~/.claude never invokes it
  # when just a moatlab link breaks -- that detached file then sits undetected
  # until the next bootstrap.sh run, whose unconditional heal captures a
  # long-stale snapshot over the repo copy (happened 2026-07-23: a 16 Jun
  # onboarding stub clobbered 100 lines of claude-moatlab/settings.json).
  # The glob covers ~/.claude plus every ~/.claude-moatlabN, so a new profile
  # needs no edit here; (N) is null_glob, so no match just skips the loop.
  local cc_settings
  for cc_settings in $HOME/.claude*/settings.json(N); do
    if [[ -f "$cc_settings" && ! -L "$cc_settings" ]]; then
      "$HOME/.claude/hooks/heal-settings-symlink.sh"
      break
    fi
  done
}

preexec() {
  print -Pn "\e]0;$1\a"
}

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# zle counts some emoji sequences wider than the terminal renders them
# (flag pairs: 2 regional indicators = 4 columns for zle but one 2-cell
# glyph on screen; ZWJ/skin-tone/keycap clusters likewise), so whenever the
# line editor draws such text its cursor math drifts and typed text visibly
# shifts. Length is NOT the problem -- plain text of any length wraps and
# redraws fine -- so filter inline suggestions by these width-risky
# characters, not by length. History saving and Ctrl+R search are
# unaffected. Two pieces because atuin init (above) registers its own
# suggestion strategy, which bypasses ZSH_AUTOSUGGEST_HISTORY_IGNORE (that
# var only filters the built-in history strategy).
ZSH_AUTOSUGGEST_HISTORY_IGNORE='*['$'\u200D\uFE0F\u20E3'$'\U0001F1E6'-$'\U0001F1FF'$'\U0001F3FB'-$'\U0001F3FF'']*'
_zsh_autosuggest_strategy_atuin_safe() {
    _zsh_autosuggest_strategy_atuin "$1"
    [[ "$suggestion" == ${~ZSH_AUTOSUGGEST_HISTORY_IGNORE} ]] && suggestion=
}
ZSH_AUTOSUGGEST_STRATEGY=(atuin_safe history)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# case insensitive autocompletion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Za-z}'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"

if [[ "$(uname -s)" != "Darwin" ]]; then
	export PATH="$HOME/.local/go/bin:$PATH"
	export GOROOT="$HOME/.local/go"
fi
export GOPATH="$HOME/go"
export PATH="$HOME/go/bin:$PATH"

. "$HOME/.cargo/env"

# Set LC_OPEN_HOST so remote machines know where to send files back
# LC_ prefix is forwarded by SSH by default (SendEnv/AcceptEnv LC_*)
if [[ -z "${SSH_CONNECTION:-}" ]]; then
    export LC_OPEN_HOST="$(hostname)"
fi

export EDITOR="nvim"
export MANPAGER="less -R --use-color -Dd+r -Du+b"

# Keep NLTK's data cache out of $HOME (it defaults to ~/nltk_data). The dir
# must already exist for nltk to pick it as the download target, hence the
# mkdir. macOS sets no XDG_DATA_HOME, so the fallback carries both platforms.
export NLTK_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nltk_data"
[[ -d "$NLTK_DATA" ]] || mkdir -p "$NLTK_DATA"

# sudo reads passwords from /dev/tty, so it dies with "a terminal is required"
# in any context that has none (Claude Code's Bash tool, i3 keybindings, cron).
# The `sudo` shim in ~/.local/scripts detects that and adds -A, which makes
# sudo collect the password through this helper's GUI dialog instead of
# failing. Inert where sudo needs no password, so passwordless machines are
# unaffected. See scripts/.local/scripts/{sudo,askpass}.
export SUDO_ASKPASS="$HOME/.local/scripts/askpass"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000

export NVM_DIR="$HOME/.nvm"
export PATH="$HOME/.nvm/versions/node/*/bin:$PATH"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export BUN_INSTALL="$HOME/.bun"
export PATH="$HOME/.deno/bin:$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"  # bun completions

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
    export WLR_DRM_NO_MODIFIERS=1
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"   # for compiling kernel on mac
    export PATH="$(brew --prefix llvm)/bin/:$PATH"              # for compiling kernel on mac
fi

source ~/.zsh/functions.zsh
source ~/.zsh/aliases.zsh

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Show the tmux session picker on interactive SSH logins (see
# scripts/.local/scripts/tmux-connect). Pick an existing session or type a name
# to create one -- no keybinding, it just appears.
#
# Every guard earns its place:
#   -o interactive : `ssh host 'cmd'` runs zsh non-interactively, so scp/rsync/
#                    git-over-ssh and every scripted `ssh popos '…'` are untouched.
#                    zsh would not even source this file for them, but the check
#                    documents the intent and costs nothing.
#   $SSH_TTY       : set only when sshd allocated a tty, so this fires on a real
#                    login and never on a local terminal on the machine itself.
#   $TMUX empty    : do not recurse when a pane's shell starts inside tmux.
#   -x <script>    : a machine whose dotfiles predate this script just gets a
#                    normal shell instead of a "command not found" on every login.
#
# Called, not exec'd: tmux-connect execs tmux itself, so detaching returns here
# to a normal prompt rather than dropping the connection. Escape in the picker
# does the same.
#
# This block replaced the old ssht/mosht wrappers -- bare `ssh`, `ssh -Y` and
# `mosh` all reach it now. See the "Connecting to remote machines" note in
# zsh/.zsh/functions.zsh for which transport to pick, and for the one-off
# `ssh -t host 'exec zsh'` that skips the picker if it ever misbehaves (an ssh
# COMMAND is never run through .zshrc, so it bypasses this guard entirely).
if [[ -o interactive ]] && [[ -n "${SSH_TTY:-}" ]] && [[ -z "${TMUX:-}" ]] &&
    [[ -x "$HOME/.local/scripts/tmux-connect" ]]; then
    "$HOME/.local/scripts/tmux-connect"
fi
