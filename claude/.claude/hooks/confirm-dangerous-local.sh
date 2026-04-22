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

# Decide whether the command is targeting a trusted remote — either cloudlab
# (directly or via sourced / redirected files) or a port-forwarded local VM
# reached through an ssh-wrapper script. Sets REMOTE_TRUSTED=1 if so.
detect_trusted_remote_script() {
	REMOTE_TRUSTED=0
	[[ "$command" == *.cloudlab.us* ]] && { REMOTE_TRUSTED=1; return; }
	local path
	while IFS= read -r path; do
		# Expand leading ~/ (hook receives the raw command string).
		path="${path/#\~/$HOME}"
		[[ -z "$path" || ! -f "$path" || ! -r "$path" ]] && continue
		# cloudlab target anywhere in the file.
		if grep -q '\.cloudlab\.us' "$path" 2>/dev/null; then
			REMOTE_TRUSTED=1
			return
		fi
		# Port-forwarded local VM: an ssh/scp/rsync line targeting
		# localhost (or 127.0.0.1 / [::1]) on a specified port — the
		# standard qemu/vagrant/virtualbox wrapper pattern. Join
		# backslash-continuation lines first so the check still fires
		# when the ssh invocation is wrapped across multiple lines.
		if awk '
			BEGIN { buf = "" }
			{
				line = $0
				if (sub(/\\$/, "", line)) { buf = buf line " "; next }
				line = buf line; buf = ""
				if (line ~ /(^|[^[:alnum:]_])(ssh|scp|rsync)[[:space:]]/ &&
				    line ~ /(localhost|127\.0\.0\.1|\[::1\])/ &&
				    line ~ /-p[[:space:]]/) { found = 1; exit }
			}
			END { exit(found ? 0 : 1) }
		' "$path" 2>/dev/null; then
			REMOTE_TRUSTED=1
			return
		fi
	done < <(
		{
			# `|| true` so that "no match" (grep exit 1) doesn't kill
			# the subshell under set -e and skip the other extractors.
			grep -oE '<[[:space:]]*[^[:space:]|&;()<>"'"'"'\`]+' <<<"$command" \
				| sed -E 's/^<[[:space:]]*//' || true
			grep -oE '(^|[[:space:]&;(`])(source|\.)[[:space:]]+[^[:space:]|&;()<>"'"'"'\`]+' <<<"$command" \
				| sed -E 's/^[[:space:]&;(`]*(source|\.)[[:space:]]+//' || true
			# Path-like tokens (absolute, relative, or ~-prefixed) so
			# that ssh-wrapper scripts passed as the command's first
			# argument are inspected too.
			grep -oE '(^|[[:space:]&;(`])(/|\./|\.\./|~/)[^[:space:]|&;()<>"'"'"'\`]+' <<<"$command" \
				| sed -E 's/^[[:space:]&;(`]+//' || true
		}
	)
}

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)

# Match a dangerous ERE pattern on lines that are NOT ssh invocations targeting
# a trusted remote (a *.cloudlab.us host or a port-forwarded local VM). Lines
# that contain `ssh ` and target a trusted remote are exempt — the dangerous
# bits inside such lines run on the remote, not locally.
danger_check() {
	local pattern="$1"
	# Check the command line-by-line, after joining backslash-continuation lines.
	# Lines that are part of a remote ssh-to-trusted-target invocation are
	# exempt. This includes multi-line quoted scripts: when an `ssh ...`
	# line opens a quote that isn't closed on the same line, subsequent
	# lines are considered "inside remote" until the matching closing
	# quote is seen.
	awk -v pat="$pattern" -v remote_trusted="$REMOTE_TRUSTED" '
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

			# ssh/scp/rsync line targeting a trusted remote: exempt.
			# The line qualifies if it contains `.cloudlab.us` directly,
			# OR if the overall command has been pre-classified as
			# targeting a trusted remote (cloudlab hostname anywhere
			# in a sourced/redirected/path-argument file, or an ssh
			# wrapper that targets a port-forwarded local VM).
			# If it opens a heredoc or a quote that does not close on
			# the same line, enter "inside remote" state so subsequent
			# lines are also exempt.
			is_remote_cmd = (line ~ /(^|[^a-zA-Z0-9_])(ssh|scp|rsync)[^[:space:]]*[[:space:]]/)
			line_has_cloudlab = (line ~ /\.cloudlab\.us/)
			if (is_remote_cmd && (line_has_cloudlab || remote_trusted)) {
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

	detect_trusted_remote_script

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

	# No local danger and command targets a trusted remote (cloudlab or a
	# port-forwarded local VM) — auto-allow so Claude Code's default Bash
	# permission doesn't ask either.
	if [[ "$REMOTE_TRUSTED" == "1" ]]; then
		allow_command "trusted-remote-targeting command: auto-allowed"
	fi
fi

exit 0
