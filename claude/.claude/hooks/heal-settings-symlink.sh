#!/usr/bin/env bash
# Heal the Claude Code settings.json stow symlink(s).
#
# Claude Code saves settings.json with an atomic write (mkstemp + rename),
# which replaces the stow symlink at ~/.claude/settings.json with a plain
# regular file -- silently diverging the live config from the dotfiles repo.
# This script detects that case, folds the live change back into the repo
# source (captured verbatim -- see the VERBATIM note below for why no
# reformatting), and re-stows so the path becomes the tracked symlink again.
#
# It covers BOTH Claude profiles managed by this repo:
#   - personal: ~/.claude/settings.json          -> claude package
#   - business: ~/.claude-moatlab/settings.json  -> claude-moatlab package
# (the business profile is the CLAUDE_CONFIG_DIR=$HOME/.claude-moatlab account;
# its settings are an INDEPENDENT copy, so each heals into its own repo source.)
#
# It is intentionally lifecycle-independent: invoked from the zsh `precmd`
# (runs before every shell prompt; a near-instant no-op while the links are
# intact) and from the top of install.sh (so a re-stow never clobbers an
# uncaptured change). Safe to run anytime; idempotent. Cross-platform
# (Linux + macOS): relies only on jq/stow/git from PATH and GNU-free shell.

set -euo pipefail

# Make jq / stow / git findable even when invoked from a minimal-PATH context
# (e.g. a launchd/cron shell). Homebrew paths cover Apple Silicon and Intel.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

heal_rc=0

# heal_one <live-path> <repo-src> <stow-args...>
# Capture a broken (rename-detached) settings.json back into its repo source and
# re-stow. Called outside any tested context so `set -e` stays active inside it:
# real cp/stow failures abort loudly; only the soft "invalid JSON" case is
# tolerated (records heal_rc=1 and moves on so the other profile still heals).
heal_one() {
	local live="$1" src="$2"
	shift 2 # remaining args are the stow invocation for this package

	# Nothing to manage if this machine has no dotfiles source for the file.
	[[ -f "$src" ]] || return 0

	# Already the proper symlink, or absent entirely -> nothing to do. This is
	# the common path and stays cheap (two stat() calls, no subprocess).
	if [[ -L "$live" || ! -e "$live" ]]; then
		return 0
	fi

	# $live is a regular file: Claude's atomic write broke the symlink. Capture
	# the live content into the repo source before restoring the link.
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
	if command -v jq >/dev/null 2>&1 && ! jq -e . "$live" >/dev/null 2>&1; then
		echo "heal-settings-symlink: $live is not valid JSON — leaving it in place, not capturing" >&2
		heal_rc=1
		return 0
	fi
	cp -f "$live" "$src"

	# Restore the stow symlink. Remove the captured regular file first so stow
	# re-links it (the stow args mirror what install.sh uses for the package).
	rm -f "$live"
	(
		cd "$DOTFILES_DIR" && stow "$@"
	)

	echo "↻ healed $live symlink — Claude Code's change is now in the repo working tree. Review with: git -C \"$DOTFILES_DIR\" diff ${src#"$DOTFILES_DIR"/}"
}

heal_one "$HOME/.claude/settings.json" "$DOTFILES_DIR/claude/.claude/settings.json" \
	--no-folding --ignore='cc-session\.md' --ignore='history\.jsonl' \
	--ignore='cache' --ignore='my-session-logs' claude

heal_one "$HOME/.claude-moatlab/settings.json" "$DOTFILES_DIR/claude-moatlab/.claude-moatlab/settings.json" \
	--no-folding claude-moatlab

exit "$heal_rc"
