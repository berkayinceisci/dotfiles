# Global Claude Code Instructions

## Core Principles

- Never delete any comments while doing updates.
- Only make changes that are directly requested - do not add "improvements" or modifications based on assumptions about what would be better.
- Never fabricate information (papers, authors, venues, results). Use `[[TODO: need source]]` when unsure.
- Distinguish observations from hypotheses. Don't state inferences as facts or invent specific numbers (e.g., rate limits, thresholds) without verification. Search for sources before making claims, not after being challenged.
- Follow existing code conventions in each project.
- Test changes before marking tasks complete.
- Be concise and direct.

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

## Git Commits

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
