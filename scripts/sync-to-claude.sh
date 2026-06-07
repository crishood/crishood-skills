#!/usr/bin/env bash
# Syncs skills from this repo to ~/.claude/skills/
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"

mkdir -p "$CLAUDE_SKILLS"

echo "Syncing skills from repo → ~/.claude/skills/"

shopt -s nullglob
skills=("$REPO_DIR/skills"/*/)
if [ ${#skills[@]} -eq 0 ]; then
  echo "  (no skills yet)"
else
  for skill_dir in "${skills[@]}"; do
    skill_name="$(basename "$skill_dir")"
    target="$CLAUDE_SKILLS/$skill_name"
    mkdir -p "$target"
    cp -r "$skill_dir"* "$target/" 2>/dev/null || true
    echo "  ✓ $skill_name"
  done
fi

echo "Done."
