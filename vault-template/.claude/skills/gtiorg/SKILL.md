---
name: gtiorg
description: Crawl GTI org chart from Teams Org Explorer via Chrome, produce department-level vault pages, detect gaps against daily notes, fuzzy-match names. Supports full crawl, targeted person re-crawl, and idempotent skipping.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, TaskCreate, TaskUpdate, TaskList, TaskGet, mcp__Claude_in_Chrome__navigate, mcp__Claude_in_Chrome__tabs_context_mcp, mcp__Claude_in_Chrome__tabs_create_mcp, mcp__Claude_in_Chrome__computer, mcp__Claude_in_Chrome__get_page_text, mcp__Claude_in_Chrome__read_page, mcp__Claude_in_Chrome__find, mcp__Claude_in_Chrome__form_input, mcp__Claude_in_Chrome__javascript_tool
user-invocable: true
---

# GTI Org Chart Crawl Skill

Crawls the [[GTI]] organizational hierarchy from Microsoft Teams Org Explorer. Produces a multi-page hub in `Topics/` with one page per department, sub-pages for large teams, and individual people notes. After crawling, cross-references daily notes to detect missing people.

**Output:**
- `Topics/GTI-Orgchart.md` — top-level hub with full org tree, department table, crawl stats
- `Topics/GTI-Orgchart-{Department}.md` — one per major department
- `Topics/GTI-Orgchart-{SubDept}.md` — sub-pages when a VP/Director subtree has headcount > 5
- `Topics/{First Last}.md` — people notes for key individuals encountered
- Gap detection report against daily notes

## Usage

```
/gtiorg                           # Full crawl (skips departments crawled < 7 days ago)
/gtiorg --force                   # Full crawl, ignore recency — re-crawl everything
/gtiorg --person "Rich Freeman"   # Targeted re-crawl of one person's subtree only
/gtiorg --gaps-only               # Skip crawl, run gap detection (Phase 5) only
```

---

## Org Explorer URL

```
https://outlook.office.com/host/1f8c20f5-d70f-4f8e-93e1-31d8fce0c8c9/096f3341-6ebc-45ac-b97f-e28aecd40b66/a953b2ce-b28f-48a5-a752-041089f4e197
```

**Navigation pattern:**
1. Navigate to Org Explorer URL
2. Search for a person by name in the search bar
3. Click their name in results → lands on their profile
4. Click **Organization** tab → shows manager (above) and direct reports (below)
5. Each direct report card shows: name, title, department
6. Click a direct report → navigate to their Organization tab → see *their* reports
7. Repeat recursively

---

## Phase 0 — Setup & Idempotency Check

### 0a. Parse arguments

| Argument | Effect |
|----------|--------|
| (none) | Full crawl with idempotent skip |
| `--force` | Full crawl, ignore `last_crawled` dates |
| `--person "Name"` | Targeted crawl of one person's subtree |
| `--gaps-only` | Skip Phases 1-4, jump to Phase 5 |

### 0b. Read existing crawl state

Read `Topics/GTI-Orgchart.md` frontmatter for:

```yaml
last_crawled: 2026-03-17
crawl_depth: 6
departments_crawled:
  Legal: 2026-03-17
  Commercial: 2026-03-17
  People: 2026-03-17
  Finance: 2026-03-17
  Technology: 2026-03-17
  Operations: 2026-03-17
  Admin: 2026-03-17
  Strategy: 2026-03-17
```

### 0c. Determine work list

**Full crawl (no `--force`):**
- For each department in `departments_crawled`:
  - If `today - crawled_date < 7 days` → **skip** (fresh enough)
  - Otherwise → **queue for re-crawl**
- If no departments are stale → report "All departments crawled within 7 days. Use --force to re-crawl." and jump to Phase 5.

**Full crawl (`--force`):** Queue all departments.

**Targeted (`--person`):** Queue only that person's subtree. Determine their department from existing orgchart pages.

### 0d. Verify browser

1. `mcp__Claude_in_Chrome__tabs_context_mcp` — verify Chrome connected
   - Not connected → stop: "Connect claude-in-chrome and log into Outlook first."
