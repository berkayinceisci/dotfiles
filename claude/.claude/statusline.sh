#!/bin/bash

# Custom Claude Code Statusline
# Capsule-style display showing: directory, git branch, model, context %, tokens, 5h/7d usage, session cost

# Honor CLAUDE_CONFIG_DIR so a secondary account (e.g. the business profile run
# with CLAUDE_CONFIG_DIR=$HOME/.claude-moatlab) reads its own credentials and
# keeps a separate usage cache instead of clobbering the personal account's.
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CACHE_FILE="/tmp/claude-usage-cache-${CLAUDE_CONFIG_DIR##*/}"
CACHE_TTL=120 # seconds

# A cached reading may be shown after a failed fetch only while it is this
# young; past that the display says "?" rather than asserting a number that is
# no longer known to be true.
MAX_STALE_AGE=600 # seconds
# A cached *failure* is retried much sooner than a cached reading, so a
# transient error does not pin the display to "?" for the full CACHE_TTL.
FAIL_TTL=20 # seconds
# Encoding of "no usage data available" in the cache file / get_usage output.
UNKNOWN="|||"

# Claude Code refreshes the OAuth token shortly AFTER process start (observed
# ~200ms) but spawns this statusline immediately, so the first render of a
# session that sat idle past the token lifetime would otherwise read an already
# expired token, get a 401, and fall back to the previous session's numbers.
# Wait out that window instead.
CREDS_RETRIES=15
CREDS_POLL_SECS=0.1

VERBOSE=0
for arg in "$@"; do
	case "$arg" in
	-v | --verbose) VERBOSE=1 ;;
	esac
done

# Log a branch decision to stderr under -v (never to stdout: that is the bar)
log() {
	if ((VERBOSE)); then
		echo "statusline: $*" >&2
	fi
	return 0
}

# Powerline characters for capsule edges (require Nerd Font)
# U+E0B6 = left rounded, U+E0B4 = right rounded
LEFT_CAP=$(printf '\xee\x82\xb6')
RIGHT_CAP=$(printf '\xee\x82\xb4')

# ANSI color codes
RESET="\033[0m"
BOLD="\033[1m"

# Background colors (distinct for each segment)
BG_BLUE="\033[48;5;33m"     # Directory - bright blue
BG_MAGENTA="\033[48;5;133m" # Git - purple/magenta
BG_CYAN="\033[48;5;37m"     # Model - teal
BG_ORANGE="\033[48;5;208m"  # Context - orange
BG_GREEN="\033[48;5;71m"    # Tokens - green
BG_PINK="\033[48;5;168m"    # 5h usage - pink
BG_PURPLE="\033[48;5;98m"   # 7d usage - deep purple
BG_VIOLET="\033[48;5;135m"  # Fable weekly usage - orchid
BG_GRAY="\033[48;5;240m"    # Cost - gray

# Foreground colors (for text)
FG_WHITE="\033[97m"

# Foreground colors matching backgrounds (for capsule edges)
FG_BLUE="\033[38;5;33m"
FG_MAGENTA="\033[38;5;133m"
FG_CYAN="\033[38;5;37m"
FG_ORANGE="\033[38;5;208m"
FG_GREEN="\033[38;5;71m"
FG_PINK="\033[38;5;168m"
FG_PURPLE="\033[38;5;98m"
FG_VIOLET="\033[38;5;135m"
FG_GRAY="\033[38;5;240m"

# Warning colors
BG_YELLOW="\033[48;5;220m"
BG_RED="\033[48;5;196m"
FG_YELLOW="\033[38;5;220m"
FG_RED="\033[38;5;196m"

# Read stdin JSON
input=$(cat)

