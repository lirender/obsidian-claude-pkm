---
name: contacts
description: Enrich external contacts from calendar meetings — scan daily notes for unprocessed externals, get emails via Outlook Calendar, extract signatures from Outlook Mail, research companies, and create/update Vendors hub + company + contact notes. Defaults to 90-day lookback. Tracks processed dates in daily note frontmatter to avoid redundant work.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite, WebSearch, WebFetch, mcp__Claude_in_Chrome__navigate, mcp__Claude_in_Chrome__tabs_context_mcp, mcp__Claude_in_Chrome__tabs_create_mcp, mcp__Claude_in_Chrome__computer, mcp__Claude_in_Chrome__get_page_text, mcp__Claude_in_Chrome__read_page, mcp__Claude_in_Chrome__find
user-invocable: true
---

# Contacts Enrichment Skill

Enriches external contacts found in Outlook Calendar meetings. Scans daily notes for `(external)` markers, skips dates already processed, hits Outlook only for new contacts, and writes vault notes.

**Output:**
- `Topics/Vendors.md` — hub of all external companies + contacts
- `Topics/{Company}.md` — one per company, with contact list + meeting history
- `Topics/{First Last}.md` — one per person, with full contact card
- Updates daily note frontmatter: `contacts_extracted: YYYY-MM-DD`

## Usage

```
/contacts
```

Then either:
- Provide names: "Eli Nasatir, Julia James" → skip vault scan, go straight to Phase 2
- Provide date range: "scan January 2026" → scan only that window
- Say nothing → default: scan last 90 days, ask to confirm

Or ask: "Enrich my external contacts", "Create contact notes for the Palantir team"

---

## Phase 0 — Scope

**Ask the user** (default pre-selected):

> "I'll scan daily notes for unprocessed external contacts. Default window: last 90 days ({date - 90d} to today). Press enter to confirm or specify a different range."

If user confirms → compute `start_date = today - 90 days`.
If user gives explicit range → use that.
If user gives names directly → skip to Phase 2 with those names.

---

## Phase 1 — Vault Scan (no browser)

Scan daily notes to find dates with unprocessed external contacts. This phase is **entirely file-based** — no Outlook, no browser.

### 1a. Migration check (first run only)

Before scanning, check if this is the first ever run:
- If `Topics/Vendors.md` exists → skill has run before, skip migration
- If `Topics/Vendors.md` does NOT exist → first run: perform migration (see below)

### 1b. Scan daily notes in range

```
files = Glob("Daily Notes/*.md") where filename date is in [start_date, today]
```

**How external contacts appear in daily notes:**
The `/daily` skill writes every non-`@gtigrows.com` attendee as `[[Name]] (external)` in the schedule table, regardless of whether the meeting title has `[EXTERNAL]` or not. A meeting titled "Weekly Sync" organized by an internal person can still contain `[[Vendor Contact]] (external)` — the tag is on the *person*, not the meeting. This is the canonical signal — not the meeting title.

For each file:

1. **Read frontmatter** — look for `contacts_extracted: YYYY-MM-DD` field
   - If present → **skip this date** (already processed)
2. **Grep for `(external)`** in the file content
   - If found → extract names: scan all lines for the pattern `[[Name]] (external)`
   - Also capture the meeting row that line appears in (to know which meeting date/title to open in Outlook)
   - Add to work list: `{ date, contacts: [{ name, meeting_title }] }`
3. **Cross-check against existing topic notes**
   - For each name: check if `Topics/{Name}.md` exists AND has an email field
   - If yes → contact already enriched (likely from a previous manual run)
   - Mark date as: `needs_frontmatter_only` — just stamp frontmatter, skip browser

### 1c. Build work list

```
to_process = [
  { date: "2026-01-12", names: ["Eli Nasatir", "Sammy Moseley", "Tom McArdle"] },
  ...
]
needs_frontmatter_only = [
  { date: "2026-01-12" },  # topics exist, just missing frontmatter marker
  ...
]
new_contacts = ["Julia James"]  # no Topics/{Name}.md exists → needs full enrichment
```

**Report to user before continuing:**
> "Found N dates with external contacts in the last 90 days:
> - Already enriched (just marking done): 4 dates
> - New contacts needing enrichment: X
> Proceeding..."

---

## Phase 1.5 — Migration (first run only, no Vendors.md exists)

When running the skill for the first time against an existing vault:

1. **Glob all daily notes ever** (not just 90 days)
2. For each: grep for `(external)`
3. For each name found with `(external)`:
   - Check if `Topics/{Name}.md` exists with email populated
   - If yes → this contact was manually enriched before the skill existed
   - Add date to `needs_frontmatter_only` list
   - Add contact to "already known" set (skip enrichment)
