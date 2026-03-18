---
name: transcript
description: Process a pasted meeting transcript into a linked summary note with extracted decisions and action items. Use when the user pastes a meeting transcript or asks to process meeting notes.
allowed-tools: Read, Write, Edit, Glob, Grep, TaskCreate, TaskUpdate
user-invocable: true
---

# Transcript Processing Skill

Processes pasted meeting transcripts into structured summary notes linked to meeting notes.

## Usage

```
/transcript
```

Then paste the transcript when prompted. Or paste the transcript directly and ask Claude to process it.

## What It Does

### 1. Identify the Meeting
- Ask which meeting the transcript is for
- Or auto-match by attendee names/topic to today's meeting notes in `Daily Notes/YYYY-MM-DD *.md`
- If no matching meeting note exists, create one first

### 2. Create Transcript Note
Create `Daily Notes/YYYY-MM-DD Meeting Title — Transcript.md`:

```markdown
---
date: YYYY-MM-DD
tags: [transcript]
---

# Meeting Title — Transcript

**Meeting:** [[YYYY-MM-DD Meeting Title]]
**Date:** YYYY-MM-DD

## Summary
- Key point 1 (concise, decision-focused)
- Key point 2
- Key point 3

## Key Decisions
- Decision 1
- Decision 2

## Action Items
- [ ] [[Person]] — task description
- [ ] [[Person]] — task description

## Full Transcript
{pasted transcript — preserved as-is}

## Related
- [[YYYY-MM-DD]]
```

### 3. Update Meeting Note
Find the original meeting note and:
- Add extracted action items under `## Action Items`
- Add link under `## Related`: `- Transcript: [[YYYY-MM-DD Meeting Title — Transcript]]`
- Don't duplicate if already linked

### 4. Update Daily Tasks
- Add action items assigned to the vault owner to the daily note's task section
- Link each task to the meeting note

## Processing Rules

### Summary
- 3-5 bullets maximum
- Focus on decisions and outcomes, not discussion
- Use past tense ("Agreed to...", "Decided that...")

### Action Items
- Always include [[person]] responsible as wiki-link
- Include deadline if mentioned
- Be specific — "Draft API spec by Friday" not "Work on API"

### Linking
- **ANY noun → [[wiki link]]** — people, projects, tools, concepts
- Link to relevant projects if recognizable
- Attendee names always get [[wiki links]]

### Transcript Handling
- Preserve the full transcript as-is in the note
- If the user asks to "clean" the transcript, remove filler words and false starts
- Never modify the transcript without being asked

## Integration

Works with:
- `/daily` - Meeting notes created during morning calendar sync
- Calendar sync skill - Its meeting notes are the natural target for transcripts
- Goal tracking - Action items can be linked to projects/goals