# Parse Claude Code data with jq
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty' | sed 's/ (1M context)//')
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
# Get raw token counts for precise context display
context_used_tokens=$(echo "$input" | jq -r '((.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0))')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Format directory (shorten home path)
if [[ -n "$cwd" ]]; then
	home_dir="${HOME:-$(eval echo ~)}"
	display_dir=$(echo "$cwd" | sed "s|^$home_dir|~|")
	# Shorten to last 2 components if too long
	if [[ ${#display_dir} -gt 30 ]]; then
		display_dir="…/$(basename "$(dirname "$cwd")")/$(basename "$cwd")"
	fi
else
	display_dir="~"
fi

# Get git branch
if [[ -n "$cwd" ]]; then
	branch=$(git --no-optional-locks -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Check if repo is dirty (any changes: staged, unstaged, or untracked)
git_dirty=""
if [[ -n "$cwd" && -n "$branch" ]]; then
	if [[ -n $(git --no-optional-locks -C "$cwd" status --porcelain 2>/dev/null) ]]; then
		git_dirty="*"
	fi
fi

# Parse an ISO 8601 timestamp into epoch seconds; empty output if unparseable
to_epoch() {
	local ts=$1
	if [[ -z "$ts" ]]; then
		echo ""
		return 1
	fi

	local epoch
	# Try GNU date first, then BSD date (macOS)
	epoch=$(date -d "$ts" +%s 2>/dev/null)
	if [[ -z "$epoch" ]]; then
		# BSD date (macOS): parse ISO 8601 format
		# Strip fractional seconds and convert +00:00 to +0000
		local clean_ts=$(echo "$ts" | sed -E 's/\.[0-9]+//; s/:([0-9]{2})$/\1/')
		epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$clean_ts" +%s 2>/dev/null)
	fi
	if [[ -z "$epoch" ]]; then
		return 1
	fi
	echo "$epoch"
}

# Read the raw credentials blob from the platform's store
read_creds() {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		# macOS - use Keychain
		security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null
	else
		# Linux - read from credentials file (honor CLAUDE_CONFIG_DIR set above)
		local creds_file="$CLAUDE_CONFIG_DIR/.credentials.json"
		if [[ -f "$creds_file" ]]; then
			cat "$creds_file"
		fi
	fi
}

# Read credentials, waiting briefly for Claude Code to replace an expired token
# (see CREDS_RETRIES above). Always echoes whatever was last read so a wrong
# expiresAt or a skewed clock cannot permanently suppress the fetch; returns
# non-zero when the token it echoes is still expired.
get_fresh_creds() {
	local attempt=0 creds expires_at now_ms
	while :; do
		creds=$(read_creds)
		if [[ -z "$creds" ]]; then
			echo ""
			return 1
		fi

		expires_at=$(echo "$creds" | jq -r '.claudeAiOauth.expiresAt // empty' 2>/dev/null)
		# No expiry recorded means there is nothing to wait for
		if [[ ! "$expires_at" =~ ^[0-9]+$ ]]; then
			echo "$creds"
			return 0
		fi
		now_ms=$(($(date +%s) * 1000))
		if ((expires_at > now_ms)); then
			log "token valid for $(((expires_at - now_ms) / 1000))s"
			echo "$creds"
			return 0
		fi

		if ((attempt >= CREDS_RETRIES)); then
			echo "$creds"
			return 1
		fi
		attempt=$((attempt + 1))
		log "token expired, waiting for refresh (attempt $attempt/$CREDS_RETRIES)"
		sleep "$CREDS_POLL_SECS"
	done
}

# True when a cached entry's 5h window has not yet rolled over. Once it has, the
# cached percentage is guaranteed wrong — this is the case that used to show
# yesterday's 99% on the first launch of a new day.
entry_window_current() {
	local five_resets=$(echo "$1" | cut -d'|' -f3)
	if [[ -z "$five_resets" ]]; then
		return 0
	fi

	local reset_epoch
	reset_epoch=$(to_epoch "$five_resets") || return 0
	if (($(date +%s) >= reset_epoch)); then
		return 1
	fi
	return 0
}

write_cache() {
	{
		echo "$1"
		echo "$2"
	} >"$CACHE_FILE" 2>/dev/null
}

# Best available answer after a failed fetch: a recent, still-valid cached
# reading if there is one, otherwise UNKNOWN. UNKNOWN is written back to the
# cache so the next few renders skip the retry (and its wait) entirely.
serve_stale_or_unknown() {
	local now=$1 cache_time=$2 entry=$3
	local age=$((now - cache_time))

	if [[ -n "$entry" && "$entry" != "$UNKNOWN" ]] && ((age < MAX_STALE_AGE)) && entry_window_current "$entry"; then
		log "serving stale cache (age ${age}s)"
		echo "$entry"
		return
	fi

	log "no usable data (cache age ${age}s); reporting unknown"
	write_cache "$now" "$UNKNOWN"
	echo "$UNKNOWN"
}

# Function to get Pro usage with caching
get_usage() {
	local now=$(date +%s)
	local cache_time=0
	local cached_entry=""

	# Check if cache exists and is fresh
	if [[ -f "$CACHE_FILE" ]]; then
		cache_time=$(head -1 "$CACHE_FILE" 2>/dev/null || echo 0)
		if [[ ! "$cache_time" =~ ^[0-9]+$ ]]; then
			cache_time=0
		fi
		cached_entry=$(tail -n +2 "$CACHE_FILE" 2>/dev/null)

		local ttl=$CACHE_TTL
		if [[ "$cached_entry" == "$UNKNOWN" ]]; then
			ttl=$FAIL_TTL
		fi
		# A fresh cache is still only usable while its window holds, so a reset
		# that lands mid-TTL is not papered over by the previous window's number
		if ((now - cache_time < ttl)) && entry_window_current "$cached_entry"; then
			# Cache is fresh, use it
			log "cache hit (age $((now - cache_time))s, ttl ${ttl}s)"
			echo "$cached_entry"
			return
		fi
	fi

	# Cache is stale or doesn't exist, fetch new data
	local creds expired=0
	creds=$(get_fresh_creds) || expired=1
	if [[ -z "$creds" ]]; then
		log "no credentials available"
		serve_stale_or_unknown "$now" "$cache_time" "$cached_entry"
		return
	fi
	if ((expired)); then
		log "token still expired after waiting; trying the API anyway"
	fi

	local token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
	if [[ -z "$token" ]]; then
		log "credentials contain no access token"
		serve_stale_or_unknown "$now" "$cache_time" "$cached_entry"
		return
	fi

	# Call API
	local response=$(curl -s --max-time 5 \
		-H "Authorization: Bearer $token" \
		-H "anthropic-beta: oauth-2025-04-20" \
		"https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

	# On empty or error response, fall back — but never to a reading that is too
	# old or whose window has already reset
	if [[ -z "$response" ]] || echo "$response" | jq -e '.error' >/dev/null 2>&1; then
		log "usage API returned no usable response"
		serve_stale_or_unknown "$now" "$cache_time" "$cached_entry"
		return
	fi

	local five_hour=$(echo "$response" | jq -r '.five_hour.utilization // 0' 2>/dev/null)
	local seven_day=$(echo "$response" | jq -r '.seven_day.utilization // 0' 2>/dev/null)
	local five_hour_resets=$(echo "$response" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
	local seven_day_resets=$(echo "$response" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
	# Per-model weekly window (limits[] kind=weekly_scoped; today that is the
	# Fable weekly cap). Appended as cache fields 5-6 so positional reads of
	# fields 1-4 (entry_window_current cuts field 3) keep working on entries
	# written by the old 4-field format.
	local fable=$(echo "$response" | jq -r '[.limits[]? | select(.kind == "weekly_scoped")][0].percent // empty' 2>/dev/null)
	local fable_resets=$(echo "$response" | jq -r '[.limits[]? | select(.kind == "weekly_scoped")][0].resets_at // empty' 2>/dev/null)

	# Write to cache
	log "fetched fresh usage (5h=${five_hour}%, 7d=${seven_day}%, fable=${fable:-?}%)"
	write_cache "$now" "${five_hour}|${seven_day}|${five_hour_resets}|${seven_day_resets}|${fable}|${fable_resets}"

	echo "${five_hour}|${seven_day}|${five_hour_resets}|${seven_day_resets}|${fable}|${fable_resets}"
}

# Format reset time as relative (e.g., "2h30m" or "3d12h")
format_reset_time() {
	local reset_time=$1
	if [[ -z "$reset_time" ]]; then
		echo ""
		return
	fi

	local now=$(date +%s)
	local reset_epoch
	reset_epoch=$(to_epoch "$reset_time")
	if [[ -z "$reset_epoch" ]]; then
		echo ""
		return
	fi

	local diff=$((reset_epoch - now))
	if ((diff <= 0)); then
		echo "now"
		return
	fi

	local days=$((diff / 86400))
	local hours=$(((diff % 86400) / 3600))
	local mins=$(((diff % 3600) / 60))

	if ((days > 0)); then
		echo "${days}d${hours}h"
	elif ((hours > 0)); then
		echo "${hours}h${mins}m"
	else
		echo "${mins}m"
	fi
}

# Format reset time as absolute local clock time
# Args: $1 = ISO 8601 reset time, $2 = "short" (HH:MM) or "long" (MonDD HH:MM)
format_reset_clock() {
	local reset_time=$1
	local mode=${2:-short}
	if [[ -z "$reset_time" ]]; then
		echo ""
		return
	fi

	local fmt
	if [[ "$mode" == "long" ]]; then
		fmt="+%b%d %H:%M"
	else
		fmt="+%H:%M"
	fi

	local clock
	# Try GNU date first, then BSD date (macOS)
	clock=$(date -d "$reset_time" "$fmt" 2>/dev/null)
	if [[ -z "$clock" ]]; then
		# BSD date (macOS): parse ISO 8601 format
		# Strip fractional seconds and convert +00:00 to +0000
		local clean_time=$(echo "$reset_time" | sed -E 's/\.[0-9]+//; s/:([0-9]{2})$/\1/')
		clock=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$clean_time" "$fmt" 2>/dev/null)
	fi
	echo "$clock"
}

# Get usage data
usage_data=$(get_usage)
five_hour_raw=$(echo "$usage_data" | cut -d'|' -f1)
seven_day_raw=$(echo "$usage_data" | cut -d'|' -f2)
five_hour_resets_raw=$(echo "$usage_data" | cut -d'|' -f3)
seven_day_resets_raw=$(echo "$usage_data" | cut -d'|' -f4)
fable_raw=$(echo "$usage_data" | cut -d'|' -f5)
fable_resets_raw=$(echo "$usage_data" | cut -d'|' -f6)

# Format reset times
five_hour_reset=$(format_reset_time "$five_hour_resets_raw")
seven_day_reset=$(format_reset_time "$seven_day_resets_raw")
fable_reset=$(format_reset_time "$fable_resets_raw")
five_hour_clock=$(format_reset_clock "$five_hour_resets_raw" short)
seven_day_clock=$(format_reset_clock "$seven_day_resets_raw" long)
fable_clock=$(format_reset_clock "$fable_resets_raw" long)

# Format percentages (API returns values already as percentages, e.g., 18.0 = 18%)
# A missing value means the reading is unknown, not zero — say so rather than
# reporting a number the fetch never actually produced
format_pct() {
	if [[ ! "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
		echo "?"
		return
	fi
	awk "BEGIN {printf \"%.0f\", $1}"
}

five_hour_pct=$(format_pct "$five_hour_raw")
seven_day_pct=$(format_pct "$seven_day_raw")
fable_pct=$(format_pct "$fable_raw")
context_pct_fmt=$(awk "BEGIN {printf \"%.0f\", ${context_pct:-0}}")

# Format cost
cost_fmt=$(awk "BEGIN {printf \"%.2f\", ${cost:-0}}")

# Determine warning colors based on usage levels
get_usage_colors() {
	local pct=$1
	local default_bg=$2
	local default_fg=$3
	# Unknown ("?") reads as absent data, not as a low number
	if [[ ! "$pct" =~ ^[0-9]+$ ]]; then
		echo "${BG_GRAY}|${FG_GRAY}"
		return
	fi
	if ((pct >= 80)); then
		echo "${BG_RED}|${FG_RED}"
	elif ((pct >= 60)); then
		echo "${BG_YELLOW}|${FG_YELLOW}"
	else
		echo "${default_bg}|${default_fg}"
	fi
}

ctx_colors=$(get_usage_colors "$context_pct_fmt" "$BG_ORANGE" "$FG_ORANGE")
ctx_bg=$(echo "$ctx_colors" | cut -d'|' -f1)
ctx_fg=$(echo "$ctx_colors" | cut -d'|' -f2)

five_hour_colors=$(get_usage_colors "$five_hour_pct" "$BG_PINK" "$FG_PINK")
five_hour_bg=$(echo "$five_hour_colors" | cut -d'|' -f1)
five_hour_fg=$(echo "$five_hour_colors" | cut -d'|' -f2)

seven_day_colors=$(get_usage_colors "$seven_day_pct" "$BG_PURPLE" "$FG_PURPLE")
seven_day_bg=$(echo "$seven_day_colors" | cut -d'|' -f1)
seven_day_fg=$(echo "$seven_day_colors" | cut -d'|' -f2)

fable_colors=$(get_usage_colors "$fable_pct" "$BG_VIOLET" "$FG_VIOLET")
fable_bg=$(echo "$fable_colors" | cut -d'|' -f1)
fable_fg=$(echo "$fable_colors" | cut -d'|' -f2)

# Format context with amount (e.g., "42% 80K/200K")
# Calculate actual context usage from raw token counts for fine granularity
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 1000000')
context_max=$(awk "BEGIN {printf \"%.0f\", ${context_window_size} / 1000}")
context_used_k=$(awk "BEGIN {printf \"%.0f\", ${context_used_tokens} / 1000}")
context_pct_fmt=$(awk "BEGIN {printf \"%.1f\", (${context_used_tokens} / ${context_window_size}) * 100}")
context_display="${context_pct_fmt}% ${context_used_k}K/${context_max}K"

# Helper function to create a capsule
# Usage: capsule "text" "bg_color" "fg_color_for_cap"
capsule() {
	local text=$1
	local bg=$2
	local fg_cap=$3
	echo "${fg_cap}${LEFT_CAP}${RESET}${bg}${FG_WHITE}${BOLD}${text}${RESET}${fg_cap}${RIGHT_CAP}${RESET}"
}

# Build capsule segments
output=""

# Directory segment (blue)
output+=$(capsule " ${display_dir} " "$BG_BLUE" "$FG_BLUE")

# Git branch segment (magenta) - only if in a git repo
if [[ -n "$branch" ]]; then
	output+=" "
	output+=$(capsule "  ${branch}${git_dirty} " "$BG_MAGENTA" "$FG_MAGENTA")
fi

# Model segment (teal)
if [[ -n "$model" ]]; then
	model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
	output+=" "
	output+=$(capsule " ${model_lower} " "$BG_CYAN" "$FG_CYAN")
fi

# Context segment (orange, or warning color)
output+=" "
output+=$(capsule " ${context_display} " "$ctx_bg" "$ctx_fg")

# 5-hour usage segment (pink, or warning color)
output+=" "
if [[ "$five_hour_pct" == "?" ]]; then
	five_hour_display="5h:?"
else
	five_hour_display="5h:${five_hour_pct}%"
fi
[[ -n "$five_hour_reset" ]] && five_hour_display+=" ${five_hour_reset}"
[[ -n "$five_hour_clock" ]] && five_hour_display+=" (${five_hour_clock})"
output+=$(capsule " ${five_hour_display} " "$five_hour_bg" "$five_hour_fg")

# 7-day usage segment (purple, or warning color)
output+=" "
if [[ "$seven_day_pct" == "?" ]]; then
	seven_day_display="7d:?"
else
	seven_day_display="7d:${seven_day_pct}%"
fi
[[ -n "$seven_day_reset" ]] && seven_day_display+=" ${seven_day_reset}"
[[ -n "$seven_day_clock" ]] && seven_day_display+=" (${seven_day_clock})"
output+=$(capsule " ${seven_day_display} " "$seven_day_bg" "$seven_day_fg")

# Fable weekly usage segment (violet, or warning color). Shown only when the
# API reports a per-model weekly window — accounts without one skip the capsule
# rather than showing a permanent "?".
if [[ "$fable_pct" != "?" ]]; then
	output+=" "
	fable_display="fable:${fable_pct}%"
	[[ -n "$fable_reset" ]] && fable_display+=" ${fable_reset}"
	[[ -n "$fable_clock" ]] && fable_display+=" (${fable_clock})"
	output+=$(capsule " ${fable_display} " "$fable_bg" "$fable_fg")
fi

# Cost segment (gray)
output+=" "
output+=$(capsule " \$${cost_fmt} " "$BG_GRAY" "$FG_GRAY")

# Output
echo -e "$output"
