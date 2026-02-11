# Global Claude Code Instructions

## Hook Blocks (CRITICAL)

When a command is blocked by a hook (e.g., "BLOCKED: sudo is not allowed"):
- **NEVER attempt workarounds** such as removing sudo, using alternative commands, or modifying the command to bypass the block
- Try running the command, the user will be asked to approve if needed by the hook
- The hook exists for security/safety/correctness reasons - respect it completely

## Sudo Commands

- Run sudo commands directly when needed. Do NOT ask the user to run them manually.
- If a hook blocks the command, the user will be prompted to approve — just attempt it.

## Temporary Scripts / Files

- **NEVER create wrapper scripts in /tmp or scratchpad.** Always modify existing project scripts or create new ones in the project directory.
- Temporary wrapper scripts lead to orphaned processes and are not version-controlled or battle-tested.
- If a multi-config loop is needed, add it to the project's existing experiment runner script.

## Dotfiles management

- dotfiles can be found under ~/dotfiles
- If the user requests a change in some configuration, they change should always be reproducible through the dotfiles
- Before proposing a fix, fully read and understand the existing configuration and the user's dotfiles management approach (stow-based). Do not propose changes that conflict with stow symlink structure. Never edit profile files directly when they should be recreated through stow.

## Core Principles

- Never delete any comments while doing updates.
- When inserting new code blocks, ensure surrounding comments still belong to their original code sections. Never separate a comment from the code it describes.
- Only make changes that are directly requested - do not add "improvements" or modifications based on assumptions about what would be better.
- **Never delete files, data, or results unless explicitly asked to delete.** A question about something ("did I ask you to...?") is not a request to act. When in doubt, ask before taking any destructive/irreversible action.
- When I ask a question or ask you to explain something, ONLY explain. Do not attempt to fix, modify, or run commands unless I explicitly ask you to make changes.
- Never fabricate information (papers, authors, venues, results). Use `[[TODO: need source]]` when unsure.
- Distinguish observations from hypotheses. Don't state inferences as facts or invent specific numbers (e.g., rate limits, thresholds) without verification. Search for sources before making claims, not after being challenged.
- Follow existing code conventions in each project.
- Test changes before marking tasks complete.
- Be concise and direct.
- When answering questions about code, ALWAYS include the relevant code snippet(s) in your response. Never provide an explanation without showing the actual code being discussed.
- When the user asks about something in their repo or config files, ALWAYS search the actual repo/config first before giving generic advice. Never assume — look at the code.

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

- When working with perf events and PEBS experiments, always validate event codes against the actual CPU architecture (EMR, SKX, GNR) before running. Never assume event codes are portable across microarchitectures. Double-check MSR values and event selectors against Intel SDM or `perf list`.

## Shell Scripts (CRITICAL)

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

## Process Management

**Problem**: Child processes become orphaned (PPID=1) when parent is killed.

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

Common example: `wrapper_proc ... -- child_proc &` — killing wrapper leaves child orphaned.

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

1. Check the actual process: `ps -p <PID> -o pid,stat,etime` or `kill -0 <PID>`
2. Check the full process tree: `pgrep -af "pattern"` (the process may have forked)
3. Only after confirming the process is truly gone, take corrective action
4. **Never `rm -rf` experiment results without first confirming no running process is writing to them**

## Batch Parallel Execution

### Prefer `xargs -P` over bash background jobs

Bash scripts with `set -euo pipefail` and background jobs (`&`) are fragile for parallel
batch processing:
- `pipefail` causes silent failures when background processes exit non-zero
- Output interleaving through pipes (`2>&1 | while read`) buffers unpredictably
- `wait -n` (bash 4.3+) combined with `|| true` silently swallows errors
- zsh doesn't support `VAR=$!` after `&` the same way bash does

**Instead, use `xargs -P N`** which handles parallelism, error propagation, and process
lifecycle cleanly:

```bash
# GOOD: reliable parallel batch processing
find results/ -maxdepth 1 -type d -name '*.v1' | sort \
  | xargs -P $(nproc) -I {} python3 scripts/process.py {} > /tmp/batch.log 2>&1

# BAD: fragile background-job parallelism in bash
for dir in results/*/; do
    process "$dir" &
    ((running++))
    if [[ $running -ge $N ]]; then wait -n || true; ((running--)); fi
done
```

### Split cores across concurrent batches

When running multiple independent batch types simultaneously (e.g., two different plot
scripts), split available cores evenly rather than oversubscribing:

