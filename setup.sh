#!/usr/bin/env bash
# Claude Code setup kit installer — see README.md for the full guide.
set -euo pipefail

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

echo "==> Claude Code setup kit"

# 1. Global CLAUDE.md
mkdir -p ~/.claude
if [ -f ~/.claude/CLAUDE.md ]; then
  cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak-"$TS"
  echo " - Existing ~/.claude/CLAUDE.md backed up to CLAUDE.md.bak-$TS"
fi
cp "$KIT_DIR/templates/CLAUDE.md" ~/.claude/CLAUDE.md
echo " - Installed ~/.claude/CLAUDE.md (edit the <placeholders>!)"

# 2. Personal skills
mkdir -p ~/.claude/skills
cp -r "$KIT_DIR/templates/skills/git-commit" ~/.claude/skills/
echo " - Installed git-commit skill"

# 3. brain-sync script
mkdir -p ~/.local/bin
cp "$KIT_DIR/templates/brain-sync" ~/.local/bin/brain-sync
chmod +x ~/.local/bin/brain-sync
echo " - Installed ~/.local/bin/brain-sync"

# 4. Brain vault skeleton
if [ -d ~/brain ]; then
  echo " - ~/brain already exists, leaving it alone"
else
  mkdir -p ~/brain/repos ~/brain/areas ~/brain/resources
  cp "$KIT_DIR/templates/brain/00-index.md" ~/brain/00-index.md
  git -C ~/brain init -q
  echo " - Created ~/brain vault skeleton (git initialized, no remote yet)"
fi

# 5. settings.json with the Stop hook
if [ -f ~/.claude/settings.json ]; then
  echo " - ~/.claude/settings.json already exists — NOT overwriting."
  echo "   Merge this into it (adds the brain auto-sync hook):"
  echo
  cat "$KIT_DIR/templates/settings.json"
else
  cp "$KIT_DIR/templates/settings.json" ~/.claude/settings.json
  echo " - Installed ~/.claude/settings.json (brain-sync Stop hook)"
fi

echo
echo "==> Done. Remaining manual steps (see README.md):"
echo "   1. Edit ~/.claude/CLAUDE.md placeholders"
echo "   2. In Claude Code, install the plugins (/plugin install ...)"
echo "   3. Create a PRIVATE GitHub repo and add it as ~/brain's origin"
echo "   4. Open ~/brain as a vault in Obsidian"
