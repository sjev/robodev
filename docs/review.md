# Robodev Workflow Review

| Field | Value |
|---|---|
| Date | 2026-03-18 |
| Reviewer | Claude Opus 4.6 (claude-opus-4-6) |
| Role | Independent critical review |

## Summary

Robodev is a document-driven, AI-assisted development workflow. The human acts as architect — owning user stories, architecture, and feature specs. AI agents handle implementation, committing, and review.

The core loop:

```
user_stories.md → /architect → architecture.md → (manual backlog) → /feature → features/{name}.md → /develop → reviews/{name}.md → /merge → /full-review
```

`/develop` orchestrates three subagents:

1. **Implementer** (Sonnet) — tests + production code
2. **Commit planner** (Haiku) — atomic conventional commits
3. **Reviewer** (Opus) — spec compliance check

Review loop: max 2 rounds, then `[BLOCKED]`.

Nine skills, three agent definitions (for model routing), shell scripts for git operations. Skills install into both Claude Code and GitHub Copilot targets.

## Relation to existing development methods

**V-Model** — The "decompose on the left, verify on the right" structure is textbook V-Model. Architecture decomposes into features, features into tasks. Verification mirrors this: tests verify code, feature review verifies the spec, full review verifies architecture alignment.

**XP** — TDD discipline, small increments, atomic commits, and the write/review split (one agent implements, a different one reviews — analogous to pair programming).

**Lean** — Minimal process artifacts. No heavyweight ceremonies. Features pulled one at a time from a backlog.

**Document-driven development** — The feature spec is a formal contract between human intent and AI execution. Closest analogy: Design-by-Contract, where the spec is both instruction and acceptance test.

The novelty: AI agents are the "development team," documents are the control interface, and model routing optimizes cost per task type.

## What is good

**Spec-as-interface.** The feature spec with structured acceptance criteria and test plans is the strongest design decision. It makes AI execution verifiable and gives the human a precise control surface.

**Cross-agent review.** A different agent (and model) reviews than implements. This is a genuine quality mechanism that avoids single-agent blind spots.

**Model routing.** Haiku for commits, Sonnet for code, Opus for review — pragmatic cost optimization without sacrificing quality where judgment matters.

**Explicit guardrails.** `[BLOCKED]`, `[ARCH CHANGE NEEDED]`, scope expansion rules, and the 2-round review cap prevent silent derailment.

**Simplicity.** Local-first execution (`inv lint`, `inv test`), no remote CI dependency, no heavyweight infrastructure. Fast feedback loops.

**Tool independence.** Skills work on Claude Code and GitHub Copilot via a simple format (YAML frontmatter + Markdown).

**Clean git history.** Atomic conventional commits maintained even in automated workflows.

## Resolved issues

The following issues identified in the initial review have been addressed.

**Agent/skill duplication eliminated.** Agent `.md` files now contain only frontmatter (name, description, model, tools, skills). Process and rules live exclusively in the referenced skills. The `implementer` agent carries a single-line note for the one behavioral delta in orchestrated mode.

**`[BLOCKED]` recovery documented.** When `/develop` hits `[BLOCKED]` after 2 review rounds, it now sets `Status: blocked` on the feature spec, marks the feature blocked in the backlog (if present), and stops with an explanatory message directing the architect to amend the spec or architecture before retrying.

**`/implement` approval clarified.** The "Standalone vs /develop" section in `skills/implement/SKILL.md` now explicitly states that the checklist and architect approval are skipped when running under `/develop` — the approved feature spec is the plan.

**Session resumption documented.** `skills/develop/SKILL.md` includes a "Resuming an interrupted run" section: when the architect instructs a resume, `/develop` inspects `git log` and the feature spec `Status` to determine the last completed phase and continues from the next.

**README typo fixed.** `rieviews/{feature}.md` corrected to `reviews/{feature}.md` in the Mermaid diagram.
