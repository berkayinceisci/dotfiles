# Agent Instructions (shared core)

<!-- Canonical, harness-agnostic instructions shared by Claude Code, Codex, and
     OpenCode. Edit THIS file; all three harnesses pick up the change.
     Tool-specific addenda live in each harness's own file:
       ~/.claude/CLAUDE.md            imports this via @~/.agents/core.md
       ~/.codex/AGENTS.md             symlink -> this file
       ~/.config/opencode/AGENTS.md   symlink -> this file
     Shared skills (open Agent Skills spec) live in ~/.agents/skills/, read
     natively by Codex and OpenCode; Claude Code reads it via the
     ~/.claude/skills symlink (created by install.sh). Task-scoped procedures
     (e.g. linux-kernel-dev) belong there, not in this always-loaded file. -->

## Context Efficiency

### File Reading
Read files with purpose. Before reading a file, know what you're looking for.
Use Grep to locate relevant sections before reading entire large files.
Never re-read a file you've already read in this session.
For files over 500 lines, use offset/limit to read only the relevant section.

### Subagent Delegation
- Delegate self-contained tasks (broad searches, codebase exploration, independent sub-tasks) to subagents, especially when the main context is already large — they do the work in a fresh context and return only a summary.
- Always give subagents explicit output rules: "Final response under 2000 characters. List outcomes, not process."

### Image Files (CRITICAL)
- **NEVER read or open PNG files** without asking the user first. PNG images consume massive context and often hit dimension limits.
- When you need to analyze a plot/image, prefer reading the **PDF version** (which is always generated alongside PNGs per the plotting rules).
- **NEVER use Bash to open/crop/process PNG files** (e.g., `Image.open('*.png')`, `PIL`, `cv2`, `convert`). If image processing is needed, ask the user first.
- No exceptions — do not attempt workarounds.

### Responses
Don't echo back file contents you just read — the user can see them.
Don't narrate tool calls ("Let me read the file..." / "Now I'll edit..."). Just do it.
Keep explanations proportional to complexity. Simple changes need one sentence, not three paragraphs.

**Tables — STRICT RULES (apply everywhere, always):**
- Markdown tables: use minimum separator (`|-|-|`). Never pad with repeated hyphens (`|---|---|`).
- NEVER use box-drawing / ASCII-art tables with characters like `┌`, `┬`, `─`, `│`, `└`, `┘`, `├`, `┤`, `┼`. These are completely banned.
- No exceptions. Not for "clarity", not for alignment, not for terminal output.

## Hook Blocks (CRITICAL)

When a command is blocked by a hook (e.g., "BLOCKED: sudo is not allowed"):
- **NEVER attempt workarounds** such as removing sudo, using alternative commands, or modifying the command to bypass the block
- Try running the command, the user will be asked to approve if needed by the hook
- The hook exists for security/safety/correctness reasons - respect it completely

## Execution Model: Control Machine vs Remote (CRITICAL)

