#!/bin/bash
set -euo pipefail

# Toggle HDMI-2 between vertical (rotated right) and horizontal (normal)
# for screen sharing presentations over Zoom.
# Only applies to popos (dual-monitor mini PC setup).

if [[ "$(hostname)" != "popos" ]]; then
    notify-send "Presentation toggle" "Only available on popos (dual-monitor setup)"
    exit 0
fi

OUTPUT="HDMI-2"
PRIMARY="HDMI-1"

if ! xrandr --query | grep -q "^${OUTPUT} connected"; then
    notify-send "Presentation toggle" "HDMI-2 not connected"
    exit 0
fi

current=$(xrandr --query | grep "^${OUTPUT} connected" | grep -o 'right\|left\|inverted\|normal' | head -1)

if [[ "$current" == "right" || "$current" == "left" || "$current" == "inverted" ]]; then
    # Switch to horizontal (presentation mode)
    xrandr --output "$OUTPUT" --rotate normal --right-of "$PRIMARY"
    notify-send "Presentation mode" "HDMI-2 → horizontal"
else
    # Switch back to vertical (daily use)
    xrandr --output "$OUTPUT" --rotate right --right-of "$PRIMARY"
    notify-send "Normal mode" "HDMI-2 → vertical"
fi

# Refresh wallpapers for new orientation
~/.config/i3/wallpaper.sh &
