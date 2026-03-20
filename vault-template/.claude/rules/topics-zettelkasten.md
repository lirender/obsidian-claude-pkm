# Knowledge Notes — Folder Taxonomy & Rules

## Purpose

Knowledge notes live alongside the goal cascade. While `Goals/` and `Projects/` track actionable work, the knowledge folders store **knowledge** — people, companies, concepts, and ideas that connect across projects and time.

## Folder Taxonomy

| Folder | Contains | Examples |
|--------|----------|----------|
| `People/` | People + people groupings (org charts, family trees, team rosters) | `Eli Nasatir.md`, `GTI-Orgchart.md`, `GTI-Orgchart-Commercial.md` |
| `Companies/` | Companies + vendor hubs | `Palantir.md`, `8090.md`, `MOC-Vendors.md` |
| `Concepts/` | Abstract ideas, frameworks, tools | `Rate Limiting.md`, `Authentication.md` |
| `Topics/` | Catch-all — work references, anything that doesn't fit above | `GTI.md` |

## Structure Rules

1. **FLAT within each folder** — no subfolders in People/, Companies/, Concepts/, or Topics/
2. **One idea per note** — atomic notes, not encyclopedias
3. **Every note links to 2-3+ other notes** — isolated notes are useless
4. **ANY noun → [[wiki link]]** — people, places, tools, concepts, years

## MOC Naming Convention

Maps of Content (hub/index notes) use the `MOC-` prefix to distinguish them from regular notes:
- `MOC-Vendors.md` — index of all external companies and contacts
- `MOC-{Name}.md` — any hub that primarily links to and organizes other notes

MOCs live in the folder matching their content type (e.g., `Companies/MOC-Vendors.md`).

## When to Create a Note

- A concept comes up repeatedly across daily notes or projects
- A person, tool, or framework is worth remembering
- An idea needs its own space to develop
- Meeting notes reference something that deserves a permanent note

## When NOT to Create a Note

- It's a one-time reference (put it in the daily note instead)
- It's an action item (put it in a project or daily task)
- It would just be a stub with no links (wait until it has connections)

## Note Format

```markdown
---
created: YYYY-MM-DD
tags: [topic]
status: developing
---

# Note Title

## Core Idea
1-2 sentences capturing the essence.

## Related
- [[Related 1]]
- [[Related 2]]
- [[Related 3]]

---
**Last updated:** YYYY-MM-DD
```

## Status Values

- `developing` — actively being built out
- `stable` — well-established, rarely changes
- `archived` — outdated or superseded

## Integration with Goal Cascade

Knowledge notes are **referenced by** but not **part of** the goal cascade:
- Projects link to relevant notes: `See [[Authentication]] for design decisions`
- Daily notes link to notes for context: `Discussed [[Rate Limiting]] approach`
- Weekly reviews surface notes that got attention
- Notes link to projects they're relevant to

## Naming Conventions

- Use Title Case: `Authentication.md` not `authentication.md`
- Use natural names: `Rate Limiting.md` not `rate-limiting.md`
- People: `First Last.md` in `People/` — e.g., `People/Jessica Siwy.md`
- Companies: `Company Name.md` in `Companies/` — e.g., `Companies/Palantir.md`
- MOCs: `MOC-Name.md` — e.g., `Companies/MOC-Vendors.md`
- Dated notes (meetings, transcripts) go in `Daily Notes/`, not knowledge folders
