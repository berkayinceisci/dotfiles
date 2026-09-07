#!/bin/bash
# Lint the file that was just written/edited, and block on real errors.
#
# Used as a PostToolUse hook by Claude Code (settings.json, matcher Edit|Write).
# Reads the tool call JSON on stdin and takes .tool_input.file_path.
# Blocks by printing the linter output to stderr and exiting 2, so the agent
# sees the diagnostics and fixes them instead of moving on.
#
# The file type is resolved by extension first, then — for extensionless files
# such as ~/.local/scripts/* — by sniffing the shebang.
#
# Severity: shellcheck runs at -S warning. Notes and style hints (SC2012,
# SC1090, SC2016 ...) are advice, not breakage, and blocking an edit on them
# is just noise. This mirrors the ruff selection below, likewise
# correctness-only.
#
# -v / LINT_EDITED_FILE_VERBOSE=1: log the resolved type and chosen linter.
set -euo pipefail

# Lines of linter output kept before truncating; the rest is summarised.
MAX_LINT_LINES=20
MAX_SYNTAX_LINES=5

VERBOSE=0
if [[ "${1:-}" == "-v" || "${LINT_EDITED_FILE_VERBOSE:-0}" == "1" ]]; then
	VERBOSE=1
fi

vlog() {
	if [[ $VERBOSE -eq 1 ]]; then
		echo "lint-edited-file: $*" >&2
	fi
}

# Never block an edit just because the hook's own dependencies are missing.
if ! command -v jq >/dev/null 2>&1; then
	vlog "jq not found, skipping"
	exit 0
fi

filepath=$(jq -r ".tool_input.file_path // empty")
if [[ -z "$filepath" || ! -f "$filepath" ]]; then
	vlog "no readable file_path in tool input, skipping"
	exit 0
fi

# Print linter output (truncated to $2 lines) and block.
emit() {
	local out="$1" max="$2" n
	# Here-strings, not pipes: head exits after $max lines, and a pipe would
	# give the writer SIGPIPE (141) once output exceeds the 64K pipe buffer,
	# which pipefail + set -e would turn into a silent non-2 exit.
	n=$(wc -l <<<"$out" | tr -d "[:space:]")
	head -n "$max" <<<"$out" >&2
	if [[ $n -gt $max ]]; then
		echo "... $((n - max)) more lines suppressed" >&2
	fi
	exit 2
}

# --- Resolve file type ------------------------------------------------------
# kind: shell (shellcheck) | python (ruff) | zsh (zsh -n) | bash (bash -n)
# The rc files get a syntax check rather than shellcheck: they are interactive
# config, and shellcheck floods them with style warnings that do not apply.
kind=""
case "$filepath" in
*.zshrc) kind=zsh ;;
*.bashrc) kind=bash ;;
*.sh | *.bash) kind=shell ;;
*.zsh) kind=zsh ;;
*.py) kind=python ;;
esac

if [[ -n "$kind" ]]; then
	vlog "type from extension: $kind ($filepath)"
else
	# Extensionless (or unknown extension): sniff the shebang. zsh is checked
	# before the generic shell patterns since shellcheck cannot parse zsh.
	shebang=$(head -n 1 "$filepath" 2>/dev/null || true)
	case "$shebang" in
	'#!'*zsh*) kind=zsh ;;
	'#!'*python*) kind=python ;;
	'#!'*bash* | '#!'*dash* | '#!'*ksh*) kind=shell ;;
	# Plain sh needs the trailing-argument forms spelled out: unlike the
	# *bash*/*ksh* patterns above, these anchor at 'sh' so that #!/bin/shy
	# does not match, which also excludes '#!/bin/sh -e' without them.
	'#!'*/sh | '#!'*/sh[[:space:]]* | '#!'*[[:space:]]sh | '#!'*[[:space:]]sh[[:space:]]*) kind=shell ;;
	esac
	if [[ -z "$kind" ]]; then
		vlog "no extension or shebang match, skipping ($filepath)"
		exit 0
	fi
	vlog "type from shebang '$shebang': $kind ($filepath)"
fi

# --- Run the linter ---------------------------------------------------------
case "$kind" in
shell)
	if ! command -v shellcheck >/dev/null 2>&1; then
		vlog "shellcheck not installed, skipping"
		exit 0
	fi
	vlog "running: shellcheck -S warning -f gcc $filepath"
	if ! out=$(shellcheck -S warning -f gcc "$filepath" 2>&1); then
		emit "$out" "$MAX_LINT_LINES"
	fi
	;;
python)
	if command -v ruff >/dev/null 2>&1; then
		vlog "running: ruff check --select F821,F811,F632,E9 $filepath"
		if ! out=$(ruff check --select F821,F811,F632,E9 --output-format concise "$filepath" 2>&1); then
			emit "$out" "$MAX_LINT_LINES"
		fi
	else
		vlog "ruff not installed, falling back to: python3 -m py_compile $filepath"
		if ! out=$(python3 -m py_compile "$filepath" 2>&1); then
			emit "$out" "$MAX_LINT_LINES"
		fi
	fi
	;;
zsh)
	if ! command -v zsh >/dev/null 2>&1; then
		vlog "zsh not installed, skipping"
		exit 0
	fi
	vlog "running: zsh -n $filepath"
	if ! out=$(zsh -n "$filepath" 2>&1); then
		emit "$out" "$MAX_SYNTAX_LINES"
	fi
	;;
bash)
	vlog "running: bash -n $filepath"
	if ! out=$(bash -n "$filepath" 2>&1); then
		emit "$out" "$MAX_SYNTAX_LINES"
	fi
	;;
esac

vlog "clean: $filepath"
exit 0