4. After marking, continue with normal Phase 2+ for any genuinely new contacts

**Migration report:**
> "Migration: Found N previously enriched contacts across M dates. Marking those dates as done. Will enrich X new contacts."

---

## Phase 2 — Get Emails from Outlook Calendar

**Only run this phase for contacts NOT already in `needs_frontmatter_only`.**

The work list from Phase 1 contains `{ date, contact_name, meeting_title }` for each person. Use that — not any meeting-title filter — to know which meeting to open.

1. `mcp__Claude_in_Chrome__tabs_context_mcp` — verify Chrome connected (once, at start)
   - Not connected → stop: "Connect claude-in-chrome and log into Outlook first"
2. Navigate to `outlook.office.com/calendar/view/day/YYYY/M/DD`
3. **Find the meeting by title** from the daily note — it might be any meeting, internal or external. Do NOT filter by `[EXTERNAL]` in the title; that prefix only appears when the *organizer* is external and is irrelevant here.
4. **Double-click** the meeting to open full event view
5. In the **Tracking** panel (right side), click the contact's name → contact card popup
6. Read the **Email** field
7. Record: `name → email`

**If email is `@gtigrows.com`** → false positive (they're GTI staff), remove from list, note the discrepancy.
**If no email in card** → note `email_unknown`, continue.

**Efficiency — batch by date:** Group contacts by date before opening Outlook. For a given day, navigate once and collect all contacts from all meetings on that day before moving to the next date. For contacts in the same meeting, click all their names before navigating away.

---

## Phase 3 — Extract Signatures from Outlook Mail

For each contact with a known email:

1. Navigate once to `outlook.office.com/mail/` (reuse if already there)
2. Search bar → `from:{email}` → Enter
3. **If results found:** open most recent non-invite email
   - Scroll to signature block
   - Extract: title/role, phone, official company name
4. **If no results or only invites:** note `No email history` — title and phone = `Unknown`

**Calendar invite detection:** skip emails where subject starts with "Invitation:", "Updated invitation:", or body is only Zoom/Teams join link with no prose.

**Mismatch flag:** signature email ≠ calendar email → add `⚠️ Email mismatch: calendar={A}, signature={B}` to contact note. Always continue.

---

## Phase 4 — Research Companies

For each unique email domain:

1. **Known companies** (Palantir, Google, Microsoft, etc.) → use training knowledge
2. **Unknown domain:**
   - `WebFetch https://{domain}` → one-liner, industry, HQ
   - If blocked → `WebSearch "{domain} company about"`
3. **Check** if `Topics/{Company}.md` exists → update rather than recreate

---

## Phase 5 — Write Vault Notes

Write in order: company notes → contact notes → Vendors hub.

### 5a. Company Note — `Topics/{Company}.md`

Check existence first. If exists, append new contacts + meetings only.

```markdown
---
created: YYYY-MM-DD
tags: [topic, work, vendor]
status: developing
---

# {Company}

## Core Idea
{1-2 sentences}. [[GTI]] engaged via {meeting context}.

## Company Details
- **Full name:** {legal name}
- **Domain:** {domain}
- **Industry:** {industry}
- **HQ:** {city, state}

## Contacts at {Company}

### [[First Last]]
- **Title:** {from sig, or "Unknown"}
- **Email:** {email}
- **Phone:** {from sig, or "—"}

## Meeting History
- [[YYYY-MM-DD]] — {meeting title}

## Related
- [[Vendors]]
- [[GTI]]

---
**Last updated:** YYYY-MM-DD
```

### 5b. Contact Note — `Topics/{First Last}.md`

Check existence first. If exists, update fields only if new data — **never overwrite `> blockquote`**.

```markdown
---
created: YYYY-MM-DD
tags: [topic, work, contact]
status: developing
company: "[[{Company}]]"
---

# {First Last}

## Contact Details
- **Title:** {from sig, or "Unknown — no email history"}
- **Company:** [[{Company}]]
- **Email:** {email}
- **Phone:** {from sig, or "—"}

## Context
- {1-2 lines: how they appeared, role inference}
{⚠️ Email mismatch note if applicable}

## Notes
> [Your notes: impressions, open items, relationship status]

## Meeting History
- [[YYYY-MM-DD]] — {meeting title} ({organizer or attendee})

## Related
- [[{Company}]]
- [[Vendors]]
- {[[other contacts from same company]]}

---
**Last updated:** YYYY-MM-DD
```

### 5c. Vendors Hub — `Topics/Vendors.md`

Create if missing. If exists, append new company section only — never modify existing `> blockquotes`.

```markdown
---
created: YYYY-MM-DD
tags: [topic, work]
status: developing
---

# Vendors

## Core Idea
External companies and contacts [[GTI]] works with. Each company has its own topic note.

## Companies

### [[{Company}]]
> [Your notes: relationship status, what's working, open questions]
- **Contacts:** [[First Last]], [[Second Person]]
- **Relationship:** {1-line context}
- **First contact:** [[YYYY-MM-DD]]

## Related
- [[GTI]]
- [[GTI-Orgchart]]

---
**Last updated:** YYYY-MM-DD
```

---

## Phase 6 — Mark Daily Notes as Processed

For **every** date in `to_process` (including `needs_frontmatter_only`):

Add `contacts_extracted: YYYY-MM-DD` to the daily note's YAML frontmatter.

**Before:**
```yaml
---
date: 2026-01-12
tags: [daily]
---
```

**After:**
```yaml
---
date: 2026-01-12
tags: [daily]
contacts_extracted: 2026-03-18
---
```

This is the **idempotency marker** — next run of `/contacts` will skip this date entirely.

**If a date gains a new external contact in the future** (e.g. someone added to a past meeting), the user must manually remove `contacts_extracted` from that date's frontmatter to force re-processing.

---

## Phase 7 — Verify Backlinks

```bash
# Contact appears in daily notes
grep -rl "{Name}" vault/Daily\ Notes/ | wc -l

# Contact note links back to dates
grep "\[\[YYYY-" vault/Topics/{Name}.md

# Vendors hub links to all companies
grep "\[\[" vault/Topics/Vendors.md
```

**Summary report:**
> "Done. Created/updated: N contact notes, M company notes, Vendors hub.
> Marked X dates as processed. Y backlinks confirmed.
> Skipped Z previously-processed dates."

---

## Key Rules

- **Vault-first** — scan files before opening any browser
- **Browser only when needed** — don't open Outlook for already-enriched contacts
- **Signal is on the person, not the meeting** — `[[Name]] (external)` in the daily note is the source of truth; meeting titles with `[EXTERNAL]` are incidental (they appear only when the *organizer* is external; internal meetings can have external attendees too)
- **`[EXTERNAL]` in meeting title ≠ the only place externals appear** — never use it as a filter in Outlook; use the work list from Phase 1
- **FLAT Topics/** — no subfolders, ever
- **[[wiki links]] for everything** — names, companies, dates, projects
- **Never overwrite `> blockquotes`** — user-editable, always preserve
- **`contacts_extracted` is sacred** — once set, only the user removes it to force a re-run
- **Idempotent** — `/contacts` can run daily safely; re-enriching same person updates gracefully
- **ULTRA SHORT notes** — fragments OK, no paragraphs

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Chrome not connected | Stop — tell user to connect, skip Phase 2+ |
| Not logged into Outlook | Stop — tell user to log in |
| No `(external)` found in range | Report "Nothing to process in last 90 days" |
| Contact card has no email | Mark `email_unknown`, continue |
| No Outlook Mail results | Mark `No email history`, continue |
| Company website blocked | WebSearch fallback |
| Duplicate contact note | Update existing, never duplicate |
| Daily note has no frontmatter | Create frontmatter block from scratch |

---

## Integration

- **Feeds from** `/daily` — external attendees written as `[[Name]] (external)` in schedule table
- **Reads** `Topics/GTI-Orgchart*.md` — cross-reference to confirm external status
- **Writes** `Topics/Vendors.md`, `Topics/{Company}.md`, `Topics/{Name}.md`
- **Marks** `Daily Notes/YYYY-MM-DD.md` frontmatter with `contacts_extracted`

---

## Outlook URLs

| Purpose | URL |
|---------|-----|
| Calendar day view | `outlook.office.com/calendar/view/day/YYYY/M/DD` |
| Mail search | `outlook.office.com/mail/` → `from:{email}` |
| Org Explorer | `outlook.office.com/host/1f8c20f5-d70f-4f8e-93e1-31d8fce0c8c9/096f3341-6ebc-45ac-b97f-e28aecd40b66/a953b2ce-b28f-48a5-a752-041089f4e197` |

---

## Learned Patterns

- **Calendar → email:** double-click event → Tracking panel → click name → email visible immediately in contact card
- **Signature location:** bottom of email body after `Best,` or `—` separator
- **Calendar invites have no signature** — detect by subject prefix or Zoom/Teams-only body
- **palantir.com pattern:** `{first_initial}{last}@palantir.com`
- **8090.inc / 8090.ai** — same company, different domains; Zoom subdomain `8090-ai.zoom.us` is the tell
- **Org Explorer search** — type name in search bar, dropdown shows `@gtigrows.com` = internal; nothing = external
- **Multiple contacts, same meeting** — open meeting once, click all names before navigating away
