# Dotfiles

- This is a cross-platform dotfiles repo. Always detect the current OS (macOS vs Linux) and handle platform differences. Use `uname -s` or equivalent checks. macOS uses BSD utilities (date, find, sort) which differ from GNU versions. Never assume GNU tools on macOS.

## Management approach (stow)

- Configs are managed as GNU stow packages symlinked into `$HOME`. If the user requests a configuration change, the change must always be reproducible through this repo (edit the package file, never the live file in `$HOME` directly).
- Before proposing a fix, fully read and understand the existing configuration and the stow-based approach. Do not propose changes that conflict with the stow symlink structure. Never edit profile files directly when they should be recreated through stow.

- SSH config (`~/.ssh/config`) is generated from `~/dotfiles/ssh_config.template` via `envsubst` in `bootstrap.sh`. Never edit `~/dotfiles/ssh/.ssh/config` directly — edit the template ask user to re-run `bootstrap.sh`.

- **Prefer declarative tracked config over imperative `bootstrap.sh` steps.** Before reaching for `bootstrap.sh` to run a `git config` / `defaults write` / etc. command, check whether the underlying config file is *itself* a tracked dotfile (e.g. `~/.gitconfig` → `git/.gitconfig`, stowed). If it is, express the change *declaratively in that file* — it then travels via stow with no imperative step. Concretely: a `git config filter.X.clean …` command does **not** belong in `bootstrap.sh` here, because `~/.gitconfig` is stowed — add a `[filter "X"]` block to `git/.gitconfig` instead. `bootstrap.sh` is only for state that *cannot* be a tracked file: generated/templated files (ssh config via `envsubst`), or genuinely machine-local/per-clone state. Putting reproducible declarative config behind an imperative `bootstrap.sh` command is a mistake — it adds a re-run dependency and hides the config from the file where one would look for it.

### Apps that rewrite their own stowed config (symlink breakage)

- Some apps save their config programmatically, and whether that breaks the stow symlink depends on *how* they write: apps that **edit in place** or **resolve the symlink first** (`git config`, `xdg-mime`/`gio` on `mimeapps.list`, `codex mcp add`) write *through* the link — the change lands in the repo and shows in `git status`, harmless. Apps that **`rename()` over the literal path** replace the symlink with a standalone regular file → silent divergence (the change goes to a detached home file, never the repo).
- **Claude Code is the only known offender here**, and even it is *inconsistent*: sometimes its settings writer (`/model`, `/config`, `/effort`, permission grants) renames over the literal path (breaks the symlink), sometimes it resolves the symlink and writes through it (change lands in the repo directly). The break case is auto-healed by `claude/.claude/hooks/heal-settings-symlink.sh`, run from the zsh `precmd` and the top of `bootstrap.sh`: it captures the live file **verbatim** into the repo source and re-stows. Capture is verbatim (not `jq -S`/reformatted) on purpose — so the break path and the write-through path leave byte-identical output and the git diff stays down to the value Claude actually changed; reformatting here would make every write-through reappear as a noisy key-reordering diff. See `claude/.claude/TODO.md` for the upstream issue links. So if `~/.claude/settings.json` is ever a regular file instead of a symlink, that is expected and the heal restores it — do not hand-fix.
- The breakage only affects **individual file symlinks** (top-level dotfiles like `~/.gitconfig`, or `--no-folding` packages like `claude`/`codex`). **Folded directory** symlinks (e.g. `~/.config/htop`, `~/.config/nvim`) are immune: a `rename()` of a file inside lands in the folded repo dir, so it stays tracked. When adding a config that its app auto-rewrites, prefer letting stow fold the directory; if it must be an individual file symlink, consider a heal hook like the Claude one.

## Coding-agents config infrastructure

This repo is the source of truth for three coding-agent harnesses (Claude Code, Codex, OpenCode), wired so a single canonical instruction file and one skills set serve all three. Most of the wiring is created by `bootstrap.sh`; see its `--- Shared agent instructions ---` / `Shared skills` comment blocks for the authoritative per-harness rationale.

- **Canonical shared instructions: `~/.agents/core.md`** — stowed from the `agents` package (`~/.agents` is a *folded* dir symlink → `dotfiles/agents/.agents/`). It is harness-agnostic: edit it for any rule that should apply to all agents. Each harness consumes it differently:
  - **Claude Code** — `~/.claude/CLAUDE.md` (a committed symlink → `dotfiles/claude/.claude/CLAUDE.md`) imports it on its first line via `@~/.agents/core.md`, then adds Claude-only rules below. No `bootstrap.sh` step needed (the import is checked in).
  - **Codex** — `~/.codex/AGENTS.md` is a symlink → `~/.agents/core.md` (Codex has no `@import`, so it links the file directly). Created by `bootstrap.sh`.
  - **OpenCode** — `~/.config/opencode/AGENTS.md` is a symlink → `~/.agents/core.md`. Created by `bootstrap.sh`.
- **Shared skills: `~/.agents/skills/`** (same `agents` package) is the single source of truth. Codex and OpenCode scan it natively as a home-scope skills path, so they need **no** bridge. Claude Code does **not** read `~/.agents/skills`, so it alone is bridged with a whole-dir symlink `~/.claude/skills → ~/.agents/skills` (created by `bootstrap.sh`) — this auto-exposes any new skill with no re-run. Do **not** symlink skills into the Codex/OpenCode dirs (for OpenCode that double-registers every skill).
- **Shared hooks: `~/.agents/hooks/`** — used by both Claude Code and Codex.
- **Repo-level project instructions: `CLAUDE.md` → `AGENTS.md`** — inside this repo, `CLAUDE.md` is a symlink to `AGENTS.md` (this file). Edit `AGENTS.md`; both names resolve to it. Note `grep -r` does not follow the symlink, so a search may list only `AGENTS.md` even though both names apply.

### Sibling repos that invoke `bootstrap.sh`

Two separate repos (each with its own remote) call this repo's `bootstrap.sh` and must be updated in lockstep if its path or name changes:

- `~/installation` (`github.com/berkayinceisci/installation`) — package installer; `setup.sh` runs `"$DOTFILES_DIR/bootstrap.sh"` *after* installing packages. **OS package installation (pacman/cargo/brew/npm) lives here, not in dotfiles** — which is why this repo's entry point is `bootstrap.sh`, not `install.sh`.
- `~/cloudlab` (`github.com/berkayinceisci/cloudlab`) — Cloudlab provisioning; `dotfiles.sh` clones this repo and runs `./bootstrap.sh`.
- This repo's own remote is `github.com/inceisciberkay/dotfiles` — note the **different** GitHub username from the other two.

## bootstrap.sh

This script must remain **idempotent**. Running it multiple times should produce the same result without errors or side effects. When making changes, ensure operations are safe to repeat (use `-f` flags, check before adding, avoid duplicate entries, etc.).
