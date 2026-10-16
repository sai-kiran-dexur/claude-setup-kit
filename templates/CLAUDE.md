# Claude Code — User Instructions

## Brain vault (`~/brain`) — the single memory store
- A SessionStart hook injects this repo's **card** (`~/brain/repos/<repo>.md`: current truth, ≤9,500 chars). Full history is in `~/brain/logs/<repo>.md` — grep it, never read it whole.
- When you learn something durable: **edit the card in place** (delete facts that stopped being true) and append dated evidence to the log. A correction or retraction updates the card in the same turn.
- Facts true for the whole team also belong in the repo's own `CLAUDE.md` (via branch + PR).
- Cross-repo notes live in `~/brain/areas/`. Built-in auto-memory is off — never write to `~/.claude/projects/*/memory/`.
- No PHI or secrets in the vault; brain-sync blocks them. A card over budget or a "TRUNCATED" note → use the `brain-distill` skill.

@~/brain/areas/working-with-claude.md

## Rules
- <machine rules, e.g. "No sudo on this machine; services via Docker, CLIs to ~/.local/bin">
- <data rules, e.g. "Never commit real customer identifiers; use placeholders">
- <one line per repo-specific gotcha that must hold everywhere>

## Profile
<role, company, OS>