2. Navigate to Org Explorer URL
3. Verify page loads (look for search bar or org chart elements)
   - Not logged in → stop: "Log into your Microsoft account in Chrome first."

---

## Phase 1 — Crawl CEO & Top-Level Tree

**Skip if `--person` mode — jump to Phase 2b.**

1. Search for "Benjamin Kovler" (CEO) in Org Explorer
2. Click **Organization** tab
3. Record all direct reports: name, title
4. For each direct report who heads a department (has a dedicated orgchart page or title indicates C-suite/SVP/President):
   - Record as department head
   - Add to department crawl queue

**Top-level tree structure (expected):**
```
Benjamin Kovler — CEO & Chairman
├── Andy Grossman — EVP, Capital Markets
├── Anthony Georgiadis — President
│   ├── Bret Kravitz — General Counsel → Legal
│   ├── Dominic OBrien — CCO → Commercial
│   ├── Kelly Dean — SVP, People → People
│   ├── Lauren Meier — Chief of Staff
│   ├── Matt Faulkner — CFO → Finance
│   │   └── Josh Barrington — SVP, Technology → Technology
│   ├── Matt Navarro — President of Operations → Operations
│   └── Rachel Albert — CAO → Admin
├── Armon Vakili — VP, Strategy → Strategy
├── Brendan Blume — Contractor
└── Jeff Goldman — Board Member
```

If the live tree differs from the stored tree, **update** — the live data is authoritative.

---

## Phase 2 — Crawl Each Department

For each department in the work queue:

### 2a. Navigate to department head

1. Search department head name in Org Explorer
2. Click **Organization** tab
3. Record all direct reports with name + title

### 2b. CRITICAL — Recursive traversal (the VP bug fix)

**The old crawl stopped at VP level. This MUST NOT happen.**

**Traversal rule:** For EVERY person encountered who meets ANY of these criteria, click into their Organization tab and crawl their direct reports:

- Title contains: **VP**, **SVP**, **EVP**, **Director**, **Senior Director**, **Head**, **General Manager**, **President**, **Chief**
- Has a "View organization" indicator or direct report count > 0 in Org Explorer
- Is listed as having reports in the org card

**Depth limit:** 8 levels from CEO (configurable). This ensures we reach individual contributors under Directors.

**Traversal algorithm:**
```
function crawl(person, depth):
    if depth > MAX_DEPTH: return
    navigate to person's Organization tab
    record person's direct reports (name, title)
    for each report:
        if should_traverse(report.title) OR report.has_direct_reports:
            crawl(report, depth + 1)
        else:
            record as leaf node
```

**`should_traverse` title patterns** (case-insensitive):
- VP, Vice President
- SVP, Senior Vice President
- EVP, Executive Vice President
- Director, Senior Director, Managing Director
- Head (as title component, e.g. "Head Grower", "Regional Head Grower")
- General Manager, GM
- President (as title component)
- Chief (as title component)
- Senior Manager, Manager (if Org Explorer shows they have reports)

**Example of the fix:** When crawling Commercial, upon reaching `[[Rich Freeman]] — VP, Merchandising and Supply Chain`, the crawler MUST:
1. Click Rich Freeman's name
2. Click Organization tab
3. Record his direct reports (e.g., Aldun Andre — Director, Commercial Strategy & Genetics)
4. For each Director-level report, recurse again
5. Continue until leaf nodes (individual contributors)

### 2c. Sub-page splitting

After crawling a department, check each VP/Director subtree:
- If a person's subtree has **headcount > 5** AND the department page would exceed ~80 people → create a sub-page `Topics/GTI-Orgchart-{SubDept}.md`
- Link from department page: `→ [[GTI-Orgchart-{SubDept}]]`
- Sub-page follows the same format as department pages

**Sub-page naming:** Use the VP/Director's functional area, not their name. Examples:
- Rich Freeman → `GTI-Orgchart-Merchandising`
- Brett Eschbach → `GTI-Orgchart-IT-Infrastructure`
- Jessica Siwy → `GTI-Orgchart-Omni-Channel`

