# Auto Mode — soft_deny rules

Scratchpad for `autoMode.soft_deny` rules in `~/.claude/settings.json`.

Soft-deny = blocked by default, but explicit user intent in this session can
override. Use for "usually wrong, occasionally right" actions where you trust
your own clearly-stated request to flip the switch.

When this list stabilizes, translate to a JSON array under
`autoMode.soft_deny` in `claude/.claude/settings.json`, prefixed with
`"$defaults"` so the built-in rules still apply.

## Rules

- Never create git commits unless I explicitly asked for one in this session.
  `git commit --amend`, `git rebase -i`, and any squash/fixup that rewrites
  committed history count too.

- Never push to a git remote unless I explicitly asked. Force-push is already
  covered by `$defaults`, but plain `git push` is not.

<!-- Add more here as we work through it. Candidates we've discussed:
- mkfs, dd if=/of=/dev/*
- rm -rf of $HOME, /, mounted disks
- sudo shutdown|reboot|halt|poweroff
-->
