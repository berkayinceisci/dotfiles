# TODO

## Remote sudo password prompts

Not urgent: every remote machine in the workflow currently grants passwordless
sudo (popos and hds01 both report `(ALL) NOPASSWD: ALL`), so the askpass helper
never runs there. Revisit if that changes.

- [ ] Refresh a stale `DISPLAY` from tmux at prompt time in
  [askpass](scripts/.local/scripts/askpass), line 80. A process that outlives
  the `ssh -X` connection it was started under keeps a `DISPLAY` pointing at a
  destroyed X11 proxy, so a dialog raised from a reattached tmux session cannot
  draw. Claude Code's environment cannot be repaired from outside the way
  [latex.lua](nvim/.config/nvim/lua/plugins/latex.lua), lines 20-32, repairs
  nvim's own — but it does not need to be: sudo spawns the helper fresh on each
  prompt and passes the caller's environment through, so the helper can re-read
  the value itself. When `$TMUX` is set and `DISPLAY` is either empty or fails
  `xdpyinfo -display`, take the value from `tmux show-environment DISPLAY`,
  matching only the `DISPLAY=value` form so a `-DISPLAY` unset marker left by a
  mosh attach cannot clobber a good value — the rule `refresh-env`
  ([functions.zsh](zsh/.zsh/functions.zsh), line 108) already follows. Guard the
  probe with `command -v xdpyinfo`, which is not installed everywhere, and fall
  back to the current non-empty check. `XAUTHORITY` needs no equivalent
  handling: ssh forwarding writes the cookie to the default `~/.Xauthority`, and
  tmux reports `-XAUTHORITY` on popos while X clients still connect. Verify
  against a tmux session reattached over a fresh `ssh -X` connection (stale
  DISPLAY replaced), a session created under mosh with no DISPLAY at all (clean
  error, no hang), and a host with no `xdpyinfo` installed.

## lazygit word-wise editing (recheck on every lazygit update)

Ctrl+Backspace (delete previous word) and Ctrl+Left / Ctrl+Right (move by word)
do nothing useful in lazygit's text inputs — commit message, filter, prompts —
unless the keys are rewritten before they arrive. Those inputs are gocui's, and
gocui/tcell fold both `^H` and DEL into a plain one-character Backspace, so the
question is only which *other* sequence its editor decodes as a word operation.
That answer changed in lazygit 0.64 and now differs by platform. Measured on
2026-09-07 against each machine's own binary, by opening the filter prompt and
injecting raw bytes with `tmux send-keys -H` (which bypasses tmux's own
bindings, so it tests lazygit directly):

|sequence|0.54.2 linux|0.64.1 linux|0.65.0 linux|0.65.0 darwin|
|-|-|-|-|-|
|`ESC b` / `ESC f` (`1b 62` / `1b 66`)|word motion|word motion|word motion|word motion|
|`\e[1;5D` — raw Ctrl+Left|ignored|word motion|word motion|ignored|
|`\e[127;5u` — Ctrl+Backspace, CSI-u|word delete|word delete|word delete|ignored|
|`ESC DEL` (`1b 7f`) — Alt+Backspace|word delete|ignored|ignored|word delete|
|`Ctrl+W` (`17`)|word delete|word delete|word delete|word delete|

Two things make this awkward. First, **neither generation accepts both of the
defaults that already flow**: the old layer takes `ESC DEL` but ignores
`\e[1;5D`, the new one is the exact opposite. So each generation needs exactly
one translation, and we carry both only because the fleet straddles both.
Second, the darwin/linux divergence is **not** dependency drift and will not be
fixed by rebuilding — `go version -m` on the two binaries reports identical
module hashes, with only `GOOS` differing:

    mod github.com/jesseduffield/lazygit v0.65.0 h1:90rrbweN10rlAv7hKIsrnsL0rpdabKDf5Eas/94JfDQ=
    dep github.com/gdamore/tcell/v3      v3.4.2  h1:gGW+6z2Bz5Wl2mNwFlm9+eRmg2JQrWcKjSkL1LRfpNU=

