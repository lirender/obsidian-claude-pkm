---
name: learnings
description: Sync session work from any Claude Code project back to the Obsidian vault. Captures accomplishments, blockers, and next steps. Run at end of coding sessions to build knowledge continuity.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(date:*), Bash(pwd:*), Bash(basename:*), TaskCreate, TaskUpdate
user-invocable: true
---

# Learnings Skill

Captures session work from any Claude Code project and syncs it to the Obsidian vault daily note. Builds continuity across sessions and projects.

## Usage

Run from any project directory:
```
/learnings
```

## What It Does

### 1. Identify Context
- Get current working directory to determine project name
- Read recent git log (last session's commits) for what changed
- Read git diff --stat for scope of changes

### 2. Generate Summary
Create a concise summary of the session:
- What was accomplished (2-4 bullets)
- Key decisions or trade-offs made
- Blockers or open questions
- What to pick up next

### 3. Write to Vault Daily Note
Append to the Obsidian vault daily note under `## Session Log`:

```markdown
## Session Log

### [[Project Name]] — HH:MM
- Accomplished: refactored auth module, fixed rate limiting
- Decisions: chose JWT over session tokens for statelessness
- Blockers: waiting on API keys from DevOps
- Next: write integration tests for auth flow
- Related: [[ChatGTI Platform]], [[Authentication]]
```

If the daily note doesn't exist, create it from template first.
If `## Session Log` section doesn't exist, append it.

### 4. Optionally Update Project Topic
If a matching topic exists in the vault (e.g., `Topics/ProjectName.md`), offer to update its status or add recent context.

## Configuration

The vault path defaults to `~/Obsidian/vault`. To customize, set in your environment or CLAUDE.md:

```
OBSIDIAN_VAULT_PATH=~/Obsidian/vault
```

## Rules

### Summary Style
- Concise bullets, not paragraphs
- Technical but readable
- Focus on "what" and "why", not "how"
- Link to vault topics where relevant with [[wiki links]]

### Git Integration
- Read `git log --oneline -20` to understand recent work
- Read `git diff --stat` for scope
- Don't require a clean git state — work in progress is fine

### Linking
- Project name becomes a [[wiki link]]
- Technologies, tools, and concepts get [[wiki links]]
- People mentioned get [[wiki links]]

### Daily Note
- Always append, never overwrite existing content
- Create the daily note from template if it doesn't exist
- Use YYYY-MM-DD date format
- Place under `## Session Log` section

### Privacy
- Don't include sensitive data (API keys, passwords, internal URLs)
- Summarize at the concept level, not code level
- Don't copy code snippets into the vault

## Global Installation

This skill should be available from ANY project, not just the vault:

```bash
# Copy to global skills directory
cp -r .claude/skills/learnings ~/.claude/skills/learnings
```

Or add to your global CLAUDE.md:
```markdown
## Cross-Project Skills
- `/learnings` — sync session work to Obsidian vault
```

## Integration

Works with:
- `/daily` - Session logs appear alongside calendar and tasks
- `/weekly` - Weekly review references session logs for accomplishments
- Goal tracking - Session work can be linked to projects and goals
- Any Claude Code project — this skill is project-agnostic
