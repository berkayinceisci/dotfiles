#!/bin/bash
# Require confirmation for dangerous commands on non-cloudlab machines
set -euo pipefail

# Only apply on non-cloudlab machines
if [[ "$(hostname -f 2>/dev/null || hostname)" == *.cloudlab.us ]]; then
	exit 0
fi

ask_permission() {
	local reason="$1"
	jq -n --arg reason "$reason" '{
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": $reason
        }
    }'
	exit 0
}

allow_command() {
	local reason="$1"
	jq -n --arg reason "$reason" '{
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "permissionDecisionReason": $reason
        }
    }'
	exit 0
}

# Decide whether the command is targeting cloudlab (directly or via sourced /
# redirected files). Sets CLOUDLAB_SCRIPT=1 if so.
detect_cloudlab_script() {
	CLOUDLAB_SCRIPT=0
	[[ "$command" == *.cloudlab.us* ]] && { CLOUDLAB_SCRIPT=1; return; }
	local path
	while IFS= read -r path; do
		[[ -z "$path" || ! -r "$path" ]] && continue
		if grep -q '\.cloudlab\.us' "$path" 2>/dev/null; then
			CLOUDLAB_SCRIPT=1
			return
		fi
	done < <(
		{
			# `|| true` so that "no match" (grep exit 1) doesn't kill
			# the subshell under set -e and skip the other extractor.
			grep -oE '<[[:space:]]*[^[:space:]|&;()<>"'"'"'\`]+' <<<"$command" \
				| sed -E 's/^<[[:space:]]*//' || true
			grep -oE '(^|[[:space:]&;(`])(source|\.)[[:space:]]+[^[:space:]|&;()<>"'"'"'\`]+' <<<"$command" \
				| sed -E 's/^[[:space:]&;(`]*(source|\.)[[:space:]]+//' || true
		}
	)
}

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)

# Match a dangerous ERE pattern on lines that are NOT ssh invocations targeting
# a *.cloudlab.us host. Lines containing both `ssh ` and `.cloudlab.us` are
# exempt — the dangerous bits inside such lines run remotely on cloudlab.
danger_check() {
	local pattern="$1"
	# Check the command line-by-line, after joining backslash-continuation lines.
	# Lines that are part of a remote ssh-to-cloudlab invocation are exempt. This
	# includes multi-line quoted scripts: when an `ssh ... .cloudlab.us` line
	# opens a quote that isn't closed on the same line, subsequent lines are
	# considered "inside remote" until the matching closing quote is seen.
	awk -v pat="$pattern" -v cloudlab_script="$CLOUDLAB_SCRIPT" '
		function count_unescaped(s, ch,    i, c, prev, n) {
			n = 0; prev = ""
			for (i = 1; i <= length(s); i++) {
				c = substr(s, i, 1)
				if (c == ch && prev != "\\") n++
				prev = c
			}
			return n
		}
		BEGIN {buf=""; remote_quote=""; remote_heredoc=""; remote_heredoc_dash=0}
		{
			line=$0
			if (buf != "") { line = buf " " line; buf="" }
			if (sub(/\\$/, "", line)) { buf=line; next }

			# Inside a remote heredoc: skip danger check until the
			# terminator line. For <<- variants, leading tabs on the
			# terminator are stripped (per POSIX).
			if (remote_heredoc != "") {
				term = line
				if (remote_heredoc_dash) sub(/^\t+/, "", term)
				if (term == remote_heredoc) {
					remote_heredoc=""; remote_heredoc_dash=0
				}
				next
			}

			# Inside a remote multi-line quoted script: skip danger check,
			# but watch for the closing quote to reset state.
			if (remote_quote != "") {
				if (count_unescaped(line, remote_quote) % 2 == 1) remote_quote=""
				next
			}

			if (line ~ /^[[:space:]]*#/) next
			if (line ~ /^[[:space:]]*$/) next

			# ssh/scp/rsync line targeting cloudlab: exempt. The line
			# qualifies if it contains `.cloudlab.us` directly, OR if
			# the overall command mentions `.cloudlab.us` somewhere
			# (e.g. hostname in a for-loop header, stored in ${h}).
			# If it opens a heredoc or a quote that does not close on
			# the same line, enter "inside remote" state so subsequent
			# lines are also exempt.
			is_remote_cmd = (line ~ /(^|[^a-zA-Z0-9_])(ssh|scp|rsync)[[:space:]]/)
			line_has_cloudlab = (line ~ /\.cloudlab\.us/)
			if (is_remote_cmd && (line_has_cloudlab || cloudlab_script)) {
				# Heredoc: <<[-]?["]?WORD["]?  at end of line (with
				# optional trailing whitespace). The end-of-line
				# anchor avoids misfiring on `<<` inside a closed
				# single-line quoted script.
				hd_pat = "<<-?[ \t]*[\"\x27]?[A-Za-z_][A-Za-z0-9_]*[\"\x27]?[ \t]*$"
				if (match(line, hd_pat)) {
					# Only a real heredoc if the << is outside any
					# quoted region (quotes balanced before RSTART).
					pre = substr(line, 1, RSTART - 1)
					if (count_unescaped(pre, "\x27") % 2 == 0 && \
					    count_unescaped(pre, "\"") % 2 == 0) {
						hd = substr(line, RSTART, RLENGTH)
						remote_heredoc_dash = (hd ~ /^<<-/) ? 1 : 0
						sub("^<<-?[ \t]*[\"\x27]?", "", hd)
						sub("[\"\x27]?[ \t]*$", "", hd)
						remote_heredoc = hd
						next
					}
				}
				if (count_unescaped(line, "\x27") % 2 == 1) remote_quote="\x27"
				else if (count_unescaped(line, "\"") % 2 == 1) remote_quote="\""
				next
			}

			if (line ~ pat) { found=1; exit }
		}
		END {exit(found ? 0 : 1)}
	' <<<"$command"
}

if [[ "$tool_name" == "Bash" ]]; then
	command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

	detect_cloudlab_script

	# sudo anywhere in command
	if danger_check '(^|[^a-zA-Z0-9_])sudo([^a-zA-Z0-9_]|$)'; then
		ask_permission "sudo requires your approval"
	fi

	# rm -rf
	if danger_check '(^|[^a-zA-Z0-9_])rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f|rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r'; then
		ask_permission "rm -rf requires your approval"
	fi

	# mkfs
	if danger_check '(^|[^a-zA-Z0-9_])mkfs'; then
		ask_permission "mkfs requires your approval"
	fi

	# dd (match only actual dd commands with key=value args, not variables named dd)
	if danger_check '(^|[^a-zA-Z0-9_])dd[[:space:]]+[a-z]+='; then
		ask_permission "dd requires your approval"
	fi

	# chmod -R
	if danger_check '(^|[^a-zA-Z0-9_])chmod[[:space:]]+-[a-zA-Z]*R'; then
		ask_permission "chmod -R requires your approval"
	fi

	# chown -R
	if danger_check '(^|[^a-zA-Z0-9_])chown[[:space:]]+-[a-zA-Z]*R'; then
		ask_permission "chown -R requires your approval"
	fi

	# No local danger and command targets cloudlab — auto-allow so Claude
	# Code's default Bash permission doesn't ask either.
	if [[ "$CLOUDLAB_SCRIPT" == "1" ]]; then
		allow_command "cloudlab-targeting command: auto-allowed"
	fi
fi

exit 0