It is platform-conditional code inside lazygit or tcell v3.4.2, so it needs an
upstream change. TERM is not the lever: darwin fails identically under
`screen-256color`, `tmux-256color` and `xterm-256color`, including the one that
does carry `kLFT5`. `Ctrl+W` is the one sequence every build accepts and would
need no platform split at all, but it is deliberately unused — lazygit binds
`<c-w>` globally to `toggleWhitespaceInDiffView` and none of the layers below
can tell whether a text input is focused, so Ctrl+Backspace pressed outside one
would silently flip that setting. Everything actually sent is inert outside a
text input on both platforms.

The rewrite has to happen once per layer that can see the foreground process,
because each sees only one hop — wezterm sees `tmux`/`ssh`/`nvim` when those are
in the way, and tmux sees `nvim`. All of the following exists solely for this:

- [wezterm.lua](wezterm/.config/wezterm/wezterm.lua), lines 157 and 165 (the
  `lazygit_word_delete` platform split and the `lazygit_key` helper) and lines
  296, 301-302 (the three key assignments) — covers a pane running lazygit
  directly, with no tmux and no nvim.
- [tmux.conf](tmux/.config/tmux/tmux.conf), lines 139-148 (the `uname` branch
  around `C-h` and `M-BSpace`) and lines 156-157 (the arrow gates).
- [lazygit.lua](nvim/.config/nvim/lua/plugins/lazygit.lua), lines 76-80 — covers
  lazygit inside lazygit.nvim's floating terminal, which neither layer above can
  see because the process is `nvim`.

- [ ] After each lazygit update, re-run the probe on **both** a Linux box and the
  Mac, then delete whatever converged. To probe: start `lazygit` in a scratch
  tmux session, wait until `Keybindings: ?` appears in `capture-pane` output,
  press `/`, confirm the `Filter:` prompt is actually open *before* typing
  (stray letters go to the files panel, where `e` opens the editor), type
  `alpha beta gamma`, then send each sequence above with `tmux send-keys -H` and
  read the filter line back with `capture-pane -p`. Also record
  `go version -m "$(command -v lazygit)"` so a future divergence can again be
  told apart from dependency drift. Collapse in this order:
  - darwin decodes `\e[1;5D` → drop all six arrow translations (tmux 156-157,
    nvim 79-80, wezterm 301-302); linux is already native there.
  - the two platforms agree on word-delete → drop the `uname` /
    `vim.fn.has("mac")` split (tmux 139-148 collapses to one `C-h` plus one
    `M-BSpace` binding, wezterm 157, nvim 76).
  - the new layer re-accepts `ESC DEL` *and* arrows are native on both → delete
    every entry in the list above, including the `lazygit_key` helper and the
    whole nvim `FileType` autocmd. `wezterm.lua`'s Ctrl+Backspace pin already
    emits exactly `ESC DEL`, so lazygit would need nothing at all. Keep the pin
    itself and the `claude` branch on `C-h`: both exist for unrelated reasons
    (nvim's enhanced-key encoding, and Claude Code's word-delete).
  - Note a running tmux server must be restarted, not just re-sourced —
    `source-file` adds bindings but never removes them, so a deleted binding
    survives a reload and keeps translating.

- [ ] Report the darwin/linux divergence upstream to lazygit or tcell, or find
  the existing issue. Identical module hashes with a `GOOS`-only difference make
  for an unusually clean report, and it is the single thing blocking every
  collapse above.

## macOS compatibility audit

Open findings from the script audit. Shared scripts must support macOS Bash
3.2 and Linux; verify fixes with the appropriate interpreter and native tools.

- [ ] Make session logging work without the `setsid` executable.
  [log-session.sh](agents/.agents/hooks/log-session.sh), line 35, launches the
  renderer with `setsid`, which was absent from this Mac's PATH during the
  audit. Errors are discarded and the hook returns success. Verify that the
  renderer completes after the hook exits on both platforms.

- [ ] Replace negative array indices in
  [rdiff](scripts/.local/scripts/rdiff), lines 11–12.
  `${args[-2]}` and `${args[-1]}` fail under Bash 3.2 with `bad array subscript`.
  Verify local comparisons with and without additional diff options.

