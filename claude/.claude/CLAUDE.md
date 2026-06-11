@~/.agents/core.md

# Claude Code Specifics

<!-- This file = the shared, harness-agnostic core (imported above) + the
     Claude-Code-only tooling below. Edit shared rules in ~/.agents/core.md so
     Codex and OpenCode pick them up too; keep only Claude-Code-tool-specific
     instructions (subagent discipline) here. -->

## Subagent Discipline

<!-- The portable delegation principle lives in core.md ("Subagent Delegation");
     only Claude-Code-specific rules below. -->
- Under ~150k context: prefer inline work for tasks under ~5 tool calls.
- Over ~150k context: prefer subagents for self-contained tasks, even simple ones — the per-call token tax on large contexts adds up fast.
- Never call TaskOutput twice for the same subagent. If it times out, increase the timeout — don't re-read.
