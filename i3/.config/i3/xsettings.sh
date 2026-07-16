#!/bin/sh

# Pop!_OS 24.04's cosmic-greeter launches i3 via a bare `Exec=i3`, bypassing
# /etc/X11/Xsession, so ~/.xprofile is never sourced and ~/.Xresources is never
# loaded (Xft.dpi ignored -> 4K panels render at 1x, tiny UI). Load it here,
# where i3 reliably exec's this script at startup. On distros whose display
# manager already loaded it (e.g. Manjaro via Xsession) the re-merge is a no-op.
# Display-dependent knobs (Xft.dpi, Xcursor.size) live in per-host overlays
# (.Xresources.$(hostname)) merged after the universal base — same per-host
# pattern as display_setup.sh — so one machine's DPI never leaks onto another.
if command -v xrdb >/dev/null; then
    db_before=$(xrdb -query 2>/dev/null | sort)
    [ -r "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
    [ -r "$HOME/.Xresources.$(hostname)" ] && xrdb -merge "$HOME/.Xresources.$(hostname)"
    db_after=$(xrdb -query 2>/dev/null | sort)
    # If the merge changed the resource DB at all, this session started before
    # ~/.Xresources was loaded (the cosmic-greeter path above) and anything
    # already running may have latched stale values. Nudge such consumers here.
    # Today that is only i3: it reads Xft.dpi ONCE at its own startup to size
    # pango fonts (window titles + i3bar), so it locked in the 96-DPI fallback
    # and the bar renders tiny on HiDPI panels; `restart` makes i3/i3bar
    # re-read the DB in place. No loop: plain `exec` lines (which run this
    # script) do not re-run on `restart`, and on hosts where the display
    # manager already loaded .Xresources the merge is a no-op, so no restart.
    if [ "$db_before" != "$db_after" ] && command -v i3-msg >/dev/null; then
        i3-msg restart >/dev/null 2>&1
    fi
fi

# Keep GTK's cursor-size in sync with Xcursor.size so the pointer is the SAME
# size over every window. libXcursor apps (terminal, root) read the X resource,
# but GTK apps (Chromium UI, rofi) read gsettings cursor-size instead -- if the
# two disagree the cursor visibly changes size between windows. Single source of
# truth: Xcursor.size in ~/.Xresources; mirror it into gsettings here.
cursor_size=$(xrdb -query 2>/dev/null | awk '/Xcursor.size/ {print $2}')
if [ -n "$cursor_size" ] && command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface cursor-size "$cursor_size"
fi

# Push X11 vars into the D-Bus activation environment and the systemd user
# manager. Pop!_OS 24.04 uses dbus-broker, which spawns D-Bus-activated services
# (flameshot v12's org.flameshot.Flameshot, and any activated GUI app) as
# transient systemd user units — those inherit the user manager's environment,
# which has no DISPLAY/XAUTHORITY, so the activated app aborts with
# "qt.qpa.xcb: could not connect to display". Classic dbus-daemon inherited the
# session env, which is why this only broke after the 24.04 upgrade.
command -v dbus-update-activation-environment >/dev/null &&
    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY

# The greeter also leaves an oversized HiDPI cursor on the X root window that
# carries into the i3 session. Reset the root cursor to the theme default at the
# size pinned by Xcursor.size in ~/.Xresources.
command -v xsetroot >/dev/null && xsetroot -cursor_name left_ptr

# fast keystrokes
xset r rate 300 60

# screen timeout (3 hours)
xset dpms 10800 10800 10800
xset s 10800

# keyboard layout
setxkbmap -layout "us,tr" -option "grp:win_space_toggle"