- [ ] Replace `mapfile` in
  [backfill-session-logs.sh](agents/.agents/hooks/backfill-session-logs.sh),
  line 42, with a Bash 3.2-compatible reader that preserves NUL-delimited
  paths. Verify empty input and paths containing spaces or newlines.

- [ ] Add portable quota-reset timestamp parsing to
  [cc-pick-account](scripts/.local/scripts/cc-pick-account), line 122.
  BSD date rejects `date -d`; the suppressed error skips reset validation and
  leaves pre-reset cache entries eligible until their TTL expires. Verify
  rejection of an otherwise fresh cache entry whose quota window has reset.

- [ ] Replace the GNU-only `rmdir --ignore-fail-on-non-empty` option in
  [bootstrap.sh](bootstrap.sh), line 249. macOS rejects the option and the
  suppressed error skips empty-directory cleanup. Verify empty directories
  are removed while populated directories remain intact.

- [ ] Correct Skim's inverse-search helper path in
  [bootstrap.sh](bootstrap.sh), line 658. It configures
  `$HOME/.local/scripts/nvr-skim-inverse`, but the tracked helper is
  [nvr-skim-inverse](scripts-private/.local/scripts-private/nvr-skim-inverse)
  and is installed under `$HOME/.local/scripts-private/`. The configured
  path did not exist on this Mac during the audit. Verify the configured
  command resolves after stowing.

- [ ] Make existing-token updates portable in
  [ticktick-oauth.sh](scripts-private/.local/scripts-private/ticktick-oauth.sh),
  line 123. Its GNU-style `sed -i` invocation is incompatible with BSD sed.
  Verify updates using dummy secrets while preserving unrelated lines.

- [ ] Detect local macOS NFS mounts in both
  [the shell hook](agents/.agents/hooks/block-nfs-writes.sh), line 31, and
  [the OpenCode plugin](opencode/.config/opencode/plugins/block-nfs-writes.js),
  line 24. The shell reads only `/proc/mounts`; the JavaScript fallback looks
  for `type nfs`, missing macOS's `(nfs, ...)` mount format. Fixed shared-path
  prefixes still apply. Add coverage for macOS mount output and paths outside
  those fixed prefixes; keep both implementations consistent.

- [ ] Handle trailing `Z` in both BSD timestamp-conversion paths in
  [statusline.sh](claude/.claude/statusline.sh), lines 136–137 and 374–375.
  The current normalization leaves `Z` unchanged, and BSD date rejected
  `2026-09-07T09:00:00Z` with the script's `%z` format. Verify `Z`, numeric
  offsets, and fractional seconds. Impact on live usage data is conditional:
  the audit did not inspect actual API timestamp values.

- [ ] Fix non-verbose early exits in [clip](scripts/.local/scripts/clip),
  line 26. `log() { (( verbose )) && printf ...; }` returns failure when
  verbosity is off, causing `set -e` to abort. This affects both platforms;
  `clip --help` failed silently while `clip -v --help` succeeded. Verify
  ordinary operation without `-v` using mocked clipboard commands.

- [ ] Clarify or complete direct macOS support in
  [xopen](scripts/.local/scripts/xopen), lines 63–95. URL and directory
  handling selects Linux-oriented tools before the Darwin branch; background
  directory launches can hide failure. Its current comment directs macOS
  users to native `open`. If supporting direct Mac invocation, verify URLs,
  directories, and files all select the native opener.

- [ ] Resolve Homebrew Ruby and Make paths portably in
  [.zshrc](zsh/.zshrc), lines 121–122. They hardcode `/opt/homebrew`, unlike
  the LLVM path's `brew --prefix` lookup. Verify prefix handling for both
  Apple Silicon and Intel Homebrew layouts.

Audit scope: 62 scripts and three zsh configuration files. Shell/zsh syntax
checks and Python parsing checks passed. Existing NFS tests passed but did
not cover the macOS mount format. Installation, hardware, clipboard, and
network workflows were not executed end to end.

Intentional platform scope: i3 scripts and CPU/kernel tools are Linux-specific;
`bootstrap.sh` excludes the i3 package on macOS. `ccinsights-all` delegates to
`popos` before reaching its `mapfile` call. These are not additional shared
macOS execution bugs.
