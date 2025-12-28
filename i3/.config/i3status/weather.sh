#!/bin/bash

CITY="Blacksburg"

# Fetch weather from wttr.in with minimal format
# %C = condition, %t = temperature
weather=$(curl -s "wttr.in/$CITY?format=%C+%t" --max-time 5 | tr -d '\n')
exit_code=$?

# If curl fails or returns empty, show fallback
if [ -z "$weather" ] || [ $exit_code -ne 0 ]; then
    echo "$CITY: N/A" > /tmp/i3status_weather
else
    echo "$CITY: $weather" > /tmp/i3status_weather
fi
