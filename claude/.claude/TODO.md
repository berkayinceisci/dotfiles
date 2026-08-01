# Claude Code TODOs

## CLAUDE.md addendum: import-split still worth it?
- Monitor workflow has been migrated to core.md (harness-neutral); the Claude
  addendum is now just Subagent Discipline. If that section also migrates or
  gets dropped, replace the @import + addendum split with a plain symlink
  like Codex/OpenCode.

## Ctrl+Backspace word-delete (RESOLVED 2026-07-31)
- WezTerm maps the physical Ctrl+Backspace key to ESC DEL (Alt+Backspace) in
  `wezterm/.config/wezterm/wezterm.lua`. Claude Code handles that sequence as
  word-delete natively, both directly and through tmux, so this no longer
  depends on .vimrc-like remapping support or the conflicting Ctrl+W binding.

### Ctrl+[ doesn't enter vim normal mode on local claude — CC enhanced-key encoding + wezterm env-detection (RESOLVED 2026-07-15, v2.1.211)
- **Symptom:** on this Linux box, local Claude Code vim mode `ctrl+[` doesn't
  switch insert→normal. Plain `Escape` works. It works on the MacBook AND over
  SSH from this same wezterm into another host (Manjaro) — **only *local* claude
  on this machine breaks**, which is the key clue: same terminal, different
  process environment.
- **Root cause (confirmed by bisection, all in local wezterm):**
  - `command cat -v` + `ctrl+[` → bare `ESC` (0x1b). Baseline byte is correct:
    US layout active, `[`=0x5b, Ctrl→0x1b. Layout is NOT the cause (an earlier
    Turkish-layout guess was WRONG — `us,tr` exists but US was active).
  - `nvim` insert-mode `ctrl+[` → returns to normal fine. wezterm delivers Esc
    to TUIs correctly, so wezterm is NOT the cause.
  - Claude Code **detects wezterm from env vars** (`TERM_PROGRAM=WezTerm`, plus
    `WEZTERM_*`) and turns on enhanced key reporting. Under that mode wezterm
    re-encodes `ctrl+[` as a CSI sequence (`modifyOtherKeys`/CSI-u, e.g.
    `CSI 27;5;91~` or `CSI 91;5u`). nvim decodes that back to Esc; **CC's vim
    mode only recognizes a literal `ESC`**, so it misses it.
  - **`ssh` forwards only `TERM`, not `TERM_PROGRAM`/`WEZTERM_*`.** So every
    ssh'd claude sees a "plain" terminal, never enables enhanced mode, gets a
    bare Esc → works. That is the entire local-vs-remote asymmetry.
  - **Proven:** `env -u TERM_PROGRAM -u TERM_PROGRAM_VERSION -u WEZTERM_… claude`
    makes local `ctrl+[` work. Narrowed to `TERM_PROGRAM` as the trigger var.
- **Key trade-off (why the env-strip is NOT the fix):** the enhanced keyboard
  mode CC turns on for wezterm is two-sided — it's what makes **Shift+Enter**
  (newline) distinguishable AND what re-encodes `ctrl+[`. Enhanced on → Shift+Enter
  works, `ctrl+[` broken; enhanced off (env-strip) → `ctrl+[` works, Shift+Enter
  breaks. Confirmed empirically (a stripped session lost Shift+Enter). So the
  env-strip alias just trades one for the other — it was reverted.
