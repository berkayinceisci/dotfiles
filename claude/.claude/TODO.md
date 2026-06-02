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
- **Decision: do NOT migrate git rules into `autoMode.soft_deny`.**
  Reason: the default autoMode `allow` rule `Git Push to Working Branch`
  overrides matching `soft_deny`, so a custom `"never push unless asked"`
  soft_deny would be silently neutralized for working-branch pushes.
  Expanding `"$defaults"` to remove that allow rule is brittle (defaults
  change across releases).
- **Mechanism: keep `confirm-git.sh`.** It returns `permissionDecision:
  "ask"` at the permission-system level, which runs *before* the autoMode
  classifier — so the prompt fires regardless of any autoMode allow/deny
  precedence. autoMode has no "ask" tier; the hook is more expressive here
  than autoMode for this case.
- **Future direction**: may relax commit gating while keeping push always
  asked. Today `confirm-git.sh` matches `(commit|push)`. To allow commits
  silently, narrow the regex to just `push`. Push should always remain
  ask-gated regardless of branch.
