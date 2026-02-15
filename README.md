**📊 [Take the quick poll](https://github.com/ballred/obsidian-claude-pkm/discussions/4)** - Help shape what gets built next!

---

# Obsidian + Claude Code PKM Starter Kit 🚀

A complete personal knowledge management system that combines Obsidian's powerful note-taking with Claude Code's AI assistance. Go from zero to a fully functional PKM in 15 minutes or less.

**v3.0** - The Cascade: end-to-end goals-to-tasks flow with `/project` and `/monthly` skills, agent memory, and agent teams.

## ✨ Features

### Core PKM
- **🎯 Goal-Aligned System** - Cascading goals from 3-year vision to daily tasks
- **📅 Daily Notes System** - Structured daily planning and reflection
- **📱 Mobile Ready** - GitHub integration for notes on any device
- **🔄 Version Controlled** - Never lose a thought with automatic Git backups
- **🎨 Fully Customizable** - Adapt templates and structure to your needs

### AI-Powered (v3.0)
- **🔗 The Cascade** - End-to-end flow: 3-year vision → yearly goals → projects → monthly → weekly → daily tasks
- **📁 Project Management** - `/project` skill to create, track, and archive projects linked to goals
- **📆 Monthly Reviews** - `/monthly` skill rolls up weekly reviews, checks quarterly milestones
- **🧠 Agent Memory** - Agents learn your vault patterns across sessions (goal-aligner remembers misalignment patterns, weekly-reviewer learns your reflection style)
- **👥 Agent Teams** - Parallel weekly reviews with collector, goal-analyzer, and project-scanner agents
- **⚡ Unified Skills** - Skills and slash commands merged (`/daily`, `/weekly`, `/monthly`, `/project`, `/push`, `/onboard`)
- **🪝 Hooks** - Auto-commit on save, session initialization with priority surfacing
- **🤖 Custom Agents** - Note organizer, weekly reviewer, goal aligner, inbox processor
- **📏 Modular Rules** - Path-specific conventions for markdown, productivity, projects
- **🎭 Output Styles** - Productivity Coach for accountability
- **📊 Status Line** - Vault stats in terminal (note count, inbox, uncommitted changes)
- **👁️ Progress Visibility** - See spinner updates during multi-step operations like morning routines

## 🚀 Quick Start

### Prerequisites
- [Obsidian](https://obsidian.md/) installed
- [Claude Code CLI](https://code.claude.com/docs) installed
- Git installed
- GitHub account (optional, for mobile sync)

### 15-Minute Quickstart
```bash
# 1) Install prerequisites (once)
# - Obsidian: https://obsidian.md/
# - Git: https://git-scm.com/
# - Claude Code CLI: https://code.claude.com/docs

# 2) Clone this repository
git clone https://github.com/ballred/obsidian-claude-pkm.git
cd obsidian-claude-pkm

# 3) Run setup (macOS/Linux)
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3b) Windows
scripts\setup.bat
```

### Manual Copy (alternative)
```bash
# Copy the vault template to your preferred location
cp -r vault-template ~/Documents/ObsidianPKM
```

### Open in Obsidian
1. Launch Obsidian
2. Click "Open folder as vault"
3. Select your vault folder (e.g., ~/Documents/ObsidianPKM)
4. Start with today's daily note!

## 📖 Documentation

- **[Setup Guide](docs/SETUP_GUIDE.md)** - Detailed installation instructions
- **[Customization](docs/CUSTOMIZATION.md)** - Make it yours
- **[Workflow Examples](docs/WORKFLOW_EXAMPLES.md)** - Daily routines and best practices
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## 🗂️ Structure

```
Your Vault/
├── CLAUDE.md                    # AI context and navigation
├── CLAUDE.local.md.template     # Template for personal overrides
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── .claude/
│   ├── agents/                  # Custom AI agents
│   │   ├── note-organizer.md
│   │   ├── weekly-reviewer.md
│   │   ├── goal-aligner.md
│   │   └── inbox-processor.md
│   ├── skills/                  # Unified skills (invoke with /skill-name)
│   │   ├── daily/               # /daily - Create daily notes, routines
│   │   ├── weekly/              # /weekly - Weekly review process
│   │   ├── monthly/             # /monthly - Monthly review and planning (NEW)
│   │   ├── project/             # /project - Create and track projects (NEW)
│   │   ├── push/                # /push - Git commit and push
│   │   ├── onboard/             # /onboard - Load vault context
│   │   ├── goal-tracking/       # Auto: Track goal progress
│   │   └── obsidian-vault-ops/  # Auto: Vault file operations
│   ├── hooks/                   # Event automation (NEW)
│   │   ├── session-init.sh
│   │   └── auto-commit.sh
│   ├── rules/                   # Path-specific conventions (NEW)
│   │   ├── markdown-standards.md
│   │   ├── productivity-workflow.md
│   │   └── project-management.md
│   ├── scripts/
│   │   └── statusline.sh        # Terminal status display (NEW)
│   ├── output-styles/
│   │   └── coach.md             # Productivity Coach
│   └── settings.json            # Permissions and config (NEW)
├── Daily Notes/
├── Goals/
├── Projects/
├── Templates/
└── Archives/
```

## 🧠 Output Styles

This starter kit includes a **Productivity Coach** output style that transforms Claude into an accountability partner. The coach will:

- Challenge you to clarify your true intentions
- Point out misalignments between stated goals and actions
- Ask powerful questions to drive momentum
- Hold you accountable to your commitments
- Help you identify and overcome resistance

To use the coach style in Claude Code:
1. The output style is automatically included in `.claude/output-styles/`
2. Start Claude Code and type `/output-style` to select from available styles
3. Or directly activate with: `/output-style coach`
4. The style preference is automatically saved for your project

Learn more about [customizing output styles](docs/CUSTOMIZATION.md#output-styles).

## 🔗 The Cascade

The complete goals-to-tasks flow — the #1 requested feature:

```
3-Year Vision ──→ Yearly Goals ──→ Projects ──→ Monthly Goals ──→ Weekly Review ──→ Daily Tasks
                                      ↑
                              /project new
                         (the bridge layer)
```

Every layer connects:
- **`/project new`** creates a project linked to a yearly goal
- **`/daily`** morning routine surfaces your ONE Big Thing + project next-actions
- **`/weekly`** review includes a project progress table
- **`/monthly`** review rolls up weekly reviews and checks quarterly milestones
- **`/goal-tracking`** includes project completion % in goal progress calculations

## 🤖 Custom Agents (v3.0)

Ask Claude to use specialized agents for common PKM tasks:

```bash
# Organize your vault and fix broken links
claude "Use the note-organizer agent to audit my vault"

# Facilitate weekly review aligned with goals
claude "Use the weekly-reviewer agent for my weekly review"

# Check if daily work aligns with long-term goals
claude "Use the goal-aligner agent to analyze my recent activity"

# Process inbox items using GTD principles
claude "Use the inbox-processor agent to clear my inbox"
```

## 🔄 Upgrading

### From v2.1 to v3.0

```bash
# 1. Copy new skill directories
cp -r vault-template/.claude/skills/project your-vault/.claude/skills/
cp -r vault-template/.claude/skills/monthly your-vault/.claude/skills/

# 2. Update existing files (review diff first)
cp vault-template/.claude/settings.json your-vault/.claude/
cp vault-template/.claude/hooks/session-init.sh your-vault/.claude/hooks/

# 3. Update agents (adds memory: project)
cp vault-template/.claude/agents/*.md your-vault/.claude/agents/

# 4. Update existing skills (adds cascade features)
cp -r vault-template/.claude/skills/daily your-vault/.claude/skills/
cp -r vault-template/.claude/skills/weekly your-vault/.claude/skills/
cp -r vault-template/.claude/skills/goal-tracking your-vault/.claude/skills/
cp -r vault-template/.claude/skills/onboard your-vault/.claude/skills/

# 5. Review and merge CLAUDE.md changes
# Add /project and /monthly to your skills table, bump version

# 6. Make scripts executable
chmod +x your-vault/.claude/hooks/*.sh
```

### From v1.x to v3.0

```bash
# 1. Copy all new directories to your vault
cp -r vault-template/.claude-plugin your-vault/
cp -r vault-template/.claude/agents your-vault/.claude/
cp -r vault-template/.claude/skills your-vault/.claude/
cp -r vault-template/.claude/hooks your-vault/.claude/
cp -r vault-template/.claude/rules your-vault/.claude/
cp -r vault-template/.claude/scripts your-vault/.claude/
cp vault-template/.claude/settings.json your-vault/.claude/
cp vault-template/CLAUDE.local.md.template your-vault/

# 2. Review and merge CLAUDE.md changes
# Your customizations are preserved, just add references to new features

# 3. Make hook scripts executable
chmod +x your-vault/.claude/hooks/*.sh
chmod +x your-vault/.claude/scripts/*.sh
```

## 🤝 Contributing

Found a bug or have a feature idea? Please open an issue or submit a PR!

## 📄 License

MIT - Use this freely for your personal knowledge management journey.

---

**Ready to transform your note-taking?** Follow the [Setup Guide](docs/SETUP_GUIDE.md) to get started!