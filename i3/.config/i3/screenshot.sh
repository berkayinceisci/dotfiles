#!/bin/bash
# Save a screenshot to ~/Pictures (X11, flameshot backend).
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
# Usage: screenshot.sh [region|window] [-v|--verbose]
#   region  select an area in the flameshot GUI (default)
#   window  pre-select the currently focused window (still editable in the GUI)
set -uo pipefail

OUTDIR="$HOME/Pictures"

mode="region"
verbose=0
for arg in "$@"; do
    case "$arg" in
    region | window) mode="$arg" ;;
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

out="$OUTDIR/$(date +%Y-%m-%d_%H-%M-%S).png"
tmp="$(mktemp "${TMPDIR:-/tmp}/screenshot-$USER-XXXXXX.png")"
# INT/TERM only (never EXIT) so the trap can't clobber the exit status.
trap 'rm -f "$tmp"' INT TERM

# --- capture ----------------------------------------------------------------
case "$mode" in
region)
    log "flameshot gui --raw"
    flameshot gui --raw >"$tmp"
    rc=$?
    ;;
window)
    # Feed the focused window's geometry to flameshot as the initial selection.
    # With no focused window xdotool prints nothing, which under `set -u` would
    # abort on ${WIDTH} and strand the temp file — fall back to a plain region.
    eval "$(xdotool getactivewindow getwindowgeometry --shell 2>/dev/null)"
    if [[ -z "${WIDTH:-}" ]]; then
        log "no focused window — falling back to region"
        flameshot gui --raw >"$tmp"
        rc=$?
    else
        log "flameshot gui --region ${WIDTH}x${HEIGHT}+${X}+${Y} --raw"
        flameshot gui --region "${WIDTH}x${HEIGHT}+${X}+${Y}" --raw >"$tmp"
        rc=$?
    fi
    ;;
esac

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
