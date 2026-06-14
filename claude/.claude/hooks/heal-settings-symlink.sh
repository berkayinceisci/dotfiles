#!/usr/bin/env bash
# Heal the Claude Code settings.json stow symlink.
#
# Claude Code saves settings.json with an atomic write (mkstemp + rename),
# which replaces the stow symlink at ~/.claude/settings.json with a plain
# regular file -- silently diverging the live config from the dotfiles repo.
# This script detects that case, folds the live change back into the repo
# source (normalized with `jq -S` so the git diff shows only the semantic
# change, not Claude's cosmetic key reordering), and re-stows so the path
# becomes the tracked symlink again.
#
# It is intentionally lifecycle-independent: invoked from the zsh `precmd`
# (runs before every shell prompt; a near-instant no-op while the link is
# intact) and from the top of install.sh (so a re-stow never clobbers an
# uncaptured change). Safe to run anytime; idempotent. Cross-platform
# (Linux + macOS): relies only on jq/stow/git from PATH and GNU-free shell.

set -euo pipefail

# Make jq / stow / git findable even when invoked from a minimal-PATH context
# (e.g. a launchd/cron shell). Homebrew paths cover Apple Silicon and Intel.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
LIVE="$HOME/.claude/settings.json"
SRC="$DOTFILES_DIR/claude/.claude/settings.json"

# Nothing to manage if this machine has no dotfiles source for the file.
[[ -f "$SRC" ]] || exit 0

# Already the proper symlink, or absent entirely -> nothing to do. This is the
# common path and stays cheap (two stat() calls, no subprocess).
if [[ -L "$LIVE" || ! -e "$LIVE" ]]; then
	exit 0
fi

# $LIVE is a regular file: Claude's atomic write broke the symlink. Capture the
# live content into the repo source before restoring the link.
#
# Capture VERBATIM (no jq -S / no reformatting). Claude Code is inconsistent
# about how it saves: sometimes it renames over the literal path (breaks the
# symlink -> this heal runs), sometimes it resolves the symlink and writes
# THROUGH it (the change lands in the repo directly and this heal never runs).
# If we reformatted here (e.g. sorted keys with `jq -S`), the two paths would
# disagree: the write-through path keeps Claude's native key order while the
# heal path would re-sort, so every write-through would reappear as a noisy
# key-reordering diff. Mirroring Claude's own bytes makes both paths identical,
# leaving the git diff down to just the value Claude actually changed.
if command -v jq >/dev/null 2>&1 && ! jq -e . "$LIVE" >/dev/null 2>&1; then
	echo "heal-settings-symlink: ~/.claude/settings.json is not valid JSON — leaving it in place, not capturing" >&2
	exit 1
fi
cp -f "$LIVE" "$SRC"

# Restore the stow symlink. Remove the captured regular file first so stow
# re-links it (matches the flags install.sh uses for the claude package).
rm -f "$LIVE"
(
	cd "$DOTFILES_DIR" && stow --no-folding \
		--ignore='cc-session\.md' --ignore='history\.jsonl' \
		--ignore='cache' --ignore='my-session-logs' claude
)

echo "↻ healed ~/.claude/settings.json symlink — Claude Code's change is now in the repo working tree. Review with: git -C \"$DOTFILES_DIR\" diff claude/.claude/settings.json"
