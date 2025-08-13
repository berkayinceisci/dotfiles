#!/bin/bash

# Check if HDMI-1-1 is connected, if so make the external monitor primary
if xrandr | grep "^HDMI-1-0 connected"; then
    xrandr --output HDMI-1-0 --mode 2560x1440 --rate 120.00 --right-of eDP-1
elif xrandr | grep "^HDMI-1-1 connected"; then
    xrandr --output HDMI-1-1 --mode 2560x1440 --rate 120.00 --right-of eDP-1
fi
