#!/bin/bash

RECOVER=0
VERBOSE=0

while [[ $# -gt 0 ]]; do
	case "$1" in
	"--recover")
		RECOVER=1
		;;
	"-v" | "--verbose")
		VERBOSE=1
		;;
	"-h" | "--help")
		printf 'Usage: %s [--recover] [-v|--verbose]\n' "${0##*/}"
		exit 0
		;;
	*)
		printf 'Unknown argument: %s\n' "$1" >&2
		printf 'Usage: %s [--recover] [-v|--verbose]\n' "${0##*/}" >&2
		exit 2
		;;
	esac
	shift
done

log()
{
	if [[ $VERBOSE -eq 1 ]]; then
		printf 'display_setup: %s\n' "$*" >&2
	fi
}

run()
{
	if [[ $VERBOSE -eq 1 ]]; then
		printf 'display_setup: command:' >&2
		printf ' %q' "$@" >&2
		printf '\n' >&2
	fi
	"$@"
}

query_xrandr()
{
	log "command: xrandr --query"
	xrandr --query
}

output_line()
{
	local output="$1"

	query_xrandr | awk -v output="$output" \
		'$1 == output { print; found = 1 } END { if (!found) exit 1 }'
}

output_connected()
{
	local line
	local output="$1"

	if ! line=$(output_line "$output"); then
		return 1
	fi
	[[ "$line" == "${output} connected"* ]]
}

output_active()
{
	local geometry_re='[[:space:]][0-9]+x[0-9]+\+[0-9]+\+[0-9]+([[:space:]]|$)'
	local line

	if ! line=$(output_line "$1"); then
		return 1
	fi
	[[ "$line" =~ $geometry_re ]]
}

enable_output()
{
	local attempt
	local output="$1"

	shift
	for attempt in 1 2; do
		if run xrandr --output "$output" "$@"; then
			if output_active "$output"; then
				return 0
			fi
		fi
		log "$output did not acquire an active mode (attempt $attempt/2)"
		if [[ $attempt -lt 2 ]]; then
			run sleep 1
		fi
	done
	return 1
}

configure_hdmi1()
{
	if enable_output HDMI-1 --mode 3840x2160 --rate 60.00 --primary \
		--pos 0x0; then
		return 0
	fi
	log "HDMI-1 rejected 3840x2160 at 60 Hz; falling back to --auto"
	enable_output HDMI-1 --auto --primary --pos 0x0
}

configure_hdmi2()
{
	local -a placement

	if output_active HDMI-1; then
		placement=(--right-of HDMI-1)
	else
		placement=(--primary --pos 0x0)
	fi

	if enable_output HDMI-2 --mode 3840x2160 --rate 60.00 \
		--rotate right "${placement[@]}"; then
		return 0
	fi
	log "HDMI-2 rejected 3840x2160 at 60 Hz; falling back to --auto"
	enable_output HDMI-2 --auto --rotate right "${placement[@]}"
}

# Reset the display engine by switching the active VT away from X and back.
#
# Why a VT round-trip: the GPU driver can wedge so that it reports outputs
# "connected" yet rejects EVERY modeset ("xrandr: Configure crtc N failed"),
# including on other outputs — at that point re-running xrandr harder (the old
# recovery behavior) cannot help, and no user-space API exists to tell the
# driver "reset your display engine". The one lever available is the active
# VT: switching away forces the X server to release the GPU entirely (drop
# DRM master), and switching back makes it re-acquire and re-initialize the
# display hardware from scratch — the software equivalent of unplugging the
# GPU and plugging it back in. Validated live on both machines; on manjaro by
# the 2026-08-17 incident: external-only setup lost signal, every modeset
# failed from within X, and one manual tty round-trip (Ctrl+Alt+F2, then
# Alt+F7) made the previously failing 2560x1440 modeset succeed on the first
# try. The VT is never the thing being fixed — it is the doorknob that makes
# the driver let go.
#
# chvt requires root: `sudo -n` here relies on the NOPASSWD sudoers drop-in
# for chvt installed by bootstrap.sh (machines with a blanket NOPASSWD rule,
# e.g. popos, work without it). If sudo -n fails, recovery aborts cleanly and
# the manual fallback is the same round-trip by hand: Ctrl+Alt+F2, log in,
# then Alt+F7 (or `sudo chvt <XDG_VTNR of X>`), then re-run this script.
recover_x_vt()
{
	local recovery_vt=2
	local x_vt="${XDG_VTNR-}"

	if [[ ! "$x_vt" =~ ^[0-9]+$ ]]; then
		log "XDG_VTNR is unavailable; refusing to guess the X virtual terminal"
		return 1
	fi
	if [[ $x_vt -eq $recovery_vt ]]; then
		recovery_vt=3
	fi

	return_to_x_vt()
	{
		if ! sudo -n chvt "$x_vt"; then
			printf 'display_setup: failed to return to X on VT %s\n' \
				"$x_vt" >&2
		fi
	}

	log "resetting the display engine via VT $recovery_vt, then VT $x_vt"
	trap return_to_x_vt INT TERM
	if ! run sudo -n chvt "$recovery_vt"; then
		trap - INT TERM
		return 1
	fi
	run sleep 2
	if ! run sudo -n chvt "$x_vt"; then
		trap - INT TERM
		return 1
	fi
	trap - INT TERM
	run sleep 2

	# Serial-console activity does not reset X's idle timer. Explicitly wake
	# the displays so a recovery launched from outside X does not return to a
	# correctly configured but immediately sleeping graphical session.
	run xset s reset
	run xset dpms force on
}

