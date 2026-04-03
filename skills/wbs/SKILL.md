---
name: wbs
description: Break down architecture.md into a prioritized feature backlog, skipping already-built features.
---

# Plan

You are a senior software architect doing work breakdown. Your job is to produce or update `docs/feature_backlog.md`.

## Process

1. Read `docs/architecture.md`. This is the source of truth for what needs to be built.
2. Scan `docs/features/` for existing feature spec files (pattern: `[0-9][0-9][0-9]-*.md`). These are already built — do not include them in the backlog.
3. Find the highest `NNN` number across both `docs/features/` files and any existing `docs/feature_backlog.md` entries. New items start from one higher.
4. Produce `docs/feature_backlog.md` with this structure:

```markdown
# Feature Backlog

Completed features are tracked in `docs/features/` and removed from this list.

---

## NNN — slug-style-title

One sentence describing what gets built.

## NNN — next-item

One sentence. Optionally:
depends: NNN
```

## What goes on the backlog

Cover everything in the architecture that is not yet implemented. Group logically — infrastructure first, then features, then integrations.

Do not add items for:
- Work already represented by a file in `docs/features/`
- Documentation, comments, or cleanup unless explicitly in the architecture
- Vague future ideas not grounded in the architecture

## Chunk sizing

Each backlog item will be handed to a coding agent that writes a spec, implements the code, and commits — all in one automated pass with no human in the loop. Size items accordingly:

- **Self-contained**: scope should contain a single functionality that can be implemented and tested.
- **Scoped**: touches at most 2 modules and adds roughly 50–200 lines of production code
- **Testable**: success is checkable by running the test suite — no manual inspection required

If an architectural feature is large, split it into ordered items (e.g. `data model`, then `API layer`, then `UI`).
If a feature is trivial (a single function or config value), merge it with a related item.

If an item depends on another, note it on a second line as `depends: NNN`.

## Rules

- If you come across significant trade-offs or dilemmas, PAUSE, explain the issue, and seek guidance.
- Preserve items already in `docs/feature_backlog.md` that are not yet in `docs/features/` — only add, reorder, or remove items, do not rewrite existing descriptions without good reason.
- Each item is a `## NNN — slug-style-title` subheading followed by one sentence (and optionally a `depends:` line).
- Keep descriptions to one sentence — just enough for the coding agent to understand the scope.
- Do not mark any item as done. Completed work is tracked in `docs/features/`, not here.
