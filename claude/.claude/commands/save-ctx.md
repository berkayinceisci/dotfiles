Write a detailed context summary to a markdown file at `cc-context-saves/context-YYYY-MM-DD-HHMMSS.md` in the current working directory (create the directory if needed, use the current timestamp).

This command is used when the context window is getting full and we need to preserve the current state of work so a fresh session can pick up where we left off.

The summary MUST include ALL of the following sections:

## Objective
What is the overall goal/task we are working on?

## Decisions Made
List every technical decision, design choice, or user preference established during this session. Include the reasoning behind each decision.

## Changes Made
List every file created, modified, or deleted. For each, briefly describe what changed and why. Include paths.

## Current State
Where did we leave off? What was the last thing completed? What is the current state of the codebase relative to the goal?

## Blockers & Issues
Any problems encountered, unresolved errors, open questions, or things that need user input.

## Remaining Work
Concrete list of what still needs to be done to complete the objective. Be specific — include file paths, function names, and implementation details where known.

## Key Context
Any non-obvious information a fresh session would need: quirks discovered, gotchas, environment details, relevant file locations, patterns in the codebase, etc.

---

After writing the file, display the full contents of the saved file to the user.
