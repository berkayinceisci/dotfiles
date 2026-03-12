#!/bin/bash
set -euo pipefail

# Toggle display for presentations.
# popos: Toggle HDMI-2 between vertical (rotated right) and horizontal (normal)
#         for screen sharing presentations over Zoom.
# manjaro: Toggle laptop screen (eDP-1) on/off when external monitor is connected.

HOST=$(hostname)

case "$HOST" in
"manjaro")
	# Find which HDMI output is connected
	if xrandr --query | grep -q "^HDMI-1-0 connected"; then
		EXTERNAL="HDMI-1-0"
	elif xrandr --query | grep -q "^HDMI-1-1 connected"; then
		EXTERNAL="HDMI-1-1"
	else
		notify-send "Presentation toggle" "No external monitor connected"
		exit 0
	fi

	LAPTOP="eDP-1"

	# Check if laptop screen is currently on
	if xrandr --query | grep -q "^${LAPTOP} connected [0-9]"; then
		# Laptop is on → turn it off
		xrandr --output "$LAPTOP" --off
		notify-send "Presentation mode" "Laptop screen off"
	else
		# Laptop is off → turn it on, to the left of external
		xrandr --output "$LAPTOP" --auto --left-of "$EXTERNAL"
		notify-send "Normal mode" "Laptop screen on"
	fi
	;;
"popos")
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
	;;
*)
	notify-send "Presentation toggle" "Not configured for host: $HOST"
	exit 0
	;;
esac

# Refresh wallpapers for new layout/orientation
~/.config/i3/wallpaper.sh &