- **FIX (confirmed working 2026-07-15, keeps BOTH):** force `ctrl+[` to emit a
  bare ESC at the wezterm layer, before the enhanced-encoding step —
  `{ key = "[", mods = "CTRL", action = act.SendString("\x1b") }` in
  `wezterm/.config/wezterm/wezterm.lua`. wezterm key assignments run ahead of key
  encoding, so CC receives a literal ESC (vim escape works) while Shift+Enter and
  the other enhanced keys stay on. Standard ASCII, no-op in other apps.
  Cross-platform for free — wezterm.lua is stowed on the Mac too. Verified: ctrl+[
  AND Shift+Enter both work.
- **Fallback (unused):** `"vimInsertModeRemaps": { "jk": "<Esc>" }` in
  settings.json (v2.1.208+) — keeps enhanced mode, escapes via `jk` instead of
  `ctrl+[`.
- **Upstream (the real fix):** CC vim mode should map enhanced-mode Ctrl+`[`
  (`CSI 27;5;91~` / `CSI 91;5u`) to Esc like nvim does. Related:
  https://github.com/anthropics/claude-code/issues/53039 — broader insert-exit
  remapping request, now closed as not planned. A specific
  `ctrl+[`-under-modifyOtherKeys bug could still be filed.

## Status Line
- Check if Claude Code allows disabling/styling the builtin git changes line

## Missing Plugins
- shellcheck

## settings.json symlink breakage (stow)
- **Problem:** Claude Code's settings writer (in-app `/model`, `/config`,
  `/effort`, permission grants) saves `~/.claude/settings.json` in two
  *inconsistent* ways: sometimes atomic temp-file + `rename()` over the
  *literal* path (replaces the stow symlink with a standalone regular file →
  silent divergence, change stuck in the detached home file), and sometimes it
  resolves the symlink and writes *through* it (change lands directly in the
  repo, shows in `git status`). Observed both within minutes on v2.1.177.
- **Verified scope (2026-06-13):** Claude Code is the *only* offender among the
  apps writing our stowed configs. `git config --global`, `xdg-mime`/`gio`
  (mimeapps.list), and `codex mcp add` all resolve the symlink first (or edit
  in place), so they write through and stay tracked. Confirmed empirically with
  isolated symlink tests. No generalized healer needed — Claude-specific.
- **Mitigation in place:** `claude/.claude/hooks/heal-settings-symlink.sh`,
  invoked from the zsh `precmd` (every prompt; cheap no-op while link intact)
  and from the top of `bootstrap.sh`. On breakage it captures the live file
  **verbatim** into the repo source and re-stows to restore the link, leaving
  the change in the git working tree for review.
- **Why verbatim, not `jq -S`:** an earlier version sorted keys with `jq -S`
  for a stable baseline, but that backfired because of the write-through path:
  the heal only runs on the break path, so write-throughs kept Claude's native
  key order while heals re-sorted — every write-through then showed up as a
  noisy full-file key-reordering diff with *zero* semantic change. Mirroring
  Claude's own bytes makes both paths byte-identical, so the diff is just the
  changed value. Tradeoff: the baseline now tracks Claude's serialization, so a
  future CC version that changes key order would cause a one-time reorder diff.
- **Reorder churn now neutralized at the git layer (the real fix):** a git
  **clean filter** sorts keys before git stores/diffs the file — `[filter
  "jqsort"]` in `git/.gitconfig` (`clean = jq -S . 2>/dev/null || cat`,
  `smudge = cat`), gated by `claude/.claude/settings.json filter=jqsort` in the
  repo's `.gitattributes`. This supersedes the verbatim-vs-`jq -S` reasoning
  above as the *churn* defense: it runs at the git boundary, so it catches
  **both** write paths (write-through and break+heal) uniformly, whereas a
  heal-internal sort only ever sees the break path. So the heal still captures
  **verbatim** (don't add `jq -S` to it — normalization belongs in the filter,
  not the heal), and the two compose: heal = bytes reach the repo; jqsort = git
  ignores their order. Filter definition lives in the tracked `git/.gitconfig`
  (travels via stow), not an `bootstrap.sh` `git config` step. One-time cost: the
  first commit after adding the filter renormalizes the existing unsorted
  baseline (a single ~all-lines reorder diff vs the old `HEAD`); every commit
  after is clean. Addresses the #61465 churn locally.
