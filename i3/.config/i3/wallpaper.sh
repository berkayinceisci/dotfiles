#!/bin/bash

# Set wallpapers per monitor
# Uses ~/wallpapers/horizontal/ and ~/wallpapers/vertical/

MAIN_WP=$(find ~/wallpapers/horizontal -maxdepth 1 -type f | shuf -n1)

if [ -d ~/wallpapers/vertical ] && xrandr | grep -q "HDMI-2 connected"; then
    VERT_WP=$(find ~/wallpapers/vertical -maxdepth 1 -type f | shuf -n1)
    feh --bg-fill "$MAIN_WP" "$VERT_WP"
else
    feh --bg-fill --randomize ~/wallpapers/horizontal/*
fi
