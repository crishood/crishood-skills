#!/usr/bin/env bash
# Imports skills from ~/.claude/skills/ into this repo
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"

if [ ! -d "$CLAUDE_SKILLS" ]; then
  echo "No skills directory found at $CLAUDE_SKILLS"
  exit 0
fi

echo "Importing skills from ~/.claude/skills/ → repo"

for skill_dir in "$CLAUDE_SKILLS"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$REPO_DIR/skills/$skill_name"
  mkdir -p "$target"
  cp -r "$skill_dir"* "$target/" 2>/dev/null || true
  echo "  ✓ $skill_name"
done

echo "Done. Review changes with: git status"
