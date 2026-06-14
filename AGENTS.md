# Dotfiles

- This is a cross-platform dotfiles repo. Always detect the current OS (macOS vs Linux) and handle platform differences. Use `uname -s` or equivalent checks. macOS uses BSD utilities (date, find, sort) which differ from GNU versions. Never assume GNU tools on macOS.

## Management approach (stow)

- Configs are managed as GNU stow packages symlinked into `$HOME`. If the user requests a configuration change, the change must always be reproducible through this repo (edit the package file, never the live file in `$HOME` directly).
- Before proposing a fix, fully read and understand the existing configuration and the stow-based approach. Do not propose changes that conflict with the stow symlink structure. Never edit profile files directly when they should be recreated through stow.

- SSH config (`~/.ssh/config`) is generated from `~/dotfiles/ssh_config.template` via `envsubst` in `install.sh`. Never edit `~/dotfiles/ssh/.ssh/config` directly — edit the template ask user to re-run `install.sh`.

### Apps that rewrite their own stowed config (symlink breakage)

- Some apps save their config programmatically, and whether that breaks the stow symlink depends on *how* they write: apps that **edit in place** or **resolve the symlink first** (`git config`, `xdg-mime`/`gio` on `mimeapps.list`, `codex mcp add`) write *through* the link — the change lands in the repo and shows in `git status`, harmless. Apps that **`rename()` over the literal path** replace the symlink with a standalone regular file → silent divergence (the change goes to a detached home file, never the repo).
- **Claude Code is the only known offender here**, and even it is *inconsistent*: sometimes its settings writer (`/model`, `/config`, `/effort`, permission grants) renames over the literal path (breaks the symlink), sometimes it resolves the symlink and writes through it (change lands in the repo directly). The break case is auto-healed by `claude/.claude/hooks/heal-settings-symlink.sh`, run from the zsh `precmd` and the top of `install.sh`: it captures the live file **verbatim** into the repo source and re-stows. Capture is verbatim (not `jq -S`/reformatted) on purpose — so the break path and the write-through path leave byte-identical output and the git diff stays down to the value Claude actually changed; reformatting here would make every write-through reappear as a noisy key-reordering diff. See `claude/.claude/TODO.md` for the upstream issue links. So if `~/.claude/settings.json` is ever a regular file instead of a symlink, that is expected and the heal restores it — do not hand-fix.
- The breakage only affects **individual file symlinks** (top-level dotfiles like `~/.gitconfig`, or `--no-folding` packages like `claude`/`codex`). **Folded directory** symlinks (e.g. `~/.config/htop`, `~/.config/nvim`) are immune: a `rename()` of a file inside lands in the folded repo dir, so it stays tracked. When adding a config that its app auto-rewrites, prefer letting stow fold the directory; if it must be an individual file symlink, consider a heal hook like the Claude one.

## install.sh

This script must remain **idempotent**. Running it multiple times should produce the same result without errors or side effects. When making changes, ensure operations are safe to repeat (use `-f` flags, check before adding, avoid duplicate entries, etc.).
