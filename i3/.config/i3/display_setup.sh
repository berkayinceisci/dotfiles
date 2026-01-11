#!/bin/bash

HOST=$(hostname)

case "$HOST" in
    "manjaro"|"ubuntu")
        # When external connected: use ONLY external, disable laptop
        # When no external: use laptop screen
        if xrandr | grep "^HDMI-1-0 connected" > /dev/null; then
            xrandr --output HDMI-1-0 --mode 2560x1440 --rate 120.00 --primary --output eDP-1 --off
        elif xrandr | grep "^HDMI-1-1 connected" > /dev/null; then
            xrandr --output HDMI-1-1 --mode 2560x1440 --rate 120.00 --primary --output eDP-1 --off
        else
            xrandr --output eDP-1 --auto --primary
        fi
        ;;
    "popos")
        HDMI1_CONNECTED=$(xrandr | grep "^HDMI-1 connected")
        HDMI2_CONNECTED=$(xrandr | grep "^HDMI-2 connected")
        
        if [ -n "$HDMI1_CONNECTED" ] && [ -n "$HDMI2_CONNECTED" ]; then
            # Dual monitor: HDMI-1 primary, HDMI-2 to the right
            xrandr --output HDMI-1 --mode 3840x2160 --rate 60.00 --primary \
                   --output HDMI-2 --mode 3840x2160 --rate 60.00 --right-of HDMI-1
        elif [ -n "$HDMI1_CONNECTED" ]; then
            xrandr --output HDMI-1 --mode 3840x2160 --rate 60.00 --primary
        elif [ -n "$HDMI2_CONNECTED" ]; then
            xrandr --output HDMI-2 --mode 3840x2160 --rate 60.00 --primary
        fi
        ;;
esac
