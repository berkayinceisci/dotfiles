#!/bin/bash
# Test matrix for block-nfs-writes.sh — run with: bash block-nfs-writes.test.sh
# Mirrors the cases the OpenCode plugin (block-nfs-writes.test.mjs) is tested
# against, plus the Codex apply_patch cases; keep the two in sync.
set -euo pipefail

HOOK="$(dirname "$0")/block-nfs-writes.sh"
FAIL=0

tc() {
	local expect="$1" json="$2" out rc=0 got=allow
	out=$(printf '%s' "$json" | bash "$HOOK" 2>&1) || rc=$?
	if [[ $rc -eq 2 ]]; then
		got=block
	elif [[ $rc -ne 0 ]]; then
		echo "FAIL [hook error rc=$rc] $json | $out"
		FAIL=1
		return
	fi
	if [[ "$got" == "$expect" ]]; then
		echo "PASS [$expect] ${json:0:90}"
	else
		echo "FAIL [want=$expect got=$got] $json | $out"
		FAIL=1
	fi
}

# File-write tools (Claude Code)
tc block '{"tool_name":"Write","tool_input":{"file_path":"/proj/group/notes.md"}}'
tc allow '{"tool_name":"Write","tool_input":{"file_path":"/home/berkay/notes.md"}}'

# Bash: ssh-wrapped writes to remote shared dirs
tc block '{"tool_name":"Bash","tool_input":{"command":"ssh hds01 '\''cp results.csv /proj/group/x'\''"}}'
tc block '{"tool_name":"Bash","tool_input":{"command":"ssh hds01 '\''echo done > /work/log.txt'\''"}}'
tc block '{"tool_name":"Bash","tool_input":{"command":"ssh hds01 '\''sudo rm -rf /proj/old-results'\''"}}'
tc block '{"tool_name":"Bash","tool_input":{"command":"ssh hds01 '\''tee /share/notes.txt'\''"}}'

# Bash: scp/rsync remote destinations (host:/path)
tc block '{"tool_name":"Bash","tool_input":{"command":"scp data.csv hds01:/share/lab/x.csv"}}'
tc block '{"tool_name":"Bash","tool_input":{"command":"rsync -av ./local-data/ hds01:/proj/data/"}}'

# Bash: reads from shared dirs must pass (read-back direction)
tc allow '{"tool_name":"Bash","tool_input":{"command":"scp hds01:/proj/results.csv ./data/"}}'
tc allow '{"tool_name":"Bash","tool_input":{"command":"rsync -av hds01:/proj/data/ ./local-data/"}}'
tc allow '{"tool_name":"Bash","tool_input":{"command":"ssh hds01 '\''cat /proj/data.csv | head'\''"}}'

# Bash: benign writes elsewhere must pass
tc allow '{"tool_name":"Bash","tool_input":{"command":"mkdir -p /home/berkay/tmp/x"}}'
tc allow '{"tool_name":"Bash","tool_input":{"command":"ssh amd062.cloudlab.us '\''nohup sudo ./exp.sh > /tmp/experiment.log 2>&1 & echo $!'\''"}}'
tc allow '{"tool_name":"Bash","tool_input":{"command":"git status"}}'

# apply_patch (Codex): paths from the patch envelope
tc block '{"tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch\n*** Update File: /proj/group/file.c\n*** End Patch"}}'
tc allow '{"tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch\n*** Update File: /home/berkay/x.c\n*** End Patch"}}'

exit $FAIL
