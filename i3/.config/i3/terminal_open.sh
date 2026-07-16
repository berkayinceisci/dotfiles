#!/bin/bash
set -euo pipefail

# Opens a terminal. If a file viewer is focused, opens the terminal in its directory.
#
# Supports:
# - TUI file managers in terminals (yazi, ranger, nnn, lf): reads /proc/PID/cwd (reliable)
# - GUI file managers (Thunar, Nautilus, Nemo, PCManFM, Dolphin, Caja): parses window
#   title to extract directory basename, then resolves to full path (best-effort)
# - Plain shells in wezterm windows: asks the focused wezterm GUI instance for its
#   focused pane's cwd (reliable); if the pane's foreground process is an attached
#   tmux client, asks the tmux server for that client's active pane path instead
#   (reliable)

# -v/--verbose: log branch decisions and resolved directories to stderr
VERBOSE=0
if [[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]]; then
    VERBOSE=1
fi

log() {
    if [[ $VERBOSE -eq 1 ]]; then
        echo "terminal_open: $*" >&2
    fi
}

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

# Decode %XX escapes in a file:// URI (wezterm percent-encodes pane cwd paths).
url_decode() {
    printf '%b' "${1//%/\\x}"
}

# --- Main ---

WID=$(xdotool getactivewindow 2>/dev/null) || exec $WEZTERM
WIN_CLASS=$(xprop -id "$WID" WM_CLASS 2>/dev/null | grep -oP '"[^"]+"' | tail -1 | tr -d '"') || WIN_CLASS=""
WIN_CLASS_LOWER="${WIN_CLASS,,}"
log "active window $WID class '$WIN_CLASS_LOWER'"

