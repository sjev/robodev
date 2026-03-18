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

## What could be better

**Agent definitions duplicate skill content.** The three agent `.md` files largely repeat instructions from their referenced skills. A change to a skill must be mirrored in the agent definition or they drift.

**No documented recovery from `[BLOCKED]`.** When `/develop` hits `[BLOCKED]` after 2 rounds, there is no guidance on what happens next. The human likely knows (fix the spec, adjust scope), but documenting this would make the workflow self-contained.

**The `/implement` approval pause under `/develop`.** The implement skill waits for human approval of the checklist mid-execution. It is unclear whether `/develop` handles this pause or if the orchestration stalls. If the spec is already approved, this gate may be redundant in orchestrated mode.

**No session resumption.** If an agent session is interrupted (context limit, crash, blocker on item 7 of 10), there is no mechanism to detect partial progress and resume. Features are assumed to complete in one pass.

**Mermaid diagram in README has a typo.** `rieviews/{feature}.md` should be `reviews/{feature}.md`.

## Recommendations

1. **Reduce duplication between agents and skills.** Agent `.md` files should reference skills and add only agent-specific config (model, tools, constraints). Process instructions belong in skills alone.

2. **Document the `[BLOCKED]` recovery path.** A short section in the workflow or README covering what the human should do: amend the spec, adjust architecture, or manually intervene. Keeps the workflow self-explanatory.

3. **Clarify the `/implement` approval step in orchestrated mode.** Either skip the human checklist approval when running under `/develop` (the spec was already approved), or document that `/develop` requires mid-stream interaction.

4. **Consider session resumption.** Allow `/develop` to detect committed partial progress and resume from the last completed step. This becomes important as features grow beyond a single context window.

5. **Fix the README typo.** `rieviews` → `reviews`.
