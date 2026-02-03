#!/bin/bash
# Block writes to any NFS-mounted filesystem
set -euo pipefail

# Get NFS mount points once (fast: just reads /proc/mounts)
NFS_MOUNTS=()
while IFS=' ' read -r _ mountpoint fstype _; do
    [[ "$fstype" == "nfs" || "$fstype" == "nfs4" ]] && NFS_MOUNTS+=("$mountpoint")
done < /proc/mounts 2>/dev/null

# No NFS mounts? Exit immediately
[[ ${#NFS_MOUNTS[@]} -eq 0 ]] && exit 0

is_under_nfs() {
    local path="$1"
    for mount in "${NFS_MOUNTS[@]}"; do
        [[ "$path" == "$mount"* ]] && return 0
    done
    return 1
}

input=$(cat)
tool_name="${CLAUDE_TOOL_NAME:-}"

case "$tool_name" in
    Write|Edit)
        file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
        if [[ -n "$file_path" ]] && is_under_nfs "$file_path"; then
            echo "BLOCKED: Cannot write to NFS filesystem: $file_path"
            exit 2
        fi
        ;;
    Bash)
        command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
        # Check paths in redirects
        for path in $(echo "$command" | grep -oE '>>?\s*/[^ ">|;&]+' | grep -oE '/[^ ">|;&]+' || true); do
            if is_under_nfs "$path"; then
                echo "BLOCKED: Redirect targets NFS filesystem: $path"
                exit 2
            fi
        done
        # Check destination of write commands (last path argument)
        if [[ "$command" =~ (^|[;&|])[[:space:]]*(cp|mv|rsync|scp)[[:space:]] ]]; then
            # Get last absolute path (the destination)
            dest=$(echo "$command" | grep -oE '/[^ ">|;&]+' | tail -1 || true)
            if [[ -n "$dest" ]] && is_under_nfs "$dest"; then
                echo "BLOCKED: Write command destination is NFS: $dest"
                exit 2
            fi
        fi
        # Commands where all path args are destinations
        if [[ "$command" =~ (^|[;&|])[[:space:]]*(tee|dd|touch|mkdir|rm|rmdir)[[:space:]] ]]; then
            for path in $(echo "$command" | grep -oE '/[^ ">|;&]+' || true); do
                if is_under_nfs "$path"; then
                    echo "BLOCKED: Write command targets NFS: $path"
                    exit 2
                fi
            done
        fi
        ;;
esac

exit 0
