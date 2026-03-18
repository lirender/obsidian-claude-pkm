#!/bin/bash
# Fetches today's calendar events via Terminal.app (which has calendar permissions)
# Terminal.app relay needed because some terminal apps lack macOS calendar entitlements
# Requires: brew install ical-buddy, Terminal.app granted calendar access in
#   System Settings → Privacy & Security → Calendars

OUTPUT="/tmp/ical-today.txt"
rm -f "$OUTPUT"

osascript -e 'tell application "Terminal" to do script "icalBuddy -f -nc -nrd -ea -npn -po title,datetime,location,attendees,notes eventsToday > /tmp/ical-today.txt 2>&1 && echo ---DONE--- >> /tmp/ical-today.txt"' > /dev/null 2>&1

# Wait for output (up to 30 seconds)
for i in $(seq 1 30); do
    if grep -q '\-\-\-DONE\-\-\-' "$OUTPUT" 2>/dev/null; then
        grep -v -- '---DONE---' "$OUTPUT" | sed $'s/\033\[[0-9;]*m//g'
        exit 0
    fi
    sleep 1
done

echo "Timeout waiting for icalBuddy"
exit 1