- **Known limitation — `jqsort` cleans `git diff`, NOT `git status` (2026-06-15):**
  the clean filter runs at the git boundary (diff/add/commit), but the
  working-tree bytes are never rewritten (`smudge = cat`). So after Claude
  writes *through* the symlink with its native bytes (keys reordered, non-ASCII
  escaped as `\uXXXX`), `git status` shows `settings.json` as ` M` even though
  `git diff` is **empty** and a commit would be a no-op — git flags it because
  the on-disk bytes differ from the `jq -S` blob in the index, while the filter
  makes them *compare* equal. Verified: `jq -S working` is byte-identical to the
  HEAD blob; the only raw diff is `—` vs literal `—`. **Harmless** — nothing
  to commit; `git add` clears it (stages an identical-to-HEAD blob). This is
  inherent to clean filters and cannot be fixed at the git-attributes layer.
- **Rejected fix for the residual ` M` (2026-06-15):** make the heal hook also
  canonicalize the file *on disk* to the exact `jq -S` form (so worktree bytes ==
  index blob → `git status` clean too), triggered from `precmd` gated on a
  stamp-file `[[ sj -nt stamp ]]` test (subprocess-free in steady state, shared
  across shells). Prototyped and verified working (cosmetic writes end clean;
  real changes stay visible as unstaged; idempotent). **Not adopted** — judged
  too much machinery (on-disk rewrite + stamp file + precmd gate) for a purely
  cosmetic status flag that has no diff and commits nothing. If the ` M` noise
  ever actually bites, this is the known-good approach to revive.
- **Upstream tracking (consider commenting, not a new issue — would dup):**
  - #67208 (open, bug, has repro) — *root cause*: settings writer mis-resolves
    relative symlinked settings.json (manual readlink + logical-dirname join
    instead of `fs.realpathSync`). Their symptom is ENOENT when `~/.claude` is
    *also* a symlink; ours is silent replacement when `~/.claude` is a real
    dir. Same bug. https://github.com/anthropics/claude-code/issues/67208
  - #28376 (closed, not_planned + stale — *not actually fixed*) — Write/Edit
    tools replace symlinks with regular files, breaking dotfiles. Same class,
    tool path. https://github.com/anthropics/claude-code/issues/28376
  - #61465 (open, bug) — the cosmetic key-reordering on Claude's writes (the
    churn the `jq -S` baseline neutralizes for us).
    https://github.com/anthropics/claude-code/issues/61465
  - #67853 (open) — XDG Base Directory support (a clean fix would sidestep the
    whole `~/.claude` real-dir layout). https://github.com/anthropics/claude-code/issues/67853
  - **Action:** add our silent-replacement variant to #67208 as corroborating
    evidence (severity: silent data loss > loud ENOENT). `gh` not installed
    locally — install or draft+paste.

## Background Task Notifications
- `TaskOutput` (blocking wait) does NOT suppress task-notification delivery
- Every background task always fires both: TaskOutput result + async notification
- For long monitoring loops (50+ background tasks), this causes a flood of stale
  notifications that waste context window, cost tokens, and block the user
- Need: a way to suppress/acknowledge notifications for tasks already consumed
  via `TaskOutput`, or a `TaskStop`-like dismiss for completed tasks

## Git commit/push policy
- **Decision (2026-06-11, supersedes the earlier "keep confirm-git.sh"):**
  `confirm-git.sh` is removed; git gating now relies on auto mode plus a
  `soft_deny` prose rule ("git commit and git push require the user's
  explicit request"). Rationale: standardize on auto mode as the single
  enforcement layer; deterministic hooks only where auto mode can't reach
  (cross-harness consistency — Codex/OpenCode never had a git gate either).
- **Known accepted gap:** the default autoMode `allow` rule `Git Push to
  Working Branch` overrides matching `soft_deny`, so working-branch pushes
  are effectively ungated (instruction-level norms only). Commits likewise
  rely on the model honoring the rule, not a guaranteed prompt.
- **If the gap ever bites:** restore the hook narrowed to `push` only
  (`git show 1cb02ac:claude/.claude/hooks/confirm-git.sh`, change regex
  `(commit|push)` → `push`) — `permissionDecision: "ask"` runs before the
  autoMode classifier, so it prompts regardless of allow-rule precedence.
