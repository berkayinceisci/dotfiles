#!/bin/bash

CITY="Blacksburg"
CACHE_FILE="/tmp/i3status_weather_cache"
OUTPUT_FILE="/tmp/i3status_weather"

# Fetch weather from wttr.in using JSON endpoint (more reliable than format endpoint)
weather=$(curl -s "wttr.in/$CITY?format=j1" --max-time 10 | jq -r '.current_condition[0] | "\(.weatherDesc[0].value) \(.temp_F)°F"' 2>/dev/null)
exit_code=$?

# If curl succeeds and returns data, use it and cache it
if [ -n "$weather" ] && [ $exit_code -eq 0 ]; then
    echo "$CITY: $weather" > "$OUTPUT_FILE"
    echo "$weather" > "$CACHE_FILE"
# If curl fails, try to use cached value
elif [ -f "$CACHE_FILE" ]; then
    cached=$(cat "$CACHE_FILE")
    echo "$CITY: $cached" > "$OUTPUT_FILE"
# No cache available, show N/A
else
    echo "$CITY: N/A" > "$OUTPUT_FILE"
fi
