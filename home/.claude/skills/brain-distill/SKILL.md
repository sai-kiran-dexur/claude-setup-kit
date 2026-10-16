---
name: brain-distill
description: Use when a ~/brain repo note is over its 9,500-char card budget, when the SessionStart brain card shows "[TRUNCATED: this note is … KB", when a card has drifted from its log, or when asked to distill, compact or refresh a brain card
---

# brain-distill

Turn a repo's dated history into a short **card** of current truth.

| File | Role | Size |
|---|---|---|
| `~/brain/repos/<name>.md` | **Card** — current truth, injected into every session in that repo by the `brain-context` SessionStart hook | ≤ 9,500 chars |
| `~/brain/logs/<name>.md` | **Log** — dated, append-only history and evidence | unbounded; grep it, never read it whole in the main context |

## 1. Split, if not split yet

If `logs/<name>.md` does not exist and the note is over budget:

```bash
cd ~/brain && touch .sync-paused && git mv repos/<name>.md logs/<name>.md
```

`.sync-paused` stops brain-sync from pushing a half-finished card. Remove it only after the user has reviewed (or when they told you to).

## 2. Read the whole log — in a subagent if it is over ~50 KB

Dispatch a subagent so the main context stays clean. It reads `logs/<name>.md` **start to end** with `Read` offset/limit in 400–600-line chunks. Never stop at the top: the newest entries are at the bottom and override older ones.

While reading, keep a ledger per topic: latest claim · date · heading. A later `CORRECTION`, `RETRACTION`, `FINAL`, `DEPLOYED`, `SUPERSEDED`, a status flip or a pivot **replaces** the earlier claim. The superseded version never goes into the card.

Also read when present:
- `~/dev/<name>/CLAUDE.md` — the card must not duplicate it; the card holds what the repo file doesn't (hosts, deploy state, live decisions, traps learned in ops). Note any place the repo CLAUDE.md is now wrong.
- `~/brain/repos/<name>-START_HERE.md` or a related `*-START_HERE` note — fold it into the card, then `git rm` it.
- The repo's row in `git -C ~/brain show HEAD:00-index.md`.

## 3. Write the card from `~/brain/templates/card.md`

- Line 1 `# <name>`; line 2 `> one-line summary` (the index uses it); then `**Status (as of YYYY-MM-DD):** …`.
- Present tense, current truth only. Narrative, evidence and "I tried X" stay in the log.
- **Invariants & traps** are the most valuable section: rules that prevent outages or wrong answers, one line each, each linking its proof `[[logs/<name>#Heading]]`.
- **Current decisions**: live ones only, dated, linked.
- Verify cheap facts where possible (`git -C ~/dev/<name> log -1 --format='%h %cs' origin/main`, paths exist). Keep the as-of date on anything you could not verify.
- Exact names: repo dirs, hosts, ports, issue/PR numbers. No PHI, no secrets — placeholders `12345678` / `V12345678`.
- Never invent content to fill a section; drop the section instead.

Check: `wc -c ~/brain/repos/<name>.md` ≤ 9500. If over, replace detail with links into the log — never replace facts with vagueness.

## 4. Close the loop in the log

Append (never rewrite history):

```markdown
## YYYY-MM-DD — distilled into card
- Superseded: <old claim> → <current truth> (see [[#Heading]])
- Repo CLAUDE.md is stale on: <item> (if any)
```

## 5. Report

Card size in chars, the 3–5 most important superseded claims you resolved, stale repo-CLAUDE.md items, and anything you were unsure about.
