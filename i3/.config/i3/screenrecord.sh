#!/bin/bash
# Toggle screen recording (X11) — portable across machines, mirrors the
# flameshot screenshot workflow: first invocation starts, second stops and
# finalizes the mp4.
#
# Backend preference (the keybindings/UX are identical regardless of which runs):
#   1. gpu-screen-recorder native binary  (Manjaro: pacman; hardware-encoded)
#   2. gpu-screen-recorder Flatpak        (Pop!_OS: com.dec05eba.gpu_screen_recorder)
#   3. ffmpeg + slop                      (universal fallback, software-encoded)
#
# Both backends capture desktop audio (default sink monitor) and write mp4 to
# ~/Videos. gpu-screen-recorder uses GPU encoding where available and falls back
# to CPU on its own (-fallback-cpu-encoding yes), so it always records even if
# the VAAPI/NVENC drivers are missing.
#
# Usage: screenrecord.sh [region|window|full]
#   region  select an area with slop (default)
#   window  the currently focused window
#   full    the primary monitor
set -uo pipefail

OUTDIR="$HOME/Videos"
PIDFILE="/tmp/screenrecord-$USER.pid"
LOG="/tmp/screenrecord-$USER.log"
DPY="${DISPLAY:-:0}"

mkdir -p "$OUTDIR"

notify() { command -v notify-send >/dev/null 2>&1 && notify-send "$@"; }

# --- toggle off: stop an in-progress recording ------------------------------
if [[ -f "$PIDFILE" ]]; then
    pid="$(cat "$PIDFILE")"
    if kill -0 "$pid" 2>/dev/null; then
        # SIGINT lets both ffmpeg and gpu-screen-recorder finalize the mp4.
        kill -INT "$pid" 2>/dev/null || true
        for _ in $(seq 1 50); do
            kill -0 "$pid" 2>/dev/null || break
            sleep 0.1
        done
    fi
    rm -f "$PIDFILE"
    notify -t 4000 "Screen recording stopped" "Saved to $OUTDIR"
    exit 0
fi

mode="${1:-region}"
out="$OUTDIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"

# --- resolve the gpu-screen-recorder command (as an array; may be empty) -----
GSR=()
if command -v gpu-screen-recorder >/dev/null 2>&1; then
    GSR=(gpu-screen-recorder)
elif command -v flatpak >/dev/null 2>&1 &&
    flatpak info com.dec05eba.gpu_screen_recorder >/dev/null 2>&1; then
    # Flatpak path (e.g. Pop!_OS). Untested from the dev machine; if it misbehaves
    # the ffmpeg fallback still records, so failures here are non-fatal.
    GSR=(flatpak run --command=gpu-screen-recorder com.dec05eba.gpu_screen_recorder)
fi

# --- primary monitor (name + geometry) for full-screen capture --------------
# Prefer the connector marked "primary"; fall back to the first connected one.
# Echoes: NAME WIDTH HEIGHT X Y
primary_monitor() {
    xrandr --query 2>/dev/null | awk '
        / connected primary / {
            for (i = 1; i <= NF; i++)
                if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) { print $1, $i; found = 1; exit }
        }
        / connected/ && !first {
            for (i = 1; i <= NF; i++)
                if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) { fname = $1; fgeom = $i; first = 1 }
        }
        END { if (!found && first) print fname, fgeom }
    ' | sed -E 's/x|\+/ /g'
}

# --- determine capture geometry (W H X Y) and the per-backend target ---------
mon_name=""
case "$mode" in
region)
    sel="$(slop -f '%w %h %x %y')" || exit 0   # Esc cancels -> non-zero
    [[ -z "$sel" ]] && exit 0
    read -r W H X Y <<<"$sel"
    ;;
window)
    eval "$(xdotool getactivewindow getwindowgeometry --shell)"
    W="$WIDTH"; H="$HEIGHT"
    ;;
full)
    read -r mon_name W H X Y <<<"$(primary_monitor)"
    if [[ -z "${mon_name:-}" ]]; then
        notify -u critical "screenrecord.sh" "could not detect a monitor"
        exit 1
    fi
    ;;
*)
    notify -u critical "screenrecord.sh" "unknown mode: $mode"
    exit 1
    ;;
esac

# H.264 (yuv420p) requires even dimensions.
W=$((W - W % 2))
H=$((H - H % 2))

# --- start recording --------------------------------------------------------
if [[ ${#GSR[@]} -gt 0 ]]; then
    # gpu-screen-recorder backend. -w selects the capture target per mode.
    case "$mode" in
    region) target=(-w region -region "${W}x${H}+${X}+${Y}") ;;
    window) target=(-w focused -s "${W}x${H}") ;; # -w focused requires an output size
    # NB: capture full screen by explicit region, not "-w $mon_name":
    # gpu-screen-recorder's monitor-name capture ignores the monitor's x/y
    # offset, so a non-origin monitor (e.g. one to the right of the laptop)
    # gets the wrong slab and the right edge is cut off.
    full)   target=(-w region -region "${W}x${H}+${X}+${Y}") ;;
    esac
    # NB: do not force "-k h264" — gpu-screen-recorder hard-fails if the GPU
    # lacks that codec instead of using the CPU fallback. Its default already
    # produces h264 (via libx264 on the CPU path).
    "${GSR[@]}" "${target[@]}" \
        -f 30 -a default_output -ac aac \
        -fallback-cpu-encoding yes -cursor yes \
        -o "$out" >"$LOG" 2>&1 &
    backend="gpu-screen-recorder"
else
    # ffmpeg + slop fallback. -nostdin: don't read the (absent) terminal.
    MON="$(pactl get-default-sink 2>/dev/null).monitor"
    ffmpeg -nostdin -y \
        -f x11grab -framerate 30 -video_size "${W}x${H}" -i "${DPY}+${X},${Y}" \
        -f pulse -i "$MON" \
        -c:v libx264 -preset veryfast -pix_fmt yuv420p -crf 23 \
        -c:a aac -b:a 160k \
        "$out" >"$LOG" 2>&1 &
    backend="ffmpeg"
fi

echo $! >"$PIDFILE"
notify -t 2000 "Screen recording started" "${mode} ${W}x${H} via ${backend}"
