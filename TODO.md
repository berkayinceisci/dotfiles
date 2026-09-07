# TODO

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
