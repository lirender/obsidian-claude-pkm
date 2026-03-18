---
name: calendar-sync
description: Sync macOS calendar to daily note, create meeting notes with attendees and join links, and time-block the day. Called by /daily morning routine or manually.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(*/ical-today.sh), TaskCreate, TaskUpdate
user-invocable: false
---

# Calendar Sync Skill

Pulls today's calendar events via icalBuddy (macOS Calendar/Exchange) and structures them into the daily note with linked meeting notes.

## Prerequisites

- `icalBuddy` installed (`brew install ical-buddy`)
- Terminal.app has calendar access (System Settings → Privacy → Calendars)
- Script at `.claude/scripts/ical-today.sh`

## What It Does

### 1. Fetch Calendar
Run `.claude/scripts/ical-today.sh` to get today's events from all macOS calendars (iCloud, Exchange, Google synced to Mac).

### 2. Parse Events
For each event extract:
- **Title** — the event name
- **Time** — start and end time
- **Location** — physical or "Microsoft Teams Meeting" / "Zoom Meeting"
- **Attendees** — list of people (strip " -Contractor" suffixes, remove the vault owner's name)
- **Meeting link** — first `https://teams.microsoft.com/meet` or `https://zoom.us` or `https://meet.google.com` URL found in notes (use the clean URL, not the safelinks wrapper)

### 3. Update Daily Note
Add a `## Schedule` section to today's daily note:

```markdown
## Schedule
- 08:00–09:00 — [[2024-01-15 Sprint Planning]] — [Join](https://teams.microsoft.com/meet/xxx)
- 09:00–09:45 — Block
- 10:00–10:30 — [[2024-01-15 Compliance Sync]] — [Join](https://zoom.us/xxx)
```

Rules:
- Events WITH attendees get a linked meeting note `[[YYYY-MM-DD Title]]`
- Events WITHOUT attendees (blocks, focus time) listed without links
- Don't duplicate the schedule if it already exists

### 4. Create Meeting Notes
For each event with attendees, create `Daily Notes/YYYY-MM-DD Title.md`:

```markdown
---
date: YYYY-MM-DD
tags: [meeting]
---

# Meeting Title

## Info
- **When:** YYYY-MM-DD HH:MM–HH:MM
- **Link:** [Join Meeting](meeting_link)
- **Attendees:** [[Person 1]], [[Person 2]]

## Agenda


## Notes


## Action Items
- [ ]

## Related
- [[YYYY-MM-DD]]
```

Rules:
- Each attendee name is a [[wiki link]]
- Don't overwrite existing meeting notes
- Place meeting notes in `Daily Notes/` alongside the daily note

### 5. Time-Block the Day
After calendar sync, suggest time blocks between meetings:

```markdown
## Time Blocks
- 07:30–08:00 — Morning review
- 08:00–09:00 — [[Meeting Name]]
- 09:15–10:00 — Deep work: [task from daily note]
- 10:00–10:30 — [[Meeting Name]]
- 10:45–12:00 — Deep work: [task]
- 12:00–13:00 — Lunch
- 13:00–17:00 — [task]
```

Rules:
- Minimum 45-minute blocks for deep work
- 15-minute buffer after meetings for context switching
- Lunch 12:00–13:00 unless meeting scheduled
- Don't plan past 17:00 unless asked
- Match tasks from the daily note to available blocks

## Fallback

If icalBuddy is not installed or fails:
- Check if Google Calendar MCP tools are available
- Fall back to Google Calendar MCP for event data
- Note: Google Calendar MCP may lack attendees for Exchange/iCal events
- Inform the user about the limitation

## Integration

Called by `/daily` morning routine after creating the daily note and pulling incomplete tasks. Can also be invoked directly when asking to sync calendar or check meetings.
