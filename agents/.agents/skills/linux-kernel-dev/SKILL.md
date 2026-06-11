---
name: linux-kernel-dev
description: Linux kernel development conventions - incremental compilation, code review focus areas (memory, concurrency, performance), common pitfalls (reference counting, THP, hugetlb), and kernel commit message format. Use when writing, reviewing, debugging, or committing Linux kernel code.
---

# Linux Kernel Development

## Incremental Compilation

```bash
ssh $REMOTE_HOST 'make -j$(nproc) mm/file.o'
```

## Code Review Focus Areas

1. **Logic**: Missing error checks, incorrect returns
2. **Memory**: Reference counting (one put per get), leaks, UAF
3. **Concurrency**: TOCTOU, missing locks
4. **Performance**: O(n) loops, stack overflow (use `kvcalloc` for large arrays)
5. **Edge Cases**: Empty lists, zero values, THP (use `folio_nr_pages()`)

## Common Pitfalls

| Issue | Rule |
|-|-|
| Reference counting | Audit ALL exit paths for exactly one put per get |
| Large stack arrays | Use `kvcalloc()`/`kvfree()` if size depends on config |
| THP accounting | Never assume page count is 1 |
| Hugetlb | Separate accounting, different putback routines |

## Kernel Commit Format

```
subsystem: brief description

1. What was wrong
2. Root cause
3. How this fixes it
```
