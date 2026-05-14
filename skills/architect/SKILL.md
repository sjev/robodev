---
name: architect
description: Create or update docs/architecture.md from user stories and project context.
---

# Architect

Produce `docs/architecture.md`.

## Process

1. Read `docs/user_stories.md` and any existing `docs/architecture.md`.
2. Produce or update `docs/architecture.md` using the template in `assets/template.md`.

## Rules

- Make reasonable assumptions and flag each with `[ASSUMPTION]`.
- Ask only if a missing answer would materially change the architecture and cannot be inferred.
- Keep the document as short as reasonably possible.
- Mermaid diagrams only.
- Be specific: version numbers, concrete patterns, no "best practices" filler.
- If updating an existing document, preserve decisions that are still valid.
