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

## Auto-mode soft_deny migration
- `autoMode.soft_deny` in `settings.json` is currently just `["$defaults"]`
- Promote the two finalized rules from `auto-mode/soft_deny.md` (no `git commit`
  / no `git push` without explicit ask) when ready
- After promotion, consider retiring `confirm-git.sh` — its coverage is narrower
  (only plain `git commit`/`git push`, missing `--amend`, `rebase -i`, squash/fixup)
