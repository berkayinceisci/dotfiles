#!/bin/sh
# Keyboard settings that X throws away whenever it (re-)adds an input device.
#
# Invoked two ways:
#   1. with no arguments -- from xsettings.sh at i3 start (and again from
#      lock.sh on unlock, which re-runs xsettings.sh).
#   2. with inputplug's argv -- from systemd's inputplug.service on every
#      XInput hierarchy event. inputplug appends four arguments:
#          <event type> <device id> <device type> <device name>
#      e.g. "XIDeviceEnabled" "12" "XISlaveKeyboard" "AT Translated Set 2 keyboard"
#
# Why this exists as its own script rather than lines inside xsettings.sh: X
# re-applies matching InputClass sections to every input device it adds, which
# resets the keyboard's XKB state. A udev reload (pacman's
# 35-systemd-udev-reload.hook fires on most -Syu runs) or an external keyboard
# being plugged in therefore silently reverts both settings below, and the only
# general repair is to re-apply them on the device-added event itself.
#
# The LAYOUT additionally has a durable form -- dotfiles/xorg-keyboard.conf,
# installed by bootstrap.sh as /etc/X11/xorg.conf.d/99-keyboard-layout.conf --
# so X restores it on a re-add by itself. The REPEAT RATE has no such form:
# `xset r rate` writes XKB *control* state (repeat_delay/repeat_interval in
# xkb->ctrls, see XkbSetControls(3)), not device configuration, and libinput
# exposes no AutoRepeat InputClass option. This script is the only thing that
# brings the rate back.
#
# No debounce: a mass re-enumeration fires one event per keyboard device, and X
# can reset the controls again on a device added AFTER we re-applied. Running on
# every event is precisely what makes the last write win, and both commands
# below are cheap and idempotent.

# KEYBOARD_SETUP_VERBOSE=1 as well as -v, because in the inputplug path argv is
# not ours to spend: inputplug appends its four event arguments and the case
# below dispatches on them, so a -v there would suppress the very filtering the
# hook is being debugged for. Same reason askpass uses ASKPASS_VERBOSE (AGENTS.md).
verbose=0
if [ "${KEYBOARD_SETUP_VERBOSE:-0}" = "1" ]; then
	verbose=1
fi
log() { [ "$verbose" -eq 1 ] && echo "keyboard_setup.sh: $*" >&2; }

case "$1" in
-v | --verbose)
	verbose=1
	;;
"")
	# Direct call (xsettings.sh): always apply.
	;;
XIDeviceEnabled)
	# The moment X has finished (re-)configuring a device and has therefore
	# just clobbered the keyboard state. XISlaveAdded fires for the same
	# device immediately before this, so matching only on Enabled keeps it to
	# one run per device rather than two.
	case "$3" in
	*Keyboard*) ;;
	*)
		log "ignoring $1 for $3 ($4)"
		exit 0
		;;
	esac
	;;
*)
	# Pointers, removals, detaches: nothing to re-apply.
	log "ignoring event $1 ($3 $4)"
	exit 0
	;;
esac

log "applying keyboard settings (event=${1:-direct} device=${4:-n/a})"

# fast keystrokes
xset r rate 300 60

# keyboard layout: us + tr, switched with Win+Space
setxkbmap -layout "us,tr" -option "grp:win_space_toggle"
