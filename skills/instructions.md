# Project Instructions

## Workflow

This project follows a phased workflow with architect gates:

```
/architect → /feature → /tdd-tests → /implement → /commit → /feature-review → /merge
```

Each phase requires explicit architect approval before proceeding to the next.

## Principles

- **Architect controls decisions.** Agents implement, they do not decide. Flag conflicts with `[BLOCKED: reason]` and stop. Flag architectural gaps with `[ARCH CHANGE NEEDED: description]` and stop.
- **Atomic increments.** Every change should be reviewable and commitable on its own.
- **Branch discipline.** Create a dedicated feature branch with `/feature`, keep development there, review committed branch diffs, then merge back to `main` with `/merge`.
- **No silent expansion.** Do not add dependencies, modules, or functionality not in the design doc.
- **Concise output.** No filler, no "TBD", no placeholders. Every sentence must be actionable or informative.

## Conventions

- Conventional commits: `type(scope): description` (imperative mood).
- Mermaid for all diagrams.
- Full type annotations on new code.
- Tests alongside implementation — cover acceptance criteria, not just happy paths.

## Project structure

- `docs/architecture.md` — architecture document (single source of truth).
- `docs/features/<name>.md` — feature design documents.
- `docs/review.md` — latest full-review output.
- `skills/` — agent skills (this folder).
