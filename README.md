# Claude Code Setup Kit

This replicates a Claude Code setup built around three ideas:

1. **Plugins** — 8 official plugins (superpowers, code-review, context7, etc.) that add skills like brainstorming, TDD, systematic debugging, and live library docs.
2. **A "brain" vault** — an Obsidian vault at `~/brain` that doubles as Claude's long-term knowledge base. Claude reads `~/brain/repos/<name>.md` before working on a repo and writes findings back there. It's a git repo, auto-synced to GitHub.
3. **Hooks + personal skills** — a `Stop` hook auto-commits the brain vault after every Claude session, and a personal `git-commit` skill enforces a commit-message style.

## Quick start

```bash
git clone https://github.com/sai-kiran-dexur/claude-setup-kit.git
cd claude-setup-kit
./setup.sh
```

Then finish the manual steps below.

## What setup.sh does

- Copies a starter `CLAUDE.md` to `~/.claude/CLAUDE.md` (backs up any existing one)
- Installs the `git-commit` skill to `~/.claude/skills/`
- Installs the `brain-sync` script to `~/.local/bin/`
- Creates the `~/brain` vault skeleton (`repos/`, `areas/`, `resources/`, `00-index.md`) and runs `git init`
- Writes `~/.claude/settings.json` with the brain-sync Stop hook (or prints the JSON to merge if you already have settings)

## Manual steps after running setup.sh

### 1. Install the plugins

Open Claude Code and run:

```
/plugin install superpowers@claude-plugins-official
/plugin install code-review@claude-plugins-official
/plugin install github@claude-plugins-official
/plugin install context7@claude-plugins-official
/plugin install skill-creator@claude-plugins-official
/plugin install code-simplifier@claude-plugins-official
/plugin install playwright@claude-plugins-official
/plugin install frontend-design@claude-plugins-official
```

(If the marketplace isn't found, add it first: `/plugin marketplace add anthropics/claude-plugins-official`.)

The heavy hitter is **superpowers** — it makes Claude check for a relevant skill before doing anything: brainstorming before building, systematic-debugging before fixing, TDD before implementing, verification before claiming "done".

### 2. Hook the brain up to GitHub

Create a **private** repo on GitHub (e.g. `my-brain`), then:

```bash
cd ~/brain
git remote add origin git@github.com:<you>/my-brain.git
git add -A && git commit -m "init brain" && git push -u origin main
```

After this, the Stop hook auto-commits and pushes the vault every time a Claude session ends — you never sync it by hand.

### 3. Open ~/brain in Obsidian

Obsidian → "Open folder as vault" → `~/brain`. Now you and Claude share the same notes: Claude writes repo knowledge there, you browse/edit it with graph view, backlinks, search.

### 4. Personalize ~/.claude/CLAUDE.md

The starter file has `<placeholders>` for your own rules — things Claude should always know (your role, hard constraints like "never commit secrets", project-specific conventions). Keep it short; every line is loaded into every session.

## How the brain workflow feels day to day

- First time Claude works on a repo, ask it to write up what it learned to `~/brain/repos/<repo>.md`.
- Every session after that, the CLAUDE.md rule makes it read that file first — so it starts with context instead of re-exploring.
- Corrections and gotchas ("that migration path is deprecated, use X") go into the same file — knowledge compounds instead of dying with the conversation.
