#!/bin/bash

# Called by udev on DRM hotplug events (monitor connect/disconnect).
# Runs as root — must switch to the X session user.

LOCK="/tmp/hotplug_display.lock"

# Debounce: skip if another instance ran in the last 5 seconds
# (udev fires multiple events per single hotplug)
if [[ -f "$LOCK" ]]; then
    last=$(stat -c %Y "$LOCK" 2>/dev/null || echo 0)
    now=$(date +%s)
    if (( now - last < 5 )); then
        exit 0
    fi
fi
touch "$LOCK"

# Find the user owning the X session
X_USER=$(who | awk '/:0/ || /:1/ {print $1; exit}')
if [[ -z "$X_USER" ]]; then
    exit 0
fi

X_HOME=$(eval echo "~$X_USER")
export DISPLAY=:0
export XAUTHORITY="$X_HOME/.Xauthority"

# Delay for hardware to stabilize after hotplug
sleep 2

# Run display setup as the X user
su "$X_USER" -c "DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $X_HOME/.config/i3/display_setup.sh"

# Reload i3 to pick up workspace/wallpaper changes
su "$X_USER" -c "DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY i3-msg reload" 2>/dev/null || true