Your coding agent runs on the **control machine** (the user's local workstation).
Experiment, hardware, and perf work targets a **remote machine**, referenced
throughout these instructions as `$REMOTE_HOST` — substitute the actual SSH
host name (e.g. an entry from `~/.ssh/config`) for the session. The shell
the agent drives is the control machine's shell; any command that must
execute on the experiment box is wrapped in `ssh $REMOTE_HOST '…'`.

**Default: remote via SSH.** Assume experiment work is remote unless the user
says otherwise. The control machine is not an experiment host.

**Runs locally on the control machine:**
- File reads/edits in the project directory (dotfiles, code, analysis/plotting scripts) — synced to the remote before execution
- Git operations on local clones (commits, diffs, log)
- Inspecting *small final artifacts* (PDFs, summary CSVs, metric JSON) `scp`'d back from the remote — what the agent reads to analyze results
- The agent itself and all its tool calls (the ssh wrapping lives *inside* the Bash tool call)

**Runs on `$REMOTE_HOST` via `ssh`:**
- All `sudo`, `wrmsr`, `rdmsr`, `perf`, and other privileged/hardware commands
- Experiment launches and their background/monitor processes
- Process inspection on the experiment host: `ps aux`, `pgrep`, `kill`, `pkill`
- `nproc` when sizing parallelism for remote work — the remote's core count is what matters
- Log streams for live monitoring (e.g. `ssh $REMOTE_HOST 'tail -F /tmp/experiment.log | grep --line-buffered …'`) — see "Long-Running Experiments"
- **Data processing and plot generation against raw experiment data.** Move compute to where the data lives — never pull multi-GB CSVs/perf dumps/trace files back just to plot them. Scripts are edited locally, `scp`/`rsync`'d over, then executed via `ssh $REMOTE_HOST 'python plots/foo.py …'`; only the small artifacts (PDFs, summary tables) come back. Pickle caches (`.cache/`) live with the scripts on the remote.

**Practical patterns:**

```bash
# Single command on the remote (read-only — does not mutate hardware state)
ssh $REMOTE_HOST 'sudo rdmsr -p 0 0x1A4'

# Multi-command block — heredoc with single-quoted sentinel to avoid local expansion.
# Non-destructive write/verify: read the MSR, write back the SAME value, confirm.
ssh $REMOTE_HOST 'bash -s' <<'EOF'
set -euo pipefail
orig=$(sudo rdmsr -p 0 0x1A4)
sudo wrmsr -a 0x1A4 "0x$orig"
[[ $(sudo rdmsr -p 0 0x1A4) == "$orig" ]] || { echo "MSR write failed"; exit 1; }
EOF

# Detached long-running job on the remote — run inside a tmux session (NOT nohup)
# so the user can attach and watch live; tee keeps the log tailable/monitorable.
# ssh returns immediately; the session closes itself when the command exits.
ssh $REMOTE_HOST 'tmux new-session -d -s exp "sudo ./experiment.sh 2>&1 | tee /tmp/experiment.log"'

# Copy files to / from the remote
scp ./script.py $REMOTE_HOST:/tmp/
scp $REMOTE_HOST:/tmp/results.csv ./data/

# Use Python for complex edits of remote files (sed fails with multiline through SSH)
scp /tmp/fix.py $REMOTE_HOST:/tmp/ && ssh $REMOTE_HOST 'python3 /tmp/fix.py file.c'
```

**Quoting discipline.** Single-quote the remote command so `$vars` expand on the
remote, not on the control machine. Use double quotes only when you deliberately
want the control machine to interpolate a value before sending.

## Environment Descriptions

### Cloudlab Experiment Hosts
Cloudlab experiment hosts: `*.cloudlab.us` — temporary single-tenant experiment machines provisioned via the Cloudlab portal. Each machine is reimaged between experiments and dedicated to the session for its lifetime, with no production data and no other users at the OS level. Routine privileged commands (`sudo`, `wrmsr`/`rdmsr`, `perf`, `rm -rf` on `/tmp` or experiment scratch dirs) inside ssh to these hosts are expected and should not require prompts.

### Lab Experiment Hosts
Lab experiment hosts: `hds01`..`hds07` — persistent shared lab machines maintained by the research group. Other lab members have accounts on the same hosts and run their own work concurrently, so commands must operate only on the user's own files (under `$HOME`, scratch dirs), own processes, and infrastructure owned by the user — never other users'. The user has root/sudo for personal kernel, perf, and hardware work, so routine privileged commands scoped to the user's workspace (`sudo`, `wrmsr`/`rdmsr`, `perf`, `modprobe`, `rm -rf` of own scratch dirs) are expected and should not require prompts.

**Important:** The default 'Interfere With Others' and 'Modify Shared Resources' restrictions still apply on lab machines. Shared NFS writes are always blocked (enforced by a hook/plugin).

## Sudo Commands

- Run sudo commands directly when needed. Do NOT ask the user to run them manually.
- Sudo commands that target the experiment host run via `ssh $REMOTE_HOST 'sudo …'`, not on the control machine. See "Execution Model" above.
- If a hook blocks the command, the user will be prompted to approve — just attempt it.

## Temporary Scripts / Files

- **NEVER create wrapper scripts in /tmp or scratchpad.** Always modify existing project scripts or create new ones in the project directory.
- Temporary wrapper scripts lead to orphaned processes and are not version-controlled or battle-tested.
- This applies equally to `/tmp` on `$REMOTE_HOST`. Do not synthesize scripts inline via `ssh $REMOTE_HOST 'cat > /tmp/…'` — edit a real project script on the control machine, `scp` it over, then invoke it via `ssh`.
- If a multi-config loop is needed, add it to the project's existing experiment runner script.

## Compression

- Use `pigz` instead of `gzip` for compression. It parallelizes across cores and is much faster on multi-core machines.
  ```bash
  # GOOD: parallel compression
  tar cf - dir/ | pigz >archive.tar.gz

  # BAD: single-threaded
  tar czf archive.tar.gz dir/
  ```

## Core Principles

- Be concise and direct.
- Never delete any comments while doing updates.
- When inserting new code blocks, ensure surrounding comments still belong to their original code sections. Never separate a comment from the code it describes.
- Only make changes that are directly requested - do not add "improvements" or modifications based on assumptions about what would be better.
- **Never delete files, data, or results unless explicitly asked to delete.** A question about something ("did I ask you to...?") is not a request to act. When in doubt, ask before taking any destructive/irreversible action.
- When I ask a question or ask you to explain something, ONLY explain. Do not attempt to fix, modify, or run commands unless I explicitly ask you to make changes.
- Never fabricate information (papers, authors, venues, results). Use `[[TODO: need source]]` when unsure.
- Distinguish observations from hypotheses. Don't state inferences as facts or invent specific numbers (e.g., rate limits, thresholds) without verification. Search for sources before making claims, not after being challenged.
- Follow existing code conventions in each project.
- If the user requests a configuration change, make it reproducible through their dotfiles repo (e.g. `~/dotfiles`) rather than editing live config files directly.
- Test changes before marking tasks complete.
- Be honest about outcomes: if tests fail, say so with the output; if a step was skipped, say so.
- When answering questions about code, ALWAYS include the relevant code snippet(s) in your response. Never provide an explanation without showing the actual code being discussed.
- When the user asks about something in their repo or config files, ALWAYS search the actual repo/config first before giving generic advice. Never assume — look at the code.

## Working Approach

- For non-trivial changes, plan first and get sign-off on the approach before editing.
- Prefer reusing existing code and utilities over adding new ones.
- After a change, verify it (build/run/tests) rather than asserting it works; read the diff before
  calling it done, and when a review flags something, find a safer fix rather than circumventing it.
- Codify repeated multi-step workflows as reusable skills, and repeated prompts as reusable commands.

## Document Generation

When writing documents, reports, or any prose that makes factual claims:
- Every factual claim must be directly traceable to a source file you read in this session.
- If a claim is not directly from a source file, mark it with `[[VERIFY]]`.
- This includes: acronym expansions, specific numbers, names, paper titles, algorithm names, and definitions.
- When in doubt, mark it. False confidence is worse than a `[[VERIFY]]` tag.

## Conversation Guidelines

Primary Objective: Engage in honest, insight-driven dialogue that advances understanding.

### Core Principles

- Intellectual honesty: Share genuine insights without unnecessary flattery or dismissiveness
- Critical engagement: Push on important considerations rather than accepting ideas at face value
- Balanced evaluation: Present both positive and negative opinions only when well-reasoned and warranted
- Directional clarity: Focus on whether ideas move us forward or lead us astray

### What to Avoid

- Sycophantic responses or unwarranted positivity
- Dismissing ideas without proper consideration
- Superficial agreement or disagreement
- Flattery that doesn't serve the conversation

### Success Metric

- The only currency that matters: Does this advance or halt productive thinking? If we're heading down an unproductive path, point it out directly.

## Hardware Performance Monitoring (CRITICAL)

- MSR/perf/PEBS work runs on `$REMOTE_HOST` (see "Execution Model"). Validate event codes against the actual CPU architecture (EMR, SKX, GNR) of **`$REMOTE_HOST`** — never assume portability across microarchitectures. Double-check MSR values and event selectors against Intel SDM or `ssh $REMOTE_HOST 'perf list'`.

## Script Conventions

These apply to any non-trivial script — bash, Python, Rust, anything — not
just shell.

- **Provide a `-v` / `--verbose` flag.** When a script has branches (platform
  detection, tool selection, mode auto-detection, fallback paths, retries)
  `-v` must log to stderr the chosen branch, the exact underlying command
  about to run, and any relevant env vars. Without this, a silent failure
  leaves the user unable to tell apart a missing dependency, a wrong
  environment (e.g. unset `DISPLAY` over ssh), and a real bug.

## Shell Scripts (CRITICAL)

Shell scripts that touch hardware, sudo, or experiment infrastructure are edited
locally and run on `$REMOTE_HOST` (see "Execution Model" and "Temporary Scripts /
Files"). The examples below show *script content*, not commands to paste into
the control machine's shell.

```bash
#!/bin/bash
set -euo pipefail

# ALWAYS use [[ ]] for conditionals, == for strings, -eq for numbers
[[ "$var" == "value" ]] && [[ $num -eq 5 ]]

# NEVER suppress errors from critical operations
wrmsr -a 0x1A4 0xF         # Good: will fail visibly
wrmsr -a 0x1A4 0xF || true # BAD: hides failures

# ALWAYS verify hardware operations
wrmsr -a 0x1A4 0xF
[[ $(rdmsr -p 0 0x1A4) == "f" ]] || {
  echo "MSR write failed"
  exit 1
}

# Use rm -f to avoid interactive prompts
rm -f file.txt # Good
rm file.txt    # Bad: may prompt
```

- When fixing shell scripts, account for the actual shell interpreter (bash vs zsh). Zsh expands globs before command substitution — test fixes against the correct shell. Always verify the fix works, don't just explain it.
- When chaining multiple independent commands (e.g., health checks, diagnostic steps), use `;` not `&&`. With `&&`, if any command returns non-zero (e.g., `grep` finding no matches, `pgrep` finding no processes), all subsequent commands are skipped. Use `&&` only when commands genuinely depend on each other's success.

- **`set -e` + `pipefail` and query commands**: Many commands return non-zero for
  "not found" rather than actual errors (`grep` no match → 1, `pip show` not
  installed → 1, `dpkg-query` not found → 1, `command -v` not found → 1,
  `diff` files differ → 1). With `set -euo pipefail`, these kill the script.
  Distinguish **actions** (must fail loudly) from **queries** (wrap in `if`):
```bash
# ACTIONS — never suppress errors
make -j"$(nproc)"
pip install "pkg==1.0"
wrmsr -a 0x1A4 0xF

# QUERIES — use if to absorb expected non-zero exit codes
if ver="$(pip show pkg 2>/dev/null | awk '/^Version:/ {print $2}')"; then
  echo "installed: $ver"
fi

if dpkg-query -W -f='${Version}' pkg 2>/dev/null; then ...; fi
if command -v binary >/dev/null 2>&1; then ...; fi
if grep -q "pattern" file 2>/dev/null; then ...; fi
```
  Also beware of `pipefail` + `grep -q`: when `grep -q` matches early, it exits
  and closes the pipe, giving the upstream command SIGPIPE (exit 141). `pipefail`
  propagates that. Use process substitution to avoid:
```bash
# BAD: pipefail propagates SIGPIPE (exit 141) from left side
if cmd_with_lots_of_output 2>&1 | grep -q 'pattern'; then ...

# GOOD: process substitution — grep reads from a subshell, no SIGPIPE
if grep -q 'pattern' <(cmd_with_lots_of_output 2>&1); then ...
```

- **Never use `[[ condition ]] && action` in loops.** If the last iteration's condition is false, the `&&` short-circuit sets the loop's exit code to 1, producing a misleading error even though all matching iterations succeeded. Use `if/then/fi` instead:
```bash
# BAD: exit code 1 if last item doesn't match condition
for d in */; do [[ "${d%/}" != *_v1 ]] && rm -rf "$d"; done

# GOOD: explicit if avoids misleading exit codes
for d in */; do if [[ "${d%/}" != *_v1 ]]; then rm -rf "$d"; fi; done
```

## Process Management

**Problem**: Child processes become orphaned (PPID=1) when parent is killed.

All operations below target `$REMOTE_HOST` (see "Execution Model"); examples
show the commands in pure form — wrap each in `ssh $REMOTE_HOST '…'` when
invoking from the control machine.

### Killing Process Trees

SIGKILL (`kill -9`) does NOT propagate to children. You must explicitly kill children first:

```bash
# WRONG: leaves child processes orphaned
kill -9 $parent_pid

# RIGHT: kill children first, then parent
pkill -9 -P "$parent_pid" 2>/dev/null || true
kill -9 "$parent_pid" 2>/dev/null || true
wait "$parent_pid" 2>/dev/null || true
```

Common example: `perf record -- ./bench &`, `nohup sudo ./loop-cmd.sh &`, or a
tmux pane shell (`tmux new-session -d "sudo ./exp.sh | tee log"`) — killing the
wrapper (perf, nohup, sudo, the pane shell, a launcher script) leaves the actual
workload child orphaned under PPID=1. `tmux kill-session` has the same problem:
it signals the pane process, not the tree under it — and a sudo'd workload is
root-owned, so killing its children requires `sudo pkill -9 -P "$pane_pid"` on
the remote, children first, then the pane.

### Cleanup Traps in Scripts

```bash
# Track all background PIDs
BG_PIDS=()

cleanup() {
  for pid in "${BG_PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      pkill -9 -P "$pid" 2>/dev/null || true # children first
      kill -9 "$pid" 2>/dev/null || true
    fi
  done
  wait 2>/dev/null || true
}

# IMPORTANT: Only trap INT TERM, NOT EXIT.
# Trapping EXIT causes the trap to fire on normal exit, which can produce
# non-zero exit codes that break `set -euo pipefail` in calling scripts.
trap cleanup INT TERM

some_command &
BG_PIDS+=("$!")
```

### Verifying Process Death

**CRITICAL: Before declaring a process dead, verify with `ps` or `kill -0`, not just log output.** Logs may be buffered/stale. Never delete results or restart experiments based on log staleness alone.

This subsection is for confirming **a specific known process** (and its known
children) is gone — i.e. you have a PID or a process name you launched and want
to verify is no longer running. For "the machine as a whole is clean of any
unexpected processes," pattern matching is insufficient; see "Verifying a
Clean Machine (CRITICAL)" below.

1. Check the actual process: `ps -p <PID> -o pid,stat,etime` or `kill -0 <PID>`
2. Check for children/forks of that known process: `pgrep -af "<pattern>"` using the binary name or wrapper script you launched as the pattern.
3. Only after confirming the process is truly gone, take corrective action
4. **Never `rm -rf` experiment results without first confirming no running process is writing to them**

### Verifying a Clean Machine (CRITICAL)

"The machine" here means `$REMOTE_HOST` — the experiment host, not the control
machine. Run each inspection command via `ssh $REMOTE_HOST '…'`.

When asked to confirm all processes are dead or the machine is clean, **NEVER rely
solely on `pgrep -af` or `grep` with specific patterns.** Pattern-based searches miss
processes with unexpected names, respawned children, or commands you didn't anticipate.

**Always use `ps aux` (unfiltered) and visually scan the full output.** Specifically:

1. Run `ssh $REMOTE_HOST 'sudo ps aux --sort=-%cpu'` to see everything by CPU usage.
2. Look for ANY user-space process consuming CPU that isn't a known system service
   (sshd, systemd, cron, tmux, zsh, etc.) or the current session (the agent, node, nvim).
   Note: the agent itself lives on the control machine, not `$REMOTE_HOST`, so it should
   not appear in the remote's `ps aux` output.
3. After killing processes, **re-check with `ssh $REMOTE_HOST 'ps aux'` again** — loop-style wrappers
   (e.g., `loop-cmd.sh`) respawn children immediately after you kill them. You must
   kill the parent wrapper first, then the children.
4. Check for `cat ...fifo` or other blocking processes that consume 0% CPU but
   indicate orphaned infrastructure (e.g., `perf record` stop FIFOs).
5. Only declare the machine clean after a full `ps aux` scan shows nothing unexpected.

## Batch Parallel Execution

### Prefer `xargs -P` over bash background jobs

Bash scripts with `set -euo pipefail` and background jobs (`&`) are fragile for parallel
batch processing:
- `pipefail` causes silent failures when background processes exit non-zero
- Output interleaving through pipes (`2>&1 | while read`) buffers unpredictably
- `wait -n` (bash 4.3+) combined with `|| true` silently swallows errors
- zsh doesn't support `VAR=$!` after `&` the same way bash does

**Instead, use `xargs -P N`** which handles parallelism, error propagation, and process
lifecycle cleanly.  **Always reserve 2 cores for the user** — use `$(($(nproc) - 2))`
instead of `$(nproc)` for the parallelism level. Because batch work typically runs on
`$REMOTE_HOST`, `nproc` must evaluate on the remote, not on the control machine —
either wrap the whole pipeline in `ssh $REMOTE_HOST '…'` (single-quoted, so `nproc`
and `$()` expand on the remote) or resolve the core count up front with
`N=$(ssh $REMOTE_HOST nproc)`:

```bash
# GOOD: reliable parallel batch processing, reserving 2 cores, all on $REMOTE_HOST
ssh $REMOTE_HOST 'find results/ -maxdepth 1 -type d -name "*.v1" | sort |
    xargs -P $(($(nproc) - 2)) -I {} python3 scripts/process.py {} >/tmp/batch.log 2>&1'

# ALSO GOOD: resolve remote core count first, then launch
N=$(ssh $REMOTE_HOST nproc)
ssh $REMOTE_HOST "find results/ -maxdepth 1 -type d -name '*.v1' | sort |
    xargs -P $((N - 2)) -I {} python3 scripts/process.py {} >/tmp/batch.log 2>&1"

# BAD: fragile background-job parallelism in bash
for dir in results/*/; do
  process "$dir" &
  ((running++))
  if [[ $running -ge $N ]]; then
    wait -n || true
    ((running--))
  fi
done

# BAD: `nproc` runs on the control machine, not on $REMOTE_HOST — wrong core count
find results/ -maxdepth 1 -type d -name '*.v1' | sort |
  xargs -P $(($(nproc) - 2)) -I {} ssh $REMOTE_HOST python3 scripts/process.py {}
```

### Split cores across concurrent batches

When running multiple independent batch types simultaneously (e.g., two different plot
scripts), split available cores (minus 2 reserved) evenly rather than oversubscribing:

```bash
# 16 cores → 14 usable → 7 per batch (run as two separate background commands)
find ... | xargs -P 7 -I {} python3 script_A.py {} >/tmp/A.log 2>&1 &
find ... | xargs -P 7 -I {} python3 script_B.py {} >/tmp/B.log 2>&1 &
```

### Monitor by output directories, not log lines

Parallel process output is interleaved and buffered. Monitor progress by counting
completed output files/directories, not by tailing logs:

```bash
# GOOD: reliable progress monitoring
watch "ls plots/output_dir/ | wc -l"

# BAD: misleading due to output buffering
tail -f /tmp/batch.log | grep "Done:"
```

## Long-Running Experiments

**Problem**: Experiments can stall silently. Track progress by *streaming*
events (log lines, counters, terminal markers) — not by polling a status file.
Pre-launch, confirm the experiment emits progress markers on stdout/stderr,
that failure signatures (`Traceback`, `OOM`, `Killed`, `FAILED`, `error`,
`assert`) reach the log, and that the expected per-iteration rate is known so
stalls are visible.

### Trial / Validation Runs (CRITICAL)

When running a benchmark or experiment for quick validation (not production
data collection), use as many cores as the **experiment host** has — resolve
the count via `ssh $REMOTE_HOST nproc` or wrap the whole launch in ssh (see
"Batch Parallel Execution" for the remote-`nproc` patterns). Do not use 1 core
or a small count for trial runs — it wastes time.

- When running long experiment batches, validate the first 1-2 results before launching the full set. Check for zero counters, empty output files, and SIGPIPE issues from piping to head/tail

### Active Monitoring (CRITICAL)

After launching any experiment or long-running process, you MUST actively watch
it in the current conversation. NEVER do any of the following:
- End the conversation by saying "the experiment will take X hours, check back later"
- Suggest the user check results manually
- Say "I'll let you know when it's done" and then stop

Instead, you MUST:
- Start a live monitor on the experiment's log stream so progress events and failure
  signatures arrive as notifications in the current conversation.
- Report progress updates to the user as events arrive.
- If an error or anomaly is detected (filter matches a failure signature),
  IMMEDIATELY stop running further experiments and diagnose/fix the issue before
  continuing.
- Only consider the task complete when the experiment has finished successfully
  and results have been collected/verified.

**Stream progress events from the log; never poll a status file.**

#### Monitoring workflow

**Step 1: Launch the experiment on `$REMOTE_HOST` inside a detached tmux
session** (never `nohup`) — it survives the SSH session closing, the user can
attach to watch output live, and the pane remains available after the experiment
finishes for post-mortem inspection.

Pipe through `tee` so the log stays tailable for monitoring and is preserved
outside tmux. Give the session a descriptive name. Keep the tmux pane open after
the command exits so the user can inspect the final output, exit code, and any
errors.

```bash
ssh "$REMOTE_HOST" 'tmux new-session -d -s exp "bash -lc '\''set -o pipefail; sudo ./<experiment_script> 2>&1 | tee /tmp/experiment.log; status=${PIPESTATUS[0]}; echo; echo \"[experiment exited with status $status]\"; exec bash'\''"'
```

**Step 2: Watch the log.** If your harness provides a persistent log-monitor
tool, point it at a remote tail pipeline filtered to events worth acting on
(use a persistent / no-timeout mode so it survives the full experiment).
Otherwise, use blocking waits — each call blocks until the next significant
event, so the agent stays engaged without sleep-polling:

```bash
# Persistent log monitor: stream every significant event as it happens
ssh $REMOTE_HOST 'tail -F /tmp/experiment.log | grep --line-buffered -E "progress=|iter=|run [0-9]+/|Traceback|ERROR|FAILED|Killed|OOM|assert|DONE"'

# Blocking wait: block until the NEXT significant event, then re-issue
ssh $REMOTE_HOST 'tail -F /tmp/experiment.log | grep --line-buffered -m1 -E "run [0-9]+0/|Traceback|ERROR|FAILED|Killed|OOM|DONE"'
```

Rules for the filter:
- **Cover every terminal state, not just the happy path.** Include progress
  markers AND crash signatures (`Traceback|ERROR|FAILED|Killed|OOM|assert|…`).
  Silence from a filter that only matches success is indistinguishable from a
  crashloop. If unsure what the experiment prints on failure, broaden the
  alternation rather than narrow it.
- **`grep --line-buffered` is mandatory**, and it must run on the **remote side**
  of the ssh (inside the single-quoted command), otherwise ssh ships bursts of
  ~4KB at a time and events arrive minutes late.
- **ssh keepalives**: set `ServerAliveInterval 30` / `ServerAliveCountMax 3`
  in `~/.ssh/config` for experiment hosts, otherwise a transient network blip
  kills the watcher mid-experiment.

**Step 3: Detect exit.** Prefer having the experiment script print a terminal
marker (`DONE` / `FAILED` / `ABORTED`) that the log filter catches — that is
the cleanest signal. As a secondary check, issue a call that blocks until the
PID dies (run it as a background task if your harness supports those):

```bash
ssh $REMOTE_HOST "tail --pid=$EXP_PID -f /dev/null"
```

That ssh call exits exactly when `$EXP_PID` dies — no polling, no sleep.

**Step 4: Post-exit verification.** When a terminal marker arrives or the
PID-wait completes, stop the log watcher, then:
- `ssh $REMOTE_HOST 'ls -la <results_dir>'` — confirm expected result files
  exist and are non-empty.
- Confirm no orphaned experiment processes remain on `$REMOTE_HOST` — follow
  the "Verifying a Clean Machine (CRITICAL)" procedure (`ssh $REMOTE_HOST
  'sudo ps aux --sort=-%cpu'` + visual scan, not pattern matching with
  `pgrep`).
- Run analysis / plotting **on `$REMOTE_HOST` against the raw data**:
  `scp`/`rsync` any updated scripts to the remote, then
  `ssh $REMOTE_HOST 'python plots/foo.py …'`. `scp` back only the small
  generated artifacts (PDFs, summary CSVs, metric JSON) — never the raw data
  files themselves.

#### One-shot snapshot, on demand

If the user explicitly asks for a current progress snapshot mid-experiment
(separate from the live event stream), answer it with a single
`ssh $REMOTE_HOST 'tail -n 50 /tmp/experiment.log'` — not a poll loop. This
is a one-off query, not a recurring mechanism.

### Clean Slate Between Experiments (CRITICAL)

When running multiple experiments in sequence, each experiment MUST start with a
completely clean process state on `$REMOTE_HOST`. **After each experiment finishes**,
you MUST:

1. Check the process list on `$REMOTE_HOST` for any orphaned processes from the
   completed experiment — follow the "Verifying a Clean Machine (CRITICAL)"
   procedure (full `ps aux` scan via ssh, not pattern matching with `pgrep`).
   Do NOT rely on the script's own cleanup — independently verify.
2. If orphans are found, abort the experiment immediately.
3. Inform the user with the problem, the reason of the problem and the solution.

Common orphan sources:
- Child processes surviving after parent is killed (SIGKILL doesn't propagate)
- Background processes not receiving signals properly
- Long-running sleep/daemon processes spawned by experiment infrastructure

## Git Commits

- Commit or push only when explicitly asked; if on the default branch, branch first.
- One brief sentence summarizing the change
- Never commit secrets (API keys, passwords, tokens)
- Check `git diff` before committing
- When applying patches or fixes via `git apply`, always verify the change actually took effect — `git apply` can silently fail; check the file contents afterward

## Code Style

### C/C++

```c
/* Use C-style comments only, never // */
static int function_name(int *ptr)  /* brace on next line, pointer: type *var */
{
    return 0;
}
```

- 4 spaces indentation, 80 char line limit
- `lower_case_with_underscores` for names
- Verify: no trailing whitespace, no `//` comments, braces on own line

### Python

- PEP 8, f-strings, type hints when project uses them

### Rust

- `cargo fmt` + `cargo clippy`, `?` for error propagation

## Plotting

### Workflow (CRITICAL)

- After writing or updating plotting code, **immediately run it** to generate the plots.
  Do NOT ask the user whether to run — just run. The code-write-run cycle should be seamless.
- **Run plotting where the data lives.** When the raw experiment data is on `$REMOTE_HOST`
  (the usual case), `scp`/`rsync` the updated script to the remote and execute it via
  `ssh $REMOTE_HOST 'python plots/foo.py …'`. Do NOT pull multi-GB raw CSV/log/trace files
  back to the control machine just to plot them — only the small generated PDFs need to
  come back so the agent can read and analyze them. See "Execution Model" for the rationale.
- After plots are generated, **immediately analyze them** (read the PDF files, describe
  trends, anomalies, key observations). Do NOT ask the user whether to analyze — just do it.
  **Use PDF versions for analysis, not PNGs** — PNGs consume excessive context.
- The full pipeline is: write code → run → analyze. All three steps happen without pausing
  for confirmation.
- **Parallelize across parameter sets.** When a plotting script needs to be run multiple
  times with different parameters (e.g., different experiments, configs, or datasets),
  run invocations in parallel rather than sequentially. For small batches (3-4 invocations),
  use parallel Bash tool calls in a single response. For larger batches, use `xargs -P`.

- Plot titles must be as descriptive as possible, including all key parameters and context.
- Output file names must be equally descriptive, encoding key parameters (e.g., platform, event, dataset, method, bin size, date). Any information in the title should also be recoverable from the filename.
- Any information encoded in the output file name must also appear in the plot title, and vice versa.
- Axis labels must include units where applicable.
- **Always derive values from data instead of hardcoding.** When a parameter can be computed from the available data (e.g., perf stat interval from timestamp deltas, frequency from cycle counters, duration from output files), derive it rather than assuming a fixed value. Use hardcoded values only as fallbacks when data is unavailable. This applies to labels, titles, computations, and any context where the actual value matters.
- Use CDF (not CCDF) with linear scale (no log scale on axes) for distribution plots.
- Side-by-side panels that show the same metric must share axis limits so they are visually comparable.
- Always save plots in both PNG (dpi=150) and PDF formats. Split the two formats at the top level into sibling roots `plots-pdf/` and `plots-png/`; the `{category}/{experiment}/...` hierarchy underneath is preserved identically in both (e.g., `plots-pdf/latency_analysis/{experiment}/file.pdf` and `plots-png/latency_analysis/{experiment}/file.png`). To sync only the vector artifacts back to the control machine, `rsync`/`scp` the `plots-pdf/` tree.
- **CDF plot colors**: Use maximally distinguishable colors for CDF curves. When curves represent distinct categories (benchmarks, workloads), use an explicit color list: `['black', 'green', 'blue', 'red', 'magenta', 'tab:orange', 'tab:brown']`. Extend with `'tab:cyan'`, `'tab:olive'`, `'tab:gray'`, `'tab:pink'` if needed. Do not use colormaps (viridis, tab10) for CDFs — they produce visually similar adjacent colors that are hard to distinguish.
- **Never use `loc="best"` for legend placement.** It is O(n) on data points and can take hours on large datasets (100M+ samples). Always use a fixed location: `loc="upper right"`, `loc="upper left"`, etc.

### Plot Generation Performance (CRITICAL)

Plotting scripts must be as fast as possible while preserving correctness. Apply these
optimizations proactively:

- **Never read the same file more than once.** If a script needs multiple derived values
  from one data file (e.g., summary stats + CDF samples + with-zero samples), read the
  file in a single pass and compute all results from that one read. Three passes over a
  30M-row CSV is 3× slower than one pass.
- **Pickle-cache loaded data.** When a script loads expensive data (large CSVs, parsed
  perf output), cache the result to a `.cache/` directory using `pickle`. On re-runs
  (e.g., iterating on plot code), load from cache instead of re-parsing. Include a
  `--no-cache` flag to force reload. The cache key should hash all parameters that
  affect the loaded data (file paths, sample limits, frequencies, etc.) **and the
  modification time (`os.path.getmtime()`) of each source file**, so that updated
  raw data automatically invalidates stale caches.
- **Cache only parsed raw data, not derived analysis.** The cache should store the
  expensive-to-load structured data (parsed CSVs, perf stat intervals, timing anchors)
  — not downstream computations (quantile binning, correlations, alignment, regime
  assignment). Derived analysis must be recomputed on every run so that algorithm
  changes (e.g., bin count formula, alignment method) take effect immediately without
  `--no-cache`. Reserve `--no-cache` for when the raw data parsing logic itself changes.
- **Per-script cache subdirectories (CRITICAL).** Each script MUST use its own
  subdirectory under `.cache/`, named after the script's cache prefix:
  `.cache/zero_frac_mlp/`, `.cache/phase_regime/`, `.cache/am/`, etc. NEVER write
  cache files to the flat `.cache/` root. This prevents concurrent agents from
  colliding — one agent running `--no-cache` on script A must not affect script B's
  cached data. When implementing `--no-cache`, only delete files within the script's
  own subdirectory, never `rm -rf .cache/` or `rm .cache/*.pkl`.
- **Add `.cache/` to `.gitignore`** in any project that uses pickle caching.

## Whitespace (CRITICAL)

- No trailing spaces/tabs on any line
- Empty lines must be truly empty
- Verify: `git diff --check` shows no warnings
