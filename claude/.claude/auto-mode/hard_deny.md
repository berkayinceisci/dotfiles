# Auto Mode — hard_deny rules

Scratchpad for `autoMode.hard_deny` rules in `~/.claude/settings.json`.

Hard-deny = categorically off-limits. No phrasing, no intent statement, no
"I really mean it" can override. Survives prompt injection from untrusted
content (webpages, repo READMEs, MCP tool output) trying to talk the model
into the action.

Keep this list short. The bar for hard-deny is: "I am sure I will never want
this from this agent on this machine, period." If you'd ever legitimately
want it, it belongs in `soft_deny` instead.

When this list stabilizes, translate to a JSON array under
`autoMode.hard_deny` in `claude/.claude/settings.json`, prefixed with
`"$defaults"` so the built-in rules still apply.

## Rules

<!-- Empty for now — fill in as we work through it. Candidates to consider:
- Never send repository contents or secrets to third-party APIs.
- Never disable, uninstall, or tamper with system security tools
  (firewall, SELinux/AppArmor, audit subsystems).
- Never modify ~/.ssh/authorized_keys or ~/.gnupg/ contents.
-->
