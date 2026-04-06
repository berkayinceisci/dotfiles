#!/bin/bash
set -euo pipefail

# Opens a terminal. If a file viewer is focused, opens the terminal in its directory.
#
# Supports:
# - TUI file managers in terminals (yazi, ranger, nnn, lf): reads /proc/PID/cwd (reliable)
# - GUI file managers (Thunar, Nautilus, Nemo, PCManFM, Dolphin, Caja): parses window
#   title to extract directory basename, then resolves to full path (best-effort)

WEZTERM="wezterm --config-file $HOME/.config/wezterm/wezterm.lua"

# TUI file managers to detect in terminal process trees
TUI_FMS="yazi|ranger|nnn|lf"

# Terminal emulator WM_CLASS patterns
TERMINALS="wezterm|alacritty|kitty|xterm|urxvt|st-256color|gnome-terminal|konsole|tilix|foot|termite"

open_in_dir() {
    if [[ -n "$1" && -d "$1" ]]; then
        exec $WEZTERM start --cwd "$1"
    fi
}

# Resolve a folder basename (from a GUI file manager's title) to a full path.
# Returns 1 if resolution fails.
resolve_basename() {
    local name="$1"

    # Special names
    case "$name" in
        Home|home)       echo "$HOME"; return 0 ;;
        "File System"|/) echo "/";     return 0 ;;
        Trash*|trash*)   return 1 ;;
        "")              return 1 ;;
    esac

    # Already an absolute path (some file managers show the full path in the title)
    if [[ "$name" == /* && -d "$name" ]]; then
        echo "$name"; return 0
    fi

    # Home directory itself (title shows username, e.g. "berkay - Thunar")
    if [[ "$(basename "$HOME")" == "$name" && -d "$HOME" ]]; then
        echo "$HOME"; return 0
    fi

    # Direct child of $HOME (covers Documents, Downloads, Desktop, dotfiles, projects, ...)
    if [[ -d "$HOME/$name" ]]; then
        echo "$HOME/$name"; return 0
    fi

    # Root-level directory (e.g. "tmp" → /tmp, "var" → /var)
    if [[ -d "/$name" ]]; then
        echo "/$name"; return 0
    fi

    # Subdirectories of common mount points
    for prefix in /tmp /media /mnt; do
        if [[ -d "$prefix/$name" ]]; then
            echo "$prefix/$name"; return 0
        fi
    done

    # Mount points under /media/$USER and /mnt
    for dir in /media/"$USER"/"$name" /mnt/*/"$name"; do
        if [[ -d "$dir" ]]; then
            echo "$dir"; return 0
        fi
    done

    # Bounded search in $HOME (maxdepth 4, stops at first match)
    local found
    found=$(find "$HOME" -maxdepth 4 -type d -name "$name" -print -quit 2>/dev/null) || true
    if [[ -n "$found" ]]; then
        echo "$found"; return 0
    fi

    return 1
}

# --- Main ---

WID=$(xdotool getactivewindow 2>/dev/null) || exec $WEZTERM
WIN_CLASS=$(xprop -id "$WID" WM_CLASS 2>/dev/null | grep -oP '"[^"]+"' | tail -1 | tr -d '"') || WIN_CLASS=""
WIN_CLASS_LOWER="${WIN_CLASS,,}"

# 1) Terminal with a TUI file manager
if echo "$WIN_CLASS_LOWER" | grep -qE "$TERMINALS"; then
    WIN_PID=$(xdotool getwindowpid "$WID" 2>/dev/null) || WIN_PID=""
    if [[ -n "$WIN_PID" ]]; then
        FM_PID=$(pstree -p "$WIN_PID" | grep -oP "($TUI_FMS)\(\K[0-9]+(?=\))" | head -1) || FM_PID=""
        if [[ -n "$FM_PID" ]]; then
            open_in_dir "$(readlink "/proc/$FM_PID/cwd" 2>/dev/null)"
        fi
    fi
fi

# 2) GUI file manager — detect by WM_CLASS pattern and strip known title suffixes
# Each entry: "class_substr|title_suffix_regex"
# The suffix is stripped from the window title to extract the folder basename.
GUI_FMS=(
    "thunar| - Thunar$"
    "nautilus| – [^–]+$"
    "nemo| — Nemo$"
    "pcmanfm| - PCManFM$"
    "dolphin| — Dolphin$"
    "caja| - Caja$"
)

for entry in "${GUI_FMS[@]}"; do
    fm_class="${entry%%|*}"
    title_regex="${entry#*|}"

    if echo "$WIN_CLASS_LOWER" | grep -qi "$fm_class"; then
        WIN_NAME=$(xdotool getwindowname "$WID" 2>/dev/null) || WIN_NAME=""
        # Strip the file manager's title suffix to get the folder basename
        basename=$(echo "$WIN_NAME" | sed -E "s/${title_regex}//") || basename="$WIN_NAME"
        basename=$(echo "$basename" | xargs) # trim whitespace
        DIR=$(resolve_basename "$basename") || DIR=""
        open_in_dir "$DIR"
        break
    fi
done

# 3) Fallback: open terminal normally
exec $WEZTERM
