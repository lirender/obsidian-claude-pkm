#!/bin/bash
# Optional hook: auto-log session to Obsidian vault when Claude Code stops
# Add to settings.json under hooks.Stop to enable
# This is a lightweight fallback — /learnings gives richer summaries

VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Obsidian/vault}"
TODAY=$(date +%Y-%m-%d)
DAILY="$VAULT/Daily Notes/$TODAY.md"
PROJECT=$(basename "$PWD")
TIME=$(date +%H:%M)

# Skip if we're already in the vault
if [[ "$PWD" == "$VAULT"* ]]; then
    exit 0
fi

# Create daily note if it doesn't exist
if [ ! -f "$DAILY" ]; then
    cat > "$DAILY" << EOF
---
date: $TODAY
tags: [daily]
---

# $TODAY

## Session Log
EOF
fi

# Append Session Log section if missing
if ! grep -q "## Session Log" "$DAILY" 2>/dev/null; then
    echo -e "\n## Session Log" >> "$DAILY"
fi

echo "- $TIME — Worked on [[$PROJECT]]" >> "$DAILY"
