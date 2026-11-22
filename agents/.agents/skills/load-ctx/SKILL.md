---
name: load-ctx
description: Resume work from a context file written by save-ctx. Use when the user invokes load-ctx, asks to load saved context, resume from a handoff note, or continue work that another session or another agent harness saved.
---

# Load Context

Resume work from a handoff note that the `save-ctx` skill wrote to
`context-saves/` in the current working directory.

## Pick the file

If the user named a file, use it. Otherwise list
`context-saves/context-*.md` and take the newest one; the timestamp in the file
name sorts chronologically. Tell the user which file was chosen. If several
were written within the last day, list them and say which one was picked. If
`context-saves/` is missing or empty, say so and stop.

## Read and verify

Read the whole file. Then check it against the workspace before acting on it:

- Run `git status --short` and `git diff --stat` (plus
  `git diff --cached --stat` when something is staged) if this is a git
  repository.
- Compare the result with the note's Changes Made and Current State sections,
  and the branch and last commit if the note records them.
- If they disagree, trust the files, and tell the user what differs before
  doing anything else. Work may have continued after the note was written.

## Continue

Treat the note's Standing Instructions as instructions from the user for this
session. Give a short summary: the objective, the current state, and the next
step from Remaining Work. Then:

- If the user asked to continue, start on Remaining Work.
- If the note lists blockers that need user input, or the workspace check found
  a mismatch, ask about those first.

Do not delete or edit the context file.