reset_link_status()
{
	local output="$1"

	# A failed link remains marked Bad until userspace acknowledges that it
	# has retrained the output; the VT round-trip in recover_x_vt performed
	# that reset. The property is driver-dependent (the modesetting driver
	# exposes it, the NVIDIA proprietary driver does not), so only set it
	# where it exists.
	if xrandr --props | awk -v output="$output" \
		'$1 == output { in_out = 1; next }
		 /^[^[:space:]]/ { in_out = 0 }
		 in_out && /link-status:/ { found = 1 }
		 END { exit !found }'; then
		run xrandr --output "$output" --set "link-status" Good
	else
		log "$output has no link-status property; skipping link reset"
	fi
}

# Ignore repeated invocations while a previous display reset/configuration is
# still in progress. Overlapping modesets can otherwise undo one another.
if command -v flock >/dev/null 2>&1; then
	exec 9<"$0"
	if ! run flock -n 9; then
		log "another display reset is already in progress"
		exit 0
	fi
fi

# Configure displays per machine. Two computers share this repo:
#   manjaro - laptop (Intel + NVIDIA hybrid). Internal panel eDP-1 plus
#             one external monitor (DELL S2725QS, 3840x2160) wired to the
#             NVIDIA GPU, so it shows up as HDMI-1-0 (or HDMI-1-1 if the
#             DRM card index differs).
#   popos   - mini PC, no internal screen. Two external 4K monitors on
#             HDMI-1 (horizontal, primary) and HDMI-2 (vertical).
# (ubuntu is treated the same as manjaro.)

HOST=$(hostname)
log "host=$HOST recover=$RECOVER DISPLAY=${DISPLAY-<unset>} XAUTHORITY=${XAUTHORITY-<unset>} XDG_VTNR=${XDG_VTNR-<unset>}"

case "$HOST" in
"manjaro" | "ubuntu")
	log "selected laptop display branch"
	if [[ $RECOVER -eq 1 ]]; then
		# Recovery from total signal loss (e.g. X lost the GPU after a VT
		# switch, or the NVIDIA driver wedged the port): reset the display
		# engine via a VT round-trip before reconfiguring the outputs.
		if ! recover_x_vt; then
			log "VT recovery failed"
			exit 1
		fi
	fi
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
	if output_connected HDMI-1-0; then
		EXT="HDMI-1-0"
	elif output_connected HDMI-1-1; then
		EXT="HDMI-1-1"
	fi

	if [[ $RECOVER -eq 1 ]] && [[ -n "$EXT" ]]; then
		reset_link_status "$EXT"
	fi

	if [[ -n "$EXT" ]]; then
		# Bring the external up as primary WITHOUT touching eDP-1 yet: prefer
		# 2560x1440, fall back to the EDID-preferred mode if that is rejected.
		if ! run xrandr --output "$EXT" --mode 2560x1440 --primary; then
			run xrandr --output "$EXT" --auto --primary
		fi
		# Did it actually get an active geometry (WxH+X+Y on its line)? Only
		# then is the external truly displaying and safe to go external-only.
		if output_active "$EXT"; then
			run xrandr --output eDP-1 --off
		else
			# External could not be driven (typical for the NVIDIA port,
			# especially on hotplug). Undo it and stay on the laptop panel.
			run xrandr --output "$EXT" --off --output eDP-1 --auto --primary
		fi
	else
		run xrandr --output eDP-1 --auto --primary
	fi
	;;
"popos")
	log "selected popos display branch"
	# Mini PC - external monitors only (no laptop screen)
	if [[ $RECOVER -eq 1 ]]; then
		if ! recover_x_vt; then
			log "VT recovery failed"
			exit 1
		fi
		if output_connected HDMI-1; then
			reset_link_status HDMI-1
		fi
	fi

	# Query connection state after recovery; the old implementation reused the
	# stale pre-reset state and could choose the wrong configuration.
	HDMI1_CONNECTED=0
	HDMI2_CONNECTED=0
	if output_connected HDMI-1; then
		HDMI1_CONNECTED=1
	fi
	if output_connected HDMI-2; then
		HDMI2_CONNECTED=1
	fi

	if [[ $HDMI1_CONNECTED -eq 1 ]] && [[ $HDMI2_CONNECTED -eq 1 ]]; then
		# Dual monitor: HDMI-1 primary, HDMI-2 vertical (rotated right) to the right
		configure_hdmi1
		configure_hdmi2
	elif [[ $HDMI1_CONNECTED -eq 1 ]]; then
		configure_hdmi1
	elif [[ $HDMI2_CONNECTED -eq 1 ]]; then
		configure_hdmi2
	else
		log "no connected HDMI outputs found"
	fi
	;;
*)
	log "no display configuration exists for host $HOST"
	;;
esac
