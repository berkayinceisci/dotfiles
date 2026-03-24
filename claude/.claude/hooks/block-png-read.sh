#!/bin/bash
# Block reading/processing PNG files — require user approval.
# Hooks receive tool input as JSON on stdin.
# For Read tool: JSON has "file_path"
# For Bash tool: JSON has "command"

input=$(cat)

# Check Read tool: file_path ends with .png
file_path=$(echo "$input" | jq -r '.file_path // empty')
if [[ -n "$file_path" && "$file_path" == *.png ]]; then
	echo "BLOCKED: Reading PNG file: $file_path"
	echo "PNG images consume significant context. Consider using the PDF version instead."
	exit 2
fi

# Check Bash tool: command references .png files (Image.open, open(), cat, etc.)
command=$(echo "$input" | jq -r '.command // empty')
if [[ -n "$command" ]] && echo "$command" | grep -qE '\.png'; then
	echo "BLOCKED: Bash command references PNG file(s)."
	echo "PNG images consume significant context. Consider using the PDF version instead."
	exit 2
fi
