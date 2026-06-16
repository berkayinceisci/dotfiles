#!/bin/bash
# Block writes to NFS/shared filesystems:
#   1. Local NFS mounts on the control machine (detected from /proc/mounts).
#   2. Shared directories on remote experiment hosts (cloudlab /proj, lab
#      /share, /work, ...) — these cannot be probed at hook time, so they are
#      matched by path prefix, including inside ssh-wrapped commands and
#      scp/rsync host:/path destinations.
#
# Used as a PreToolUse hook by BOTH Claude Code and Codex — the stdin JSON
# contract is the same (tool_name + tool_input):
#   Claude Code: settings.json    matcher Write|Edit|Bash
#   Codex:       config.toml      matcher ^Bash$|^apply_patch$
# Blocks by printing a reason to stderr and exiting 2.
#
# -v / BLOCK_NFS_VERBOSE=1: log detection results and chosen branches to stderr.
set -euo pipefail

VERBOSE=0
if [[ "${1:-}" == "-v" || "${BLOCK_NFS_VERBOSE:-0}" == "1" ]]; then
	VERBOSE=1
fi

vlog() {
	if [[ $VERBOSE -eq 1 ]]; then
		echo "block-nfs-writes: $*" >&2
	fi
}

# Get local NFS mount points once (fast: just reads /proc/mounts; absent on macOS)
NFS_MOUNTS=()
if [[ -r /proc/mounts ]]; then
	while IFS=' ' read -r _ mountpoint fstype _; do
		if [[ "$fstype" == "nfs" || "$fstype" == "nfs4" ]]; then
			NFS_MOUNTS+=("$mountpoint")
		fi
	done </proc/mounts
fi
vlog "local NFS mounts: ${NFS_MOUNTS[*]:-none}"

# Remote shared-directory prefixes. Remote mounts cannot be probed per tool
# call, so block by convention: the shared-NFS policy names /proj/* (cloudlab),
# /share/*, /work/* as shared partitions on any host. Extend per-site via the
# conf file (one absolute prefix per line, # comments).
REMOTE_PREFIXES=(/proj /share /work)
PREFIX_CONF="$HOME/.agents/hooks/nfs-remote-prefixes.conf"
if [[ -r "$PREFIX_CONF" ]]; then
	while IFS= read -r line; do
		line="${line%%#*}"
		line="${line//[[:space:]]/}"
		if [[ -n "$line" ]]; then
			REMOTE_PREFIXES+=("$line")
		fi
	done <"$PREFIX_CONF"
fi
vlog "remote shared prefixes: ${REMOTE_PREFIXES[*]}"

is_blocked_path() {
	local path="$1"
	# Strip scp/rsync "host:" remote specifier so host:/proj/... checks as /proj/...
	path="${path#*:}"
	local mount prefix
	# Guard the array expansion: macOS ships bash 3.2, where "${arr[@]}" on an
	# empty array under `set -u` errors as "unbound variable" (fixed in 4.4).
	# NFS_MOUNTS is empty on macOS (no /proc/mounts), so loop only when non-empty.
	if [[ ${#NFS_MOUNTS[@]} -gt 0 ]]; then
		for mount in "${NFS_MOUNTS[@]}"; do
			if [[ "$path" == "$mount" || "$path" == "$mount"/* ]]; then
				return 0
			fi
		done
	fi
	for prefix in "${REMOTE_PREFIXES[@]}"; do
		if [[ "$path" == "$prefix" || "$path" == "$prefix"/* ]]; then
			return 0
		fi
	done
	return 1
}

block() {
	echo "BLOCKED: $1" >&2
	exit 2
}

input=$(cat)
# Tool name is passed in JSON, not as env var
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)
vlog "tool_name=$tool_name"

case "$tool_name" in
Write | Edit)
	file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
	vlog "branch=Write/Edit file_path=$file_path"
	if [[ -n "$file_path" ]] && is_blocked_path "$file_path"; then
		block "Cannot write to NFS/shared filesystem: $file_path"
	fi
	;;
apply_patch)
	# Codex file edits: target paths appear in the patch envelope as
	# "*** Update File: <path>" / "*** Add File: <path>" / "*** Delete File: <path>"
	patch=$(echo "$input" | jq -r '.tool_input.command // .tool_input.patch // empty' 2>/dev/null || true)
	vlog "branch=apply_patch"
	while IFS= read -r path; do
		if [[ -n "$path" ]] && is_blocked_path "$path"; then
			block "Patch targets NFS/shared filesystem: $path"
		fi
	done < <(echo "$patch" | grep -oE '^\*\*\* (Update|Add|Delete) File: .+$' | sed 's/^\*\*\* [A-Za-z]* File: //' || true)
	;;
Bash)
	command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
	vlog "branch=Bash"
	# Check paths in redirects (also matches redirects inside ssh '...' strings)
	while IFS= read -r path; do
		if [[ -n "$path" ]] && is_blocked_path "$path"; then
			block "Redirect targets NFS/shared filesystem: $path"
		fi
	done < <(echo "$command" | grep -oE '>>?[[:space:]]*/[^ ">|;&]+' | grep -oE '/[^ ">|;&]+' || true)
	# Check destination of write commands (last path argument). The leading
	# delimiter set includes quotes/whitespace so commands wrapped in
	# ssh '...' match too; paths may be plain (/path) or remote (host:/path).
	if echo "$command" | grep -qE "(^|[;&|'\"[:space:]])(sudo[[:space:]]+)?(cp|mv|rsync|scp)[[:space:]]"; then
		# Last path-like token = destination. Deliberately unfiltered: a relative
		# dest (./data/) must win over an absolute/remote source (host:/proj/...),
		# otherwise copying FROM a shared dir back to local would false-positive.
		dest=$(echo "$command" | grep -oE "[^ \">|;&']*/[^ \">|;&']+" | tail -1 || true)
		vlog "copy-style dest=$dest"
		if [[ -n "$dest" ]] && is_blocked_path "$dest"; then
			block "Write command destination is NFS/shared: $dest"
		fi
	fi
	# Commands where all path args are destinations
	if echo "$command" | grep -qE "(^|[;&|'\"[:space:]])(sudo[[:space:]]+)?(tee|dd|touch|mkdir|rm|rmdir)[[:space:]]"; then
		while IFS= read -r path; do
			if [[ -n "$path" ]] && is_blocked_path "$path"; then
				block "Write command targets NFS/shared filesystem: $path"
			fi
		done < <(echo "$command" | grep -oE "[^ \">|;&']*/[^ \">|;&']+" | grep -E '^(/|[^ /]+:/)' || true)
	fi
	;;
esac

exit 0
