# Global Claude Code Instructions

## Hook Blocks (CRITICAL)

When a command is blocked by a hook (e.g., "BLOCKED: sudo is not allowed"):
- **NEVER attempt workarounds** such as removing sudo, using alternative commands, or modifying the command to bypass the block
- **ALWAYS tell the user** to run the exact blocked command themselves
- The hook exists for security/safety reasons - respect it completely

Example: If `sudo ./install.sh` is blocked, do NOT try `./install.sh` without sudo. Instead say: "This command requires sudo. Please run it yourself: `sudo ./install.sh`"

## Core Principles

- Never delete any comments while doing updates.
- When inserting new code blocks, ensure surrounding comments still belong to their original code sections. Never separate a comment from the code it describes.
- Only make changes that are directly requested - do not add "improvements" or modifications based on assumptions about what would be better.
- **Never delete files, data, or results unless explicitly asked to delete.** A question about something ("did I ask you to...?") is not a request to act. When in doubt, ask before taking any destructive/irreversible action.
- Never fabricate information (papers, authors, venues, results). Use `[[TODO: need source]]` when unsure.
- Distinguish observations from hypotheses. Don't state inferences as facts or invent specific numbers (e.g., rate limits, thresholds) without verification. Search for sources before making claims, not after being challenged.
- Follow existing code conventions in each project.
- Test changes before marking tasks complete.
- Be concise and direct.

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

## Process Management

**Problem**: Child processes become orphaned (PPID=1) when parent is killed.

```bash
# Before starting: check for orphans
pgrep -af "pattern" && pkill -9 -f "pattern"

# Kill entire process tree, not just parent
pkill -9 -f "script_name"
pkill -9 -f "workload_binary"

# Verify processes are dead
sleep 2 && pgrep -af "pattern" || echo "Clean"

# In scripts: use cleanup traps
cleanup() {
    pkill -P $$
    exit
}
trap cleanup EXIT INT TERM
```

**CRITICAL: Before declaring a process dead, verify with `ps` or `kill -0`, not just log output.** Logs may be buffered/stale. Never delete results or restart experiments based on log staleness alone. Specifically:

1. Check the actual process: `ps -p <PID> -o pid,stat,etime` or `kill -0 <PID>`
2. Check the full process tree: `pgrep -af "pattern"` (the process may have forked)
3. Only after confirming the process is truly gone, take corrective action
4. **Never `rm -rf` experiment results without first confirming no running process is writing to them**

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

## Git Commits

- **NEVER commit unless the user explicitly asks you to commit.** Creating files or documentation does not imply permission to commit. Wait for explicit instructions like "commit this" or "commit the changes".
- One brief sentence summarizing the change
- Never commit secrets (API keys, passwords, tokens)
- Check `git diff` before committing

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
- Any information encoded in the output file name (e.g., dataset, method, parameters, date) must also appear in the plot title.
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