### 2d. Record crawl data

For each department, record:
- All people: `{ name, title, manager, depth }`
- Headcount (crawled)
- Max depth
- Timestamp

---

## Phase 3 — Write Vault Pages

Write in order: department pages → sub-pages → hub → people notes.

### 3a. Department Page — `Topics/GTI-Orgchart-{Department}.md`

Check existence first. If exists, **replace** the `## Org Tree` and `## Stats` sections but preserve any `> blockquotes` or user-added sections.

```markdown
---
created: YYYY-MM-DD
tags: [topic, work]
status: developing
---

# GTI-Orgchart-{Department}

## Department Head
- [[Dept Head Name]] — Title

## Org Tree
- [[Dept Head Name]] — Title
  - [[Direct Report 1]] — Title
    - [[Sub Report 1]] — Title
    - [[Sub Report 2]] — Title → [[GTI-Orgchart-SubDept]]
  - [[Direct Report 2]] — Title
  - ...

## Stats
- **Headcount:** {crawled_count} (crawled)
- **Depth:** {max_depth} levels

## Related
- [[GTI-Orgchart]] — Main org chart
- [[GTI]]

---
**Last updated:** YYYY-MM-DD
```

**Org tree indentation:** 2 spaces per level. Use `- [[Name]] — Title` format. Wiki-link every person EXCEPT contractors without last names (e.g., `SK Rana — Contractor`).

### 3b. Sub-Page — `Topics/GTI-Orgchart-{SubDept}.md`

Same format as department page. Add cross-link to parent department page in Related section:
```markdown
## Related
- [[GTI-Orgchart-{ParentDept}]] — Parent department
- [[GTI-Orgchart]] — Main org chart
- [[GTI]]
```

### 3c. Hub Page — `Topics/GTI-Orgchart.md`

Update the existing hub. Replace `## Org Tree`, `## Department Pages`, and `## Stats` sections. Preserve any user-added sections or `> blockquotes`.

**Frontmatter** — add/update crawl state:
```yaml
---
created: 2026-03-17
tags: [topic, work]
status: developing
last_crawled: YYYY-MM-DD
crawl_depth: 8
departments_crawled:
  Legal: YYYY-MM-DD
  Commercial: YYYY-MM-DD
  ...
---
```

**Org Tree section:** Show full tree from CEO, indented. Department heads link to their department page with `→ [[GTI-Orgchart-{Dept}]]`. Only show down to the direct-report level under each department head in the hub (detail lives in department pages).

**Department Pages table:**
```markdown
## Department Pages
| Department | Head | Page | Crawled |
|------------|------|------|---------|
| Legal | [[Bret Kravitz]] | [[GTI-Orgchart-Legal]] | 9 |
| Commercial | [[Dominic OBrien]] | [[GTI-Orgchart-Commercial]] | 25 |
...
```

Update the `Crawled` column with actual headcounts from this crawl.

**Stats section:**
```markdown
## Stats
- **Total employees crawled:** {total}
- **Department pages:** {count}
- **Sub-pages:** {count}
- **Depth:** {max_depth} levels
- **Last crawled:** YYYY-MM-DD
```

### 3d. People Notes — `Topics/{First Last}.md`

Create a people note for anyone who is a **Director or above** (VP, SVP, EVP, Director, Senior Director, C-suite, President, General Counsel) and does NOT already have a `Topics/{First Last}.md` file.

**Do not overwrite existing people notes.** If the file exists, only update title/role if it has changed.

```markdown
---
created: YYYY-MM-DD
tags: [topic, work, contact]
status: developing
company: "[[GTI]]"
---

# {First Last}

## Core Idea
{Title} at [[GTI]]. Reports to [[Manager Name]].

## Role
- **Title:** {title}
- **Department:** [[GTI-Orgchart-{Dept}]]
- **Reports to:** [[Manager Name]]
- **Direct reports:** {count}

## Notes
> [Your notes]

## Related
- [[GTI-Orgchart-{Dept}]]
- [[GTI-Orgchart]]
- [[GTI]]

---
**Last updated:** YYYY-MM-DD
```

