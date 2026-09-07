#!/bin/bash
# Take a screenshot to ~/Pictures, or to the clipboard with -c (X11, flameshot
# backend).
#
# Mirrors screenrecord.sh: same mode names, same notify-send UX, same
# "never leave a dud file behind" rule.
#
# flameshot's --raw mode writes the PNG bytes to stdout, so the caller owns the
# file name (hence the .png suffix, which a bare `> $(date)` redirect used to
# omit). It is also why the capture goes to a temp file first: with a direct
# redirect the shell creates the target the moment the binding fires, so
# cancelling the flameshot overlay (Esc / right-click) left a 0-byte extensionless
# file in ~/Pictures every time. Only a validated PNG is moved into place.
#
# Usage: screenshot.sh [region|window|screen] [-c|--clipboard] [-v|--verbose]
#   region  select an area in the flameshot GUI (default)
#   window  pre-select the currently focused window (still editable in the GUI)
#   screen  the whole monitor under the cursor, no GUI
set -uo pipefail

OUTDIR="$HOME/Pictures"

mode="region"
clipboard=0
verbose=0
for arg in "$@"; do
    case "$arg" in
    region | window | screen) mode="$arg" ;;
    -c | --clipboard) clipboard=1 ;;
    -v | --verbose) verbose=1 ;;
    *)
        echo "screenshot.sh: unknown argument: $arg" >&2
        exit 1
        ;;
    esac
done

log() { [[ $verbose -eq 1 ]] && echo "screenshot.sh: $*" >&2; }
notify() { command -v notify-send >/dev/null 2>&1 && notify-send "$@"; }

mkdir -p "$OUTDIR"

# --- monitor under the cursor -----------------------------------------------
# `flameshot screen` MUST be given an explicit -n. Without it flameshot passes
# screenNumber = -1 ("the screen containing the cursor"), which routes into
# ScreenGrabber::selectMonitorAndCrop(). That function's first branch is a
# single-monitor shortcut that crops correctly but never assigns
# m_selectedMonitor, so the getSelectedScreen() call right after it returns
# nullptr, flameshot decides the capture failed and discards it with
# "Screenshot aborted." (flameshot v14.0.0, core/flameshot.cpp:193 +
# utils/screengrabber.cpp:168). Passing -n <index> takes the other branch and
# skips that code entirely.
#
# The index has to match QGuiApplication::screens() ordering. The xcb platform
# plugin enumerates those from RandR, the same source and order as
# `xrandr --listmonitors`, so the row index is the screen index. Run with -v to
# print the resolved index and geometry if a multi-monitor layout disagrees.
cursor_monitor_index() {
    local X Y mx my idx geom w h x y
    eval "$(xdotool getmouselocation --shell 2>/dev/null)"
    mx="${X:-}"
    my="${Y:-}"
    if [[ -z "$mx" ]] || [[ -z "$my" ]]; then
        log "xdotool getmouselocation failed — cannot resolve cursor monitor"
        return 1
    fi
    while read -r idx _ geom _; do
        idx="${idx%:}"
        [[ "$idx" =~ ^[0-9]+$ ]] || continue
        # e.g. "2560/600x1440/340+0+0" -> 2560x1440 at +0+0 (the /NNN are mm)
        if [[ ! "$geom" =~ ^([0-9]+)/[0-9]+x([0-9]+)/[0-9]+\+(-?[0-9]+)\+(-?[0-9]+)$ ]]; then
            continue
        fi
        w="${BASH_REMATCH[1]}"
        h="${BASH_REMATCH[2]}"
        x="${BASH_REMATCH[3]}"
        y="${BASH_REMATCH[4]}"
        if [[ $mx -ge $x ]] && [[ $mx -lt $((x + w)) ]] &&
            [[ $my -ge $y ]] && [[ $my -lt $((y + h)) ]]; then
            log "cursor ($mx,$my) is on monitor $idx (${w}x${h}+${x}+${y})"
            echo "$idx"
            return 0
        fi
    done < <(xrandr --listmonitors 2>/dev/null | tail -n +2)
    log "cursor ($mx,$my) matched no monitor in xrandr --listmonitors"
    return 1
}

# --- build the flameshot invocation for the requested mode ------------------
args=()
case "$mode" in
region)
    args=(gui)
    ;;
window)
    # Feed the focused window's geometry to flameshot as the initial selection.
    # With no focused window xdotool prints nothing, which under `set -u` would
    # abort on ${WIDTH} and strand the temp file — fall back to a plain region.
    eval "$(xdotool getactivewindow getwindowgeometry --shell 2>/dev/null)"
    if [[ -z "${WIDTH:-}" ]]; then
        log "no focused window — falling back to region"
        args=(gui)
    else
        args=(gui --region "${WIDTH}x${HEIGHT}+${X}+${Y}")
    fi
    ;;
screen)
    if idx="$(cursor_monitor_index)"; then
        args=(screen -n "$idx")
    else
        # Degrade to the whole desktop rather than failing outright: `full`
        # takes a different code path that needs no monitor index at all.
        log "falling back to full desktop capture"
        args=(full)
    fi
    ;;
esac

# --- capture ----------------------------------------------------------------
if [[ $clipboard -eq 1 ]]; then
    # No file involved, so there is nothing to validate or clean up — flameshot
    # owns the clipboard write. Aborting the overlay is the common case and is
    # NOT an error, so it exits 0 quietly (see the file check below for why the
    # exit code alone is not trusted in the save path).
    log "flameshot ${args[*]} --clipboard"
    flameshot "${args[@]}" --clipboard
    rc=$?
    if [[ $rc -ne 0 ]]; then
        log "no capture (exit $rc)"
        exit 0
    fi
    log "copied to clipboard"
    notify -t 2000 "Screenshot copied" "$mode"
    exit 0
fi

out="$OUTDIR/$(date +%Y-%m-%d_%H-%M-%S).png"
tmp="$(mktemp "${TMPDIR:-/tmp}/screenshot-$USER-XXXXXX.png")"
# INT/TERM only (never EXIT) so the trap can't clobber the exit status.
trap 'rm -f "$tmp"' INT TERM

log "flameshot ${args[*]} --raw"
flameshot "${args[@]}" --raw >"$tmp"
rc=$?

# --- validate: discard anything that isn't a real PNG -----------------------
# Aborting the overlay is the common case and is NOT an error, so it exits 0
# quietly. flameshot's exit code alone is not enough: some versions still exit 0
# after an abort and simply write nothing, so the PNG magic is the real test.
if [[ $rc -ne 0 ]] || [[ ! -s "$tmp" ]] || ! head -c 8 "$tmp" | grep -qa $'\x89PNG'; then
    log "no PNG captured (exit $rc, $(stat -c %s "$tmp" 2>/dev/null || echo 0) bytes) — discarding"
    rm -f "$tmp"
    exit 0
fi

mv "$tmp" "$out"
log "saved $out"
notify -t 2000 "Screenshot saved" "${out##*/}"
