# Topics / Zettelkasten Rules

## Purpose

The `Topics/` folder enables Zettelkasten-style atomic notes alongside the goal cascade. While `Goals/` and `Projects/` track actionable work, `Topics/` stores **knowledge** — concepts, people, tools, and ideas that connect across projects and time.

## Structure Rules

1. **FLAT — no subfolders in Topics/** — intentional for maximum graph connectivity
2. **One idea per note** — atomic notes, not encyclopedias
3. **Every topic links to 2-3+ other topics** — isolated notes are useless
4. **ANY noun → [[wiki link]]** — people, places, tools, concepts, years

## When to Create a Topic

- A concept comes up repeatedly across daily notes or projects
- A person, tool, or framework is worth remembering
- An idea needs its own space to develop
- Meeting notes reference something that deserves a permanent note

## When NOT to Create a Topic

- It's a one-time reference (put it in the daily note instead)
- It's an action item (put it in a project or daily task)
- It would just be a stub with no links (wait until it has connections)

## Topic Note Format

```markdown
---
created: YYYY-MM-DD
tags: [topic]
status: developing
---

# Topic Title

## Core Idea
1-2 sentences capturing the essence.

## Related Topics
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

Topics are **referenced by** but not **part of** the goal cascade:
- Projects link to relevant topics: `See [[Authentication]] for design decisions`
- Daily notes link to topics for context: `Discussed [[Rate Limiting]] approach`
- Weekly reviews surface topics that got attention
- Topics link to projects they're relevant to

## Naming Conventions

- Use Title Case: `Authentication.md` not `authentication.md`
- Use natural names: `Rate Limiting.md` not `rate-limiting.md`
- People: `First Last.md` — e.g., `Jessica Siwy.md`
- Dated notes (meetings, transcripts) go in `Daily Notes/`, not `Topics/`
