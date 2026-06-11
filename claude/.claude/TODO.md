# Claude Code TODOs

## Vim Mode Configuration
- Waiting for .vimrc-like configuration support to remap Ctrl+Backspace to delete previous word
- Currently Ctrl+W works but conflicts with tmux vim-aware pane switching (bind-key -n C-w)
- Feature request to be submitted via /feedback

## Status Line
- Check if Claude Code allows disabling/styling the builtin git changes line

## Missing Plugins
- shellcheck

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
