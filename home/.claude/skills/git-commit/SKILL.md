---
name: git-commit
description: Use when creating any git commit — enforces [Tag] subject-line format and forbids Co-Authored-By trailer
---

# Git Commit Style

## Format

```
[Tag] short description of what changed
```

One subject line. No body unless truly necessary. **Never** add `Co-Authored-By` or any AI attribution trailer.

## Tags

Pick the tag that matches what you changed:

| Tag | When |
|-----|------|
| `[Infra]` | Kubernetes manifests, Helm values, cluster config |
| `[Kafka]` | Kafka topics, consumer/producer config |
| `[Postgres]` | Schema, migrations, DB config |
| `[Redis]` | Cache config |
| `[LocalStack]` | LocalStack / AWS mock config |
| `[Test]` | Smoke tests, test fixtures, CI |
| `[Scripts]` | Shell scripts, tooling |
| `[Docs]` | README, documentation only |
| `[Bug]` | Bug fixes that don't fit a component tag |
| `[CLAUDE]` | CLAUDE.md, Claude rules, skills |

For new components, invent a tag that matches the component name — e.g. `[EtlUtils]`, `[DevUtils]`.

## Examples

```
[Test] add smoke tests for all infra services
[Kafka] replace bitnami chart with apache/kafka:4.0.0 standalone manifest
[LocalStack] pin Helm chart to community image (localstack:4)
[Infra] set ndots:1 on smoke-job to prevent search-domain hijack
[Bug] fix kafka-topics path: /opt/kafka/bin/kafka-topics.sh
```

## Rules

- Subject line only — keep it under ~72 chars
- No `Co-Authored-By`, no AI attribution, no trailers
- No bullet-point body unless listing 3+ distinct changes that won't fit on one line
- Tense: imperative ("add", "fix", "remove") or noun phrase ("smoke tests for infra")
