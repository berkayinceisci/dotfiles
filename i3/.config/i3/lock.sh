#!/bin/sh
# Screen locker for i3 (bound to Mod4+l in the i3 config).
#
# Uses i3lock-color, which blurs in-process and locks INSTANTLY (no external
# screenshot/resample step). On Arch it's the AUR `i3lock-color` package; on
# Pop!_OS/Ubuntu it's built from source to /usr/local/bin, which shadows apt's
# stock /usr/bin/i3lock via PATH (see the installation repo's gui_apps.sh).
#
# If only stock i3lock is on PATH (e.g. right after a distro upgrade, before the
# build re-runs), it rejects the color flags below -- so we fall back to a plain
# i3lock rather than silently failing to lock. A silent no-op once made Mod4+l
# look completely dead.

verbose=0
case "$1" in
	-v|--verbose) verbose=1 ;;
esac
log() { [ "$verbose" -eq 1 ] && echo "lock.sh: $*" >&2; }

BLANK='#00000000'
CLEAR='#ffffff22'
DEFAULT='#ffffff88'
TEXT='#ffffffbb'
WRONG='#880000bb'
VERIFYING='#9b8361ff'

log "using $(command -v i3lock)"
if i3lock \
	--insidever-color=$CLEAR \
	--ringver-color=$VERIFYING \
	--insidewrong-color=$CLEAR \
	--ringwrong-color=$WRONG \
	--inside-color=$BLANK \
	--ring-color=$DEFAULT \
	--line-color=$BLANK \
	--separator-color=$DEFAULT \
	--verif-color=$TEXT \
	--wrong-color=$TEXT \
	--time-color=$TEXT \
	--date-color=$TEXT \
	--layout-color=$TEXT \
	--keyhl-color=$WRONG \
	--bshl-color=$WRONG \
	--blur 5 \
	--clock \
	--indicator \
	--time-str="%H:%M:%S" \
	--date-str="%A, %m-%d-%Y" \
	--keylayout 1 \
	--radius 120 \
	--ring-width 12
then
	log "locked with i3lock-color"
else
	log "color flags rejected (stock i3lock?); falling back to plain i3lock"
	i3lock -c 000000
fi

~/.config/i3/xsettings.sh
