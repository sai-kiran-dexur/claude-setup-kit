# Claude Code Setup Kit

My Claude Code setup as restorable dotfiles. It is built around one idea: **Claude's long-term memory is an Obsidian vault (`~/brain`) that it reads automatically and writes with discipline.**

This repo is **public and generic**: scripts, skills, templates, the restore script. Anything personal or infrastructure-specific (my `settings.json`, `CLAUDE.md`, MCP server list, plugin list, cron line) lives in a **private layer**, by default `~/brain/system/claude/` inside the private brain repo. Set `KIT_PRIVATE` to put it elsewhere.

## How it works

```
~/brain/
  repos/<repo>.md    CARD — current truth, ≤ 9,500 chars, edited in place
  logs/<repo>.md     LOG  — dated, append-only history and evidence
  areas/             cross-repo notes (incl. working-with-claude.md: standing rules)
  templates/card.md
  system/claude/     private layer of this kit (settings, CLAUDE.md, MCP, plugins, cron)
```

| Piece | What it does |
|---|---|
| `brain-context` (SessionStart hook) | Resolves the repo (worktrees → parent repo, `_`/`-` tolerant), injects its card + a pointer to its log + any sync warning. Stays under the 10k-char hook cap; an over-budget note is shown as a head + `TRUNCATED` warning instead of its stale top. |
| `brain-sync` (Stop: debounced · SessionEnd + midnight cron: `--force`) | Commits at most every 30 min with messages naming the changed notes; **blocks** the commit on gitleaks (secrets) or `brain-phi-scan` (MRN / visit / account / patient-id / DOB / SSN shaped values; `12345678`/`V12345678` allowed); retries push with rebase; writes failures to `~/brain/.sync-health`, which the next session shows. `touch ~/brain/.sync-paused` pauses it. |
| `brain-index` | Regenerates `00-index.md` from the cards' `> summary` and `**Status` lines. |
| `brain-distill` skill | Turns a long log into a card: reads the whole log (in a subagent), carries only the latest truth, records superseded claims in the log. |
| `git-commit` skill | `[Tag] subject` commits, no AI trailers (also enforced by `attribution` in settings). |
| `~/.claude/CLAUDE.md` | Short rules + the card/log protocol, and `@~/brain/areas/working-with-claude.md` so standing preferences load everywhere. Built-in auto-memory is off: the brain is the single store. |

Why cards: Claude's Read tool returns the first 2,000 lines by default and append-only notes keep their newest facts at the bottom, so a long note is either a context bill or a trap that shows retracted claims first. A card keeps current truth small and first; the log keeps the evidence.

## Use

```bash
git clone https://github.com/sai-kiran-dexur/claude-setup-kit.git && cd claude-setup-kit

# restore on a new machine (clones the brain, which carries the private layer)
BRAIN_REMOTE=git@github.com:<you>/<private-brain>.git ./setup.sh

bin/kit-export   # snapshot the live setup: generic files -> this repo, personal -> $KIT_PRIVATE
bin/kit-diff     # show drift between live and kit (exit 1 on drift)
```

`setup.sh` backs up every file it replaces (`*.bak-<timestamp>`), is idempotent, installs plugins and user-scope MCP servers from the private layer (redacted env values must be re-entered), and adds the cron backstop. `SETUP_SKIP_CLAUDE=1` skips the `claude` CLI steps for dry runs. Prerequisites: `git jq uv flock claude`, and `gitleaks` in `~/.local/bin`.

Without a private layer it falls back to `templates/` (`CLAUDE.md` has `<placeholders>`).

## Choices worth knowing

- **Plugins kept lean:** superpowers, code-review, playwright, frontend-design. Unused ones were removed; every plugin's skills and hooks cost context in every session.
- **MCP:** native Claude Code handles multiple servers, OAuth and on-demand tool loading, so there is no extra gateway hop. Prefer purpose-built read-only servers (aggregates, no raw PHI) over generic database MCPs, whose results land in plaintext transcripts.
- **Never in this repo:** hostnames, IPs, credentials, customer data. `kit-export` writes those files to the private layer only.
