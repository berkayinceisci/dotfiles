#!/bin/bash

HOST=$(hostname)

case "$HOST" in
    "berkay") # manjaro and ubuntu
        if xrandr | grep "^HDMI-1-0 connected" > /dev/null; then
            xrandr --output HDMI-1-0 --mode 2560x1440 --rate 120.00 --right-of eDP-1
        elif xrandr | grep "^HDMI-1-1 connected" > /dev/null; then
            xrandr --output HDMI-1-1 --mode 2560x1440 --rate 120.00 --right-of eDP-1
        fi
        ;;
    "pop-os")
        if xrandr | grep "^HDMI-1 connected" > /dev/null; then
            xrandr --output HDMI-1 --mode 3840x2160 --rate 60.00
        elif xrandr | grep "^HDMI-2 connected" > /dev/null; then
            xrandr --output HDMI-2 --mode 3840x2160 --rate 60.00
        ;;
esac
