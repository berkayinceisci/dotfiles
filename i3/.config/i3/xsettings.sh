#!/bin/sh

# Pop!_OS 24.04's cosmic-greeter launches i3 via a bare `Exec=i3`, bypassing
# /etc/X11/Xsession, so ~/.xprofile is never sourced and ~/.Xresources is never
# loaded (Xft.dpi ignored -> 4K panels render at 1x, tiny UI). Load it here,
# where i3 reliably exec's this script at startup.
[ -r "$HOME/.Xresources" ] && command -v xrdb >/dev/null && xrdb -merge "$HOME/.Xresources"

# Keep GTK's cursor-size in sync with Xcursor.size so the pointer is the SAME
# size over every window. libXcursor apps (terminal, root) read the X resource,
# but GTK apps (Chromium UI, rofi) read gsettings cursor-size instead -- if the
# two disagree the cursor visibly changes size between windows. Single source of
# truth: Xcursor.size in ~/.Xresources; mirror it into gsettings here.
cursor_size=$(xrdb -query 2>/dev/null | awk '/Xcursor.size/ {print $2}')
if [ -n "$cursor_size" ] && command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface cursor-size "$cursor_size"
fi

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