---

## Phase 4 — Targeted Re-Crawl (`--person` mode)

When invoked as `/gtiorg --person "Rich Freeman"`:

1. **Locate the person** in existing orgchart pages
   - Grep all `Topics/GTI-Orgchart*.md` for the name
   - Determine which department page they're on
   - Record their current entry (title, manager, depth)

2. **Crawl their subtree only**
   - Search name in Org Explorer
   - Click Organization tab
   - Recursively crawl all direct reports (same traversal rules as Phase 2b)

3. **Update the department page**
   - Replace only the subtree under that person in the `## Org Tree`
   - Update headcount in `## Stats`
   - If subtree headcount > 5 and no sub-page exists → create one

4. **Update the hub page**
   - Update `Crawled` count for the affected department
   - Update `departments_crawled.{dept}` date in frontmatter

5. **Create people notes** for any new Director+ found

6. **Report:**
   > "Re-crawled {Name}'s subtree: {N} people found ({M} new). Updated [[GTI-Orgchart-{Dept}]]."

---

## Phase 5 — Gap Detection (Meeting Cross-Reference)

Run after every crawl, or standalone with `--gaps-only`.

### 5a. Build the org chart name set

```
Glob Topics/GTI-Orgchart*.md
Read each → extract all [[Name]] wiki-links from Org Tree sections
→ Set<string> orgchart_names
```

Also check root-level people notes that reference GTI:
```
Grep Topics/*.md for company: "[[GTI]]"
→ add those names to known_gti_people set
```

### 5b. Scan daily notes for GTI-related names

```
Grep "Daily Notes/*.md" for [[Name]] patterns
→ Set<string> daily_note_names
```

Filter to likely GTI people:
- Name appears in a meeting with known GTI people
- Name appears near GTI-related context (meeting titles with "GTI", internal meeting markers)
- Name is wiki-linked (not plain text)

### 5c. Find gaps

```
missing = daily_note_names - orgchart_names - known_gti_people
```

### 5d. Check legacy people notes

Some people have root-level vault notes that predate the orgchart skill (e.g., `Topics/Brad Asher.md`, `Topics/Rich Freeman.md`). Cross-reference:
- If a person is in `orgchart_names` but also has a standalone note → no action needed (the orgchart page and people note coexist)
- If a person has a standalone note but is NOT in `orgchart_names` → flag: "May be a GTI employee not yet in org chart"

### 5e. Fuzzy name matching

For each name in `missing`, run a fuzzy check against `orgchart_names`:

**Fuzzy rules:**
1. **First-name match:** "Alden" ↔ "Aldun" (Levenshtein distance ≤ 2 on first name)
2. **Last-name match:** exact last name + different first name → likely the same person or a relative
3. **Nickname/abbreviation:** "Dan" ↔ "Daniel", "Mike" ↔ "Michael", "Chris" ↔ "Christopher", "Matt" ↔ "Matthew", "Josh" ↔ "Joshua", "Rick" ↔ "Richard", "Joe" ↔ "Joseph", "Ben" ↔ "Benjamin", "Jen" ↔ "Jennifer", "Becca" ↔ "Rebecca", "Kate" ↔ "Katherine"
4. **Transposition/typo:** Levenshtein distance ≤ 2 on the full name

**Implementation approach:**
- Split each name into first + last
- Compare first names: exact match, nickname table match, or Levenshtein ≤ 2
- Compare last names: exact match or Levenshtein ≤ 1
- If first AND last match by any rule → flag as near-match

### 5f. Report

Present findings to user:

```markdown
## Gap Detection Report

### Missing from Org Chart
People found in daily notes but not in any GTI-Orgchart page:
- **John Smith** — mentioned in [[2026-03-15]], [[2026-03-18]]
- **Sarah Chen** — mentioned in [[2026-03-10]]

### Near Matches (confirm or dismiss)
- **"Alden Andre"** (daily note) → **"Aldun Andre"** (orgchart) — likely same person?
- **"Dan Fleury"** (daily note) → **"Daniel Fleury"** (orgchart) — nickname match

### Legacy Notes Without Org Chart Entry
- [[Brad Asher]] — has Topics/ note, not in any GTI-Orgchart page
```

