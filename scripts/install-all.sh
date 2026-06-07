#!/usr/bin/env bash
# Installs all skills from this repo into ~/.claude/skills/
# Use this when setting up a new machine
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/sync-to-claude.sh"

echo ""
echo "All skills installed. Restart Claude Code to pick them up."
