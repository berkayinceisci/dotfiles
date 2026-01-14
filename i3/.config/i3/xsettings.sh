#!/bin/sh

# fast keystrokes
xset r rate 300 60

# screen timeout (3 hours)
xset dpms 10800 10800 10800
xset s 10800

# keyboard layout
setxkbmap -layout "us,tr" -option "grp:win_space_toggle"
