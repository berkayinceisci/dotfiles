#!/bin/bash

# Configure displays per machine. Two computers share this repo:
#   manjaro - laptop (Intel + NVIDIA hybrid). Internal panel eDP-1 plus
#             one external monitor (DELL S2725QS, 3840x2160) wired to the
#             NVIDIA GPU, so it shows up as HDMI-1-0 (or HDMI-1-1 if the
#             DRM card index differs).
#   popos   - mini PC, no internal screen. Two external 4K monitors on
#             HDMI-1 (horizontal, primary) and HDMI-2 (vertical).
# (ubuntu is treated the same as manjaro.)

HOST=$(hostname)

case "$HOST" in
"manjaro" | "ubuntu")
	# Laptop + external monitor setup (see header).
	# Preferred behavior when an external is present AND can actually be
	# driven: use ONLY the external, disable the laptop panel. But on this
	# hybrid Intel+NVIDIA laptop the external hangs off the NVIDIA GPU, and
	# the proprietary driver frequently reports the port "connected" while
	# still refusing to set a mode on it. Blindly turning eDP-1 off in that
	# state leaves the machine with NO usable display (black screen at the
	# greeter / on login). So: try to bring the external up FIRST, VERIFY it
	# actually got an active mode, and only then turn the laptop panel off.
	# If it did not come up, keep eDP-1 on so we are never left blind.
	# Drive the external at 2560x1440 (2K), NOT its native 4K: the hybrid GPU
	# renders 4K too slowly (laggy). 1440p is a supported EDID mode on the
	# Dell; fall back to --auto (EDID-preferred) if 1440p is unavailable, e.g.
	# a different external is attached.

	# The external's DRM card index can shift between HDMI-1-0 and HDMI-1-1.
	EXT=""
	if xrandr | grep "^HDMI-1-0 connected" >/dev/null; then
		EXT="HDMI-1-0"
	elif xrandr | grep "^HDMI-1-1 connected" >/dev/null; then
		EXT="HDMI-1-1"
	fi

	if [ -n "$EXT" ]; then
		# Bring the external up as primary WITHOUT touching eDP-1 yet: prefer
		# 2560x1440, fall back to the EDID-preferred mode if that is rejected.
		xrandr --output "$EXT" --mode 2560x1440 --primary 2>/dev/null ||
			xrandr --output "$EXT" --auto --primary
		# Did it actually get an active geometry (WxH+X+Y on its line)? Only
		# then is the external truly displaying and safe to go external-only.
		if xrandr | grep -E "^$EXT connected" | grep -qE "[0-9]+x[0-9]+\+[0-9]+\+[0-9]+"; then
			xrandr --output eDP-1 --off
		else
			# External could not be driven (typical for the NVIDIA port,
			# especially on hotplug). Undo it and stay on the laptop panel.
			xrandr --output "$EXT" --off --output eDP-1 --auto --primary
		fi
	else
		xrandr --output eDP-1 --auto --primary
	fi
	;;
"popos")
	# Mini PC - external monitors only (no laptop screen)
	HDMI1_CONNECTED=$(xrandr | grep "^HDMI-1 connected")
	HDMI2_CONNECTED=$(xrandr | grep "^HDMI-2 connected")

	# Turn off outputs first to force GPU to re-negotiate signal
	if [ -n "$HDMI1_CONNECTED" ]; then
		xrandr --output HDMI-1 --off
	fi
	if [ -n "$HDMI2_CONNECTED" ]; then
		xrandr --output HDMI-2 --off
	fi
	sleep 2

	if [ -n "$HDMI1_CONNECTED" ] && [ -n "$HDMI2_CONNECTED" ]; then
		# Dual monitor: HDMI-1 primary, HDMI-2 vertical (rotated right) to the right
		xrandr --output HDMI-1 --mode 3840x2160 --rate 60.00 --primary \
			--output HDMI-2 --mode 3840x2160 --rate 60.00 --rotate right --right-of HDMI-1
	elif [ -n "$HDMI1_CONNECTED" ]; then
		xrandr --output HDMI-1 --mode 3840x2160 --rate 60.00 --primary
	elif [ -n "$HDMI2_CONNECTED" ]; then
		xrandr --output HDMI-2 --mode 3840x2160 --rate 60.00 --primary
	fi
	;;
esac
