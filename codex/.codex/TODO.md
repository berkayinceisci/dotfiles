# Codex TODOs

## config.toml runtime-state pollution (stow)
- **Problem:** Codex writes local runtime state into `~/.codex/config.toml`.
  In a stowed dotfiles setup, that path is the tracked source file
  `codex/.codex/config.toml`, so machine-local state shows up in `git status`.
- **Observed local state:** Codex currently writes project trust entries like:
  ```toml
  [projects."/home/berkay/dotfiles"]
  trust_level = "trusted"
  ```
  It also writes hook trust/cache entries under `[hooks.state...]`, for example
  hashes for configured `PreToolUse` hooks. Treat both as local runtime state,
  not portable dotfiles configuration.
- **Rejected mitigation:** Do not solve this by launching Codex with an alternate
  `CODEX_HOME`. That makes the wrapper diverge from `cc-with-session-logging`,
  causes config drift, and can hide normal TUI settings such as `status_line`.
- **Mitigation in place:** `codex-with-untracked-state` is only a session-logging
  wrapper again and runs Codex with the normal `~/.codex` config. Git ignores
  runtime-only sections through the `codex-runtime` clean filter in
  `git/.gitconfig`, gated by this repo's `.gitattributes`:
  ```gitattributes
  codex/.codex/config.toml filter=codex-runtime
  ```
  The filter strips `[projects...]` and `[hooks.state...]` before Git stores or
  compares `config.toml`; Codex can still keep those sections in the live file.
- **Upstream tracking:**
  - #14601 (open) — asks Codex to stop appending project trust metadata to
    `~/.codex/config.toml` and move it to a dedicated project-state file.
    https://github.com/openai/codex/issues/14601
  - #15433 (closed) — duplicate/similar request to separate project trust state
    from global config so `~/.codex/config.toml` can be VCS-managed.
    https://github.com/openai/codex/issues/15433
- **Action:** keep the local Git clean filter until Codex moves project trust
  and hook trust/cache state out of `config.toml`. If upstream only fixes
  `[projects...]`, keep filtering `[hooks.state...]` unless Codex also moves
  hook state to a separate local file.
