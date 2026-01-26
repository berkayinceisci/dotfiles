#!/bin/bash

# Custom Claude Code Statusline
# Capsule-style display showing: directory, git branch, model, context %, tokens, 5h/7d usage, session cost

CACHE_FILE="/tmp/claude-usage-cache"
CACHE_TTL=60  # seconds

# Powerline characters for capsule edges (require Nerd Font)
# U+E0B6 = left rounded, U+E0B4 = right rounded
LEFT_CAP=$(printf '\xee\x82\xb6')
RIGHT_CAP=$(printf '\xee\x82\xb4')

# ANSI color codes
RESET="\033[0m"
BOLD="\033[1m"

# Background colors (distinct for each segment)
BG_BLUE="\033[48;5;33m"      # Directory - bright blue
BG_MAGENTA="\033[48;5;133m"  # Git - purple/magenta
BG_CYAN="\033[48;5;37m"      # Model - teal
BG_ORANGE="\033[48;5;208m"   # Context - orange
BG_GREEN="\033[48;5;71m"     # Tokens - green
BG_PINK="\033[48;5;168m"     # 5h usage - pink
BG_PURPLE="\033[48;5;98m"    # 7d usage - deep purple
BG_GRAY="\033[48;5;240m"     # Cost - gray

# Foreground colors (for text)
FG_WHITE="\033[97m"
FG_BLACK="\033[30m"

# Foreground colors matching backgrounds (for capsule edges)
FG_BLUE="\033[38;5;33m"
FG_MAGENTA="\033[38;5;133m"
FG_CYAN="\033[38;5;37m"
FG_ORANGE="\033[38;5;208m"
FG_GREEN="\033[38;5;71m"
FG_PINK="\033[38;5;168m"
FG_PURPLE="\033[38;5;98m"
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
model=$(echo "$input" | jq -r '.model.display_name // empty')
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Calculate total tokens
total_tokens=$((input_tokens + output_tokens))

# Format directory (shorten home path)
if [[ -n "$cwd" ]]; then
    display_dir="${cwd/#$HOME/~}"
    # Shorten to last 2 components if too long
    if [[ ${#display_dir} -gt 30 ]]; then
        display_dir="…/$(basename "$(dirname "$cwd")")/$(basename "$cwd")"
    fi
else
    display_dir="~"
fi

# Get git branch
if [[ -n "$cwd" ]]; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Check if repo is dirty (any changes: staged, unstaged, or untracked)
git_dirty=""
if [[ -n "$cwd" && -n "$branch" ]]; then
    if [[ -n $(git -C "$cwd" status --porcelain 2>/dev/null) ]]; then
        git_dirty="*"
    fi
fi

# Get git changes from git diff
if [[ -n "$cwd" && -n "$branch" ]]; then
    git_files=$(git -C "$cwd" diff --numstat HEAD 2>/dev/null | wc -l | tr -d ' ')
    git_stat=$(git -C "$cwd" diff --shortstat HEAD 2>/dev/null)
    git_added=$(echo "$git_stat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
    git_removed=$(echo "$git_stat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
    git_files=${git_files:-0}
    git_added=${git_added:-0}
    git_removed=${git_removed:-0}
fi

# Function to get Pro usage with caching
get_usage() {
    local now=$(date +%s)
    local cache_time=0
    local cached_data=""

    # Check if cache exists and is fresh
    if [[ -f "$CACHE_FILE" ]]; then
        cache_time=$(head -1 "$CACHE_FILE" 2>/dev/null || echo 0)
        if (( now - cache_time < CACHE_TTL )); then
            # Cache is fresh, use it
            tail -n +2 "$CACHE_FILE"
            return
        fi
    fi

    # Cache is stale or doesn't exist, fetch new data
    # Get token from Keychain
    local creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    if [[ -z "$creds" ]]; then
        echo "||"
        return
    fi

    local token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    if [[ -z "$token" ]]; then
        echo "||"
        return
    fi

    # Call API
    local response=$(curl -s --max-time 5 \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

    if [[ -z "$response" ]]; then
        echo "||"
        return
    fi

    local five_hour=$(echo "$response" | jq -r '.five_hour.utilization // 0' 2>/dev/null)
    local seven_day=$(echo "$response" | jq -r '.seven_day.utilization // 0' 2>/dev/null)

    # Write to cache
    {
        echo "$now"
        echo "${five_hour}|${seven_day}"
    } > "$CACHE_FILE" 2>/dev/null

    echo "${five_hour}|${seven_day}"
}

# Get usage data
usage_data=$(get_usage)
five_hour_raw=$(echo "$usage_data" | cut -d'|' -f1)
seven_day_raw=$(echo "$usage_data" | cut -d'|' -f2)

# Format percentages (API returns values already as percentages, e.g., 18.0 = 18%)
five_hour_pct=$(awk "BEGIN {printf \"%.0f\", ${five_hour_raw:-0}}")
seven_day_pct=$(awk "BEGIN {printf \"%.0f\", ${seven_day_raw:-0}}")
context_pct_fmt=$(awk "BEGIN {printf \"%.0f\", ${context_pct:-0}}")

# Format tokens (K format)
if (( total_tokens >= 1000 )); then
    tokens_fmt=$(awk "BEGIN {printf \"%.1fK\", ${total_tokens}/1000}")
else
    tokens_fmt="${total_tokens}"
fi

# Format cost
cost_fmt=$(awk "BEGIN {printf \"%.2f\", ${cost:-0}}")

# Determine warning colors based on usage levels
get_usage_colors() {
    local pct=$1
    local default_bg=$2
    local default_fg=$3
    if (( pct >= 80 )); then
        echo "${BG_RED}|${FG_RED}"
    elif (( pct >= 60 )); then
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

# Format context with amount (e.g., "42% 80K/200K")
# Calculate actual context usage from percentage (not cumulative tokens)
context_max=200  # 200K context window
context_used_k=$(awk "BEGIN {printf \"%.0f\", (${context_pct:-0}/100) * ${context_max}}")
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

# Tokens segment (green)
output+=" "
output+=$(capsule " ${tokens_fmt} " "$BG_GREEN" "$FG_GREEN")

# 5-hour usage segment (pink, or warning color)
output+=" "
output+=$(capsule " 5h:${five_hour_pct}% " "$five_hour_bg" "$five_hour_fg")

# 7-day usage segment (purple, or warning color)
output+=" "
output+=$(capsule " 7d:${seven_day_pct}% " "$seven_day_bg" "$seven_day_fg")

# Cost segment (gray)
output+=" "
output+=$(capsule " \$${cost_fmt} " "$BG_GRAY" "$FG_GRAY")

# Colors for git diff numbers
FG_DIFF_GREEN="\033[38;5;78m"
FG_DIFF_RED="\033[38;5;203m"

# Bottom line: Git changes (dark background with colored +/-)
bottom_line=""
if [[ "$git_files" -gt 0 ]]; then
    BG_DARK="\033[48;5;236m"
    FG_DARK="\033[38;5;236m"
    git_text=" ${git_files} files ${FG_DIFF_GREEN}+${git_added}${FG_WHITE} ${FG_DIFF_RED}-${git_removed}${FG_WHITE} "
    bottom_line="${FG_DARK}${LEFT_CAP}${RESET}${BG_DARK}${FG_WHITE}${BOLD}${git_text}${RESET}${FG_DARK}${RIGHT_CAP}${RESET}"
fi

# Output: top line, margin, then bottom line if there are changes
echo -e "$output"
if [[ -n "$bottom_line" ]]; then
    echo ""
    echo -e "$bottom_line"
fi