# 1) Terminal focused
if echo "$WIN_CLASS_LOWER" | grep -qE "$TERMINALS"; then
    WIN_PID=$(xdotool getwindowpid "$WID" 2>/dev/null) || WIN_PID=""

    # 1a) TUI file manager running inside it: its cwd wins
    if [[ -n "$WIN_PID" ]]; then
        FM_PID=$(pstree -p "$WIN_PID" | grep -oP "($TUI_FMS)\(\K[0-9]+(?=\))" | head -1) || FM_PID=""
        if [[ -n "$FM_PID" ]]; then
            log "TUI file manager pid $FM_PID"
            open_in_dir "$(readlink "/proc/$FM_PID/cwd" 2>/dev/null)"
        fi
    fi

    # 1b) Plain shell (or tmux) in a wezterm window: the wezterm mux tracks
    # per-pane cwd natively, so ask the focused GUI instance. The socket must
    # be targeted explicitly (gui-sock-<pid> of the focused window, one GUI
    # process per `wezterm start`): without WEZTERM_UNIX_SOCKET, `wezterm cli`
    # outside a pane falls back to the mux-server socket and spawns a stray
    # headless mux server.
    GUI_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/wezterm/gui-sock-${WIN_PID}"
    if [[ "$WIN_CLASS_LOWER" == *wezterm* ]]; then
        log "wezterm gui pid '$WIN_PID', socket $GUI_SOCK $(if [[ -S "$GUI_SOCK" ]]; then echo present; else echo MISSING; fi)"
    fi
    if [[ "$WIN_CLASS_LOWER" == *wezterm* && -n "$WIN_PID" && -S "$GUI_SOCK" ]] &&
        command -v jq >/dev/null 2>&1; then
        # Identify the active pane via the X window title, NOT via
        # `wezterm cli list-clients` focused_pane_id: that field never updates
        # on tab switches for GUI clients (wezterm 20240203), so with several
        # tabs it points at whichever pane was focused first. The GUI keeps the
        # X title current and prefixes it with "[N/M] " (active tab index /
        # tab count) when a window has multiple tabs — parse that to find the
        # active tab, then take its active pane; prefer an exact pane-title
        # match to disambiguate several mux windows in one GUI process.
        WIN_NAME=$(xdotool getwindowname "$WID" 2>/dev/null) || WIN_NAME=""
        TAB_N=0
        TAB_M=0
        TITLE="$WIN_NAME"
        if [[ "$WIN_NAME" =~ ^\[([0-9]+)/([0-9]+)\]\ (.*)$ ]]; then
            TAB_N=${BASH_REMATCH[1]}
            TAB_M=${BASH_REMATCH[2]}
            TITLE=${BASH_REMATCH[3]}
        fi
        log "X title '$WIN_NAME' -> tab $TAB_N/$TAB_M, pane title '$TITLE'"
        PANE_JSON=$(WEZTERM_UNIX_SOCKET="$GUI_SOCK" wezterm cli list --format json 2>/dev/null |
            jq -c --argjson n "$TAB_N" --argjson m "$TAB_M" --arg t "$TITLE" '
                def dedup: reduce .[] as $x ([]; if index($x) then . else . + [$x] end);
                . as $panes
                | ([$panes[].window_id] | dedup) as $wins
                | [ $wins[] as $w
                    | ([$panes[] | select(.window_id == $w) | .tab_id] | dedup) as $tabs
                    | if $n > 0 and ($tabs | length) == $m
                      then $panes[] | select(.tab_id == $tabs[$n-1] and .is_active)
                      elif $n == 0 and ($tabs | length) == 1
                      then $panes[] | select(.tab_id == $tabs[0] and .is_active)
                      else empty
                      end ]
                | (map(select(.title == $t)) | .[0]) // .[0] // empty') || PANE_JSON=""
        if [[ -n "$PANE_JSON" ]]; then
            PANE_TTY=$(jq -r '.tty_name // empty' <<<"$PANE_JSON") || PANE_TTY=""
            if [[ -n "$PANE_TTY" ]]; then
                FG_INFO=$(ps -o stat=,pid=,comm= -t "${PANE_TTY#/dev/}" 2>/dev/null |
                    awk '$1 ~ /\+/ {print $2, $3; exit}') || FG_INFO=""
                FG_PID=${FG_INFO%% *}
                FG_COMM=${FG_INFO#* }
                # tmux refinement: when an attached tmux client is the pane's
                # foreground process, the pane cwd is merely where the client was
                # launched — ask the tmux server for that client's active pane path.
                if [[ "$FG_COMM" == tmux* ]]; then
                    log "tmux client on $PANE_TTY"
                    open_in_dir "$(tmux display-message -p -c "$PANE_TTY" '#{pane_current_path}' 2>/dev/null)"
                elif [[ -n "$FG_PID" ]]; then
                    # Plain shell: read the foreground process's cwd straight
                    # from /proc — always current. Do NOT trust the pane cwd
                    # wezterm reports: it is refreshed at the START of an
                    # output burst, before the typed command runs, so it lags
                    # one command behind (`cd` then Alt+Return would open the
                    # PREVIOUS directory).
                    log "fg pid $FG_PID ($FG_COMM) on $PANE_TTY"
                    open_in_dir "$(readlink "/proc/$FG_PID/cwd" 2>/dev/null)"
                fi
            fi

            # Fallback (no tty / unreadable fg process): wezterm's cached pane
            # cwd, a percent-encoded file:// URI. May lag one command behind.
            CWD_URI=$(jq -r '.cwd // empty' <<<"$PANE_JSON") || CWD_URI=""
            if [[ -n "$CWD_URI" ]]; then
                DIR=$(url_decode "$CWD_URI")
                DIR=${DIR#file://} # strip scheme
                DIR="/${DIR#*/}"   # strip hostname ("" for file:///path)
                log "wezterm pane $(jq -r '.pane_id' <<<"$PANE_JSON") cwd $DIR"
                open_in_dir "$DIR"
            fi
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
log "fallback: no cwd resolved, opening in \$HOME"
exec $WEZTERM