**Ask user:** "Want me to add any of the missing people to the org chart? I can search for them in Org Explorer."

If user confirms names → run targeted crawl (Phase 4) for each.

---

## Chrome Interaction Patterns

### Searching for a person
1. Click the search bar in Org Explorer (usually top of page)
2. Type person's full name
3. Wait for dropdown results (~1-2 seconds)
4. Click the correct result (match on name + title if ambiguous)
5. Wait for profile to load

### Reading the Organization tab
1. Click "Organization" tab (may already be active)
2. **Manager** section: person above in the hierarchy
3. **Direct reports** section: cards below, each showing name + title
4. If "Show more" or pagination exists → click to load all reports
5. Read each card: extract name and title text

### Handling load states
- If page shows spinner → wait 2 seconds, re-read
- If "Show more" button visible → click it, wait for load
- If no Organization tab visible → person may be a contractor (no org data)
- If search returns no results → try last name only, then first name only

### Avoiding duplicates
- Track all visited person URLs/names in a set
- Before navigating to a person, check if already visited
- Skip if visited → prevents infinite loops from circular reporting

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Chrome not connected | Stop — tell user to connect |
| Not logged into Outlook | Stop — tell user to log in |
| Person not found in search | Log warning, continue with next person |
| Organization tab missing | Log as contractor/external, skip subtree |
| Page won't load after 3 attempts | Skip person, log error, continue |
| Circular reference detected | Skip (already visited), log warning |
| Name ambiguity in search | Pick result matching expected title, log if uncertain |
| Department page doesn't exist | Create it fresh |
| Hub page doesn't exist | Create it fresh from scratch |

---

## Key Rules

- **FLAT Topics/** — no subfolders, ever
- **[[wiki links]] for every person** — `[[First Last]]` format
- **Contractors without clear names** — plain text, no wiki link (e.g., `SK Rana — Contractor`)
- **Never overwrite `> blockquotes`** — user-editable content, always preserve
- **Idempotent** — safe to run daily; skips fresh departments, only updates stale ones
- **Depth over breadth** — always traverse VP/Director subtrees fully before moving to next sibling
- **ULTRA SHORT notes** — bullets, fragments, no paragraphs
- **Live data wins** — if Org Explorer differs from stored tree, update to match live
- **2-space indent** for org tree nesting

---

## Integration

- **Feeds into** `/contacts` — org chart cross-reference confirms internal vs external
- **Reads** `Daily Notes/*.md` — gap detection scans for [[Name]] patterns
- **Reads** `Topics/*.md` — checks for legacy people notes
- **Writes** `Topics/GTI-Orgchart*.md`, `Topics/{First Last}.md`

---

## Outlook URLs

| Purpose | URL |
|---------|-----|
| Org Explorer | `https://outlook.office.com/host/1f8c20f5-d70f-4f8e-93e1-31d8fce0c8c9/096f3341-6ebc-45ac-b97f-e28aecd40b66/a953b2ce-b28f-48a5-a752-041089f4e197` |
| Calendar day view | `outlook.office.com/calendar/view/day/YYYY/M/DD` |

---

## Learned Patterns

- **Org Explorer search** — type name, dropdown shows results with title; `@gtigrows.com` = internal
- **Organization tab** — always click it explicitly; sometimes defaults to "About" tab
- **Direct report cards** — show name + title; click name to navigate to their profile
- **"Show more" pagination** — some managers with 10+ reports have paginated cards; always expand
- **Contractors** — often have no Organization tab or show empty direct reports
- **Title normalization** — Org Explorer may show "Vice President" vs "VP"; normalize to short form in vault
- **Department inference** — the subtitle under a person's name often shows their department or business unit
- **Circular orgs** — rare but possible with dotted-line reporting; track visited set to avoid loops