```bash
# 14 cores → 7 per batch (run as two separate background commands)
find ... | xargs -P 7 -I {} python3 script_A.py {} > /tmp/A.log 2>&1 &
find ... | xargs -P 7 -I {} python3 script_B.py {} > /tmp/B.log 2>&1 &
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

**Problem**: Experiments can stall silently. Track progress, not just status.

```bash
# Monitor progress, alert on stall
while true; do
    current=$(wc -l <output.log)
    [[ $current -eq $last ]] && echo "WARNING: No progress!"
    last=$current
    sleep 300
done
```

**Pre-launch checklist**: Progress tracking exists, monitor running, expected rate known.

### Trial / Validation Runs

When running a benchmark or experiment for quick validation (not production data collection),
use as many cores as the system has (`nproc`) to minimize runtime. Do not use 1 core or a
small core count for trial runs — it wastes time.

- When running long experiment batches, validate the first 1-2 results before launching the full set. Check for zero counters, empty output files, and SIGPIPE issues from piping to head/tail

### Active Monitoring (CRITICAL)

After launching any experiment or long-running process, you MUST actively monitor
it in the current conversation. NEVER do any of the following:
- End the conversation by saying "the experiment will take X hours, check back later"
- Create a separate monitoring script and leave
- Suggest the user check results manually
- Say "I'll let you know when it's done" and then stop

Instead, you MUST:
1. Stay in the conversation and poll the experiment's progress at reasonable intervals
   (e.g., check logs, output files, process status every 30-60 seconds).
2. Report progress updates to the user as you observe them.
3. If an error or anomaly is detected, IMMEDIATELY stop running further experiments
   and diagnose/fix the issue before continuing.
4. Only consider the task complete when the experiment has finished successfully and
   results have been collected/verified.

### Clean Slate Between Experiments (CRITICAL)

When running multiple experiments in sequence, each experiment MUST start with a
completely clean process state. **After each experiment finishes**, you MUST:

1. Check the process list for any orphaned processes from the completed experiment.
   Use `pgrep -af` with patterns matching the experiment's binaries and background
   processes. Do NOT rely on the script's own cleanup — independently verify.
2. If orphans are found, kill them (children first, then parents) and verify they
   are gone before proceeding to the next experiment.
3. Only start the next experiment after confirming a clean slate.

Common orphan sources:
- Child processes surviving after parent is killed (SIGKILL doesn't propagate)
- Background processes not receiving signals properly
- Long-running sleep/daemon processes spawned by experiment infrastructure

## Git Commits

- One brief sentence summarizing the change
- Never commit secrets (API keys, passwords, tokens)
- Check `git diff` before committing

## Git Patches

- When applying patches or fixes, always verify the change actually took effect. `git apply` can silently fail - check the file contents after applying.

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

- Plot titles must be as descriptive as possible, including all key parameters and context.
- Output file names must be equally descriptive, encoding key parameters (e.g., platform, event, dataset, method, bin size, date). Any information in the title should also be recoverable from the filename.
- Any information encoded in the output file name must also appear in the plot title, and vice versa.
- Axis labels must include units where applicable.

## Whitespace (CRITICAL)

- No trailing spaces/tabs on any line
- Empty lines must be truly empty
- Verify: `git diff --check` shows no warnings

## Linux Kernel Development

### Remote SSH Workflow

```bash
# Use Python for complex edits (sed fails with multiline through SSH)
scp /tmp/fix.py remote:/tmp/ && ssh remote 'python3 /tmp/fix.py file.c'

# Incremental compilation
ssh remote 'make -j$(nproc) mm/file.o'

# Rewrite commits (git rebase -i hangs through SSH)
git filter-branch -f --msg-filter 'sed "s/old/new/"' HEAD~N..HEAD
```

### Code Review Focus Areas

1. **Logic**: Missing error checks, incorrect returns
2. **Memory**: Reference counting (one put per get), leaks, UAF
3. **Concurrency**: TOCTOU, missing locks
4. **Performance**: O(n) loops, stack overflow (use `kvcalloc` for large arrays)
5. **Edge Cases**: Empty lists, zero values, THP (use `folio_nr_pages()`)

### Common Pitfalls

| Issue | Rule |
|-------|------|
| Reference counting | Audit ALL exit paths for exactly one put per get |
| Large stack arrays | Use `kvcalloc()`/`kvfree()` if size depends on config |
| THP accounting | Never assume page count is 1 |
| Hugetlb | Separate accounting, different putback routines |

### Kernel Commit Format

```
subsystem: brief description

1. What was wrong
2. Root cause
3. How this fixes it
```
