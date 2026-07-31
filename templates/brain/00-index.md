# Brain

Knowledge base shared between me and Claude Code. Auto-synced to GitHub after every Claude session.

## Structure
- `repos/` — one note per repository: architecture, gotchas, conventions, how to run it. Claude reads the matching note before working on a repo and writes findings back.
- `areas/` — ongoing concerns that span repos (infra, on-call, team processes).
- `resources/` — external references: links, vendor docs, runbooks.

## Conventions
- One note per repo, named exactly after the repo: `repos/<repo-name>.md`
- Link between notes with `[[wikilinks]]`
- Claude writes here directly — review its updates like you'd review a teammate's notes
