#!/usr/bin/env bash
# setup.sh — restore (or bootstrap) the Claude Code setup on a machine.
#
#   ./setup.sh                 restore: generic files from this kit + personal layer from $KIT_PRIVATE
#   BRAIN_REMOTE=git@github.com:you/brain.git ./setup.sh   also clone the brain vault if ~/brain is missing
#
# Every file it replaces is backed up as <file>.bak-<timestamp>. Safe to re-run.
set -euo pipefail

KIT=$(cd "$(dirname "$0")" && pwd)
PRIV=${KIT_PRIVATE:-$HOME/brain/system/claude}
TS=$(date +%Y%m%d-%H%M%S)

say()  { printf ' - %s\n' "$*"; }
need() { command -v "$1" >/dev/null || { echo "missing prerequisite: $1" >&2; exit 1; }; }
put()  { # src dst mode — install with backup when content differs
  local src=$1 dst=$2 mode=${3:-0644}
  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst"; then cp -a "$dst" "$dst.bak-$TS"; say "backed up $dst"; fi
  install -m "$mode" "$src" "$dst"
}

echo "==> Claude Code setup (kit: $KIT, personal layer: $PRIV)"
for c in git jq uv flock; do need "$c"; done
[[ ${SETUP_SKIP_CLAUDE:-0} == 1 ]] || need claude

# 1. Brain vault — clone first, because the personal layer may live inside it
if [[ ! -d $HOME/brain ]]; then
  if [[ -n ${BRAIN_REMOTE:-} ]]; then
    git clone -q "$BRAIN_REMOTE" "$HOME/brain" && say "cloned brain from $BRAIN_REMOTE"
  else
    mkdir -p "$HOME/brain"/{repos,logs,areas,templates}
    cp "$KIT/templates/brain/00-index.md" "$HOME/brain/00-index.md"
    git -C "$HOME/brain" init -q -b main
    say "created an empty ~/brain (set BRAIN_REMOTE to clone yours instead)"
  fi
fi
put "$KIT/templates/brain/.gitignore"          "$HOME/brain/.gitignore"
put "$KIT/templates/brain/templates/card.md"   "$HOME/brain/templates/card.md"

# 2. Generic scripts and skills
for f in "$KIT"/home/.local/bin/*; do put "$f" "$HOME/.local/bin/$(basename "$f")" 0755; done
for d in "$KIT"/home/.claude/skills/*/; do
  for f in "$d"*; do put "$f" "$HOME/.claude/skills/$(basename "$d")/$(basename "$f")"; done
done
say "installed brain-* scripts and skills"

# 3. Personal layer (settings, CLAUDE.md) — falls back to the generic templates
if [[ -f $PRIV/settings.json ]]; then
  put "$PRIV/settings.json" "$HOME/.claude/settings.json"; put "$PRIV/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  say "restored settings.json + CLAUDE.md from $PRIV"
else
  if [[ ! -f $HOME/.claude/settings.json ]]; then
    tmpl=$(mktemp); sed "s#__HOME__#$HOME#g" "$KIT/templates/settings.json" > "$tmpl"
    put "$tmpl" "$HOME/.claude/settings.json"; rm -f "$tmpl"
  fi
  [[ -f $HOME/.claude/CLAUDE.md ]]     || put "$KIT/templates/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"
  say "no personal layer at $PRIV — used templates where nothing existed (edit the <placeholders>)"
fi

# 4–5 talk to the claude CLI; SETUP_SKIP_CLAUDE=1 skips them (dry runs into a scratch HOME)
[[ ${SETUP_SKIP_CLAUDE:-0} == 1 ]] && PRIV_SKIP=1 || PRIV_SKIP=0

# 4. Plugins
if (( ! PRIV_SKIP )) && [[ -f $PRIV/plugins.txt ]]; then
  claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1 || true
  while read -r p; do [[ -n $p ]] && { claude plugin install "$p" >/dev/null 2>&1 && say "plugin $p" || say "plugin $p FAILED"; }; done < "$PRIV/plugins.txt"
fi

# 5. MCP servers (user scope). Redacted env values must be filled in by hand afterwards.
if (( ! PRIV_SKIP )) && [[ -f $PRIV/mcp-servers.json ]]; then
  for name in $(jq -r 'keys[]' "$PRIV/mcp-servers.json"); do
    claude mcp get "$name" >/dev/null 2>&1 && continue
    claude mcp add-json --scope user "$name" "$(jq -c --arg n "$name" '.[$n]' "$PRIV/mcp-servers.json")" >/dev/null && say "mcp $name"
  done
  grep -q '<redacted>' "$PRIV/mcp-servers.json" && say "NOTE: some MCP env/header values were redacted — set them with 'claude mcp add-json'"
fi

# 6. Midnight brain-sync backstop
if [[ -f $PRIV/crontab.txt ]] && ! crontab -l 2>/dev/null | grep -qF brain-sync; then
  (crontab -l 2>/dev/null; cat "$PRIV/crontab.txt") | crontab - && say "installed brain-sync cron line"
fi

command -v gitleaks >/dev/null || say "WARNING: install gitleaks to ~/.local/bin — brain-sync uses it to block secrets"
echo "==> Done. Run bin/kit-diff to confirm no drift."
