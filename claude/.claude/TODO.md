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
