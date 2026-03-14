# Architecture: robodev

## Problem and context

Developers using AI coding agents face prompt/configuration drift between tools and
lack a repeatable workflow keeping the human architect in control. This template
provides a single-source-of-truth setup using the [Agent Skills](https://agentskills.io)
open standard so teams can switch agents without duplicating instructions.

Target audience: software architects steering AI agents through a phased workflow
(spec → plan → implement → review) with reviewable, atomic increments.

## Goals and non-goals

**Goals:** single source of truth via Agent Skills standard; phased workflow with
architect gates; tool-agnostic (Claude Code CLI, Copilot CLI, any Agent Skills
compatible tool); minimal context to avoid token bloat.

**Non-goals:** not a framework/runtime — static template only; no CI/CD; language-agnostic.

## Repository structure

```
robodev/
├── skills/                                      # Tool-agnostic skill sources
│   ├── instructions.md                          # Project instructions template
│   ├── architect/SKILL.md
│   ├── feature/SKILL.md + template.md
│   ├── tdd-tests/SKILL.md
│   ├── implement/SKILL.md
│   ├── feature-review/SKILL.md
│   ├── merge/SKILL.md
│   ├── full-review/SKILL.md
│   └── commit/SKILL.md
├── docs/
│   ├── architecture.md                          # This document
│   ├── features/                                # Active feature design docs (cleaned up on merge)
│   ├── reviews/                                 # Active feature review docs (cleaned up on merge)
│   └── internal/user_stories.md                 # Requirements
└── README.md
```

This repo is a **source of reusable workflow skills**, not a target project.
Skills live in a neutral `skills/` folder — not in `.claude/` or `.github/` —
because they aren't tied to any specific tool.

An installer script (future) copies skills into a target project's tool-specific
locations (e.g., `.claude/skills/`, `.github/copilot-instructions.md`).

## Skill inventory

| Skill | Purpose | Invocation | Context |
|---|---|---|---|
| `/architect` | Create/update `docs/architecture.md` from user stories | User-only | Inline |
| `/feature` | Create/switch feature branch and write `docs/features/<name>.md` | User-only | Inline |
| `/tdd-tests` | Write failing tests from a feature test plan | User-only | Inline |
| `/implement` | Implement a feature design as code + tests | User-only | Inline |
| `/commit` | Stage and commit feature-branch changes with conventional messages | User-only | Inline |
| `/feature-review` | Review committed feature-branch diff vs `main` | Both | Fork (Explore subagent) |
| `/merge` | Merge approved feature branch into `main` and clean up temporary feature docs | User-only | Inline |
| `/full-review` | Audit full codebase, score on 5 KPIs | Both | Fork (Explore subagent) |

Code-changing skills require explicit user invocation. Review skills run in forked
subagents (read-only, isolated context) enabling cross-agent review — a different
model reviews than the one that authored the code.

## Development cycle

```mermaid
flowchart LR
    A["/architect"] -->|approve| B["/feature"]
    B -->|approve| C["/tdd-tests"]
    C -->|approve| D["/implement"]
    D -->|approve| E["/commit"]
    E -->|review ready| F["/feature-review"]
    F -->|approve| G["/merge"]
    H["/full-review"] -.->|periodic| A
```

1. **`/architect`** — agent asks clarifying questions, produces architecture doc. Gate: architect approves.
2. **`/feature`** — agent creates or switches to `feat/<name>` from `main`, then writes the feature design doc. Gate: architect approves. Flags `[ARCH CHANGE NEEDED]` if architecture needs updating.
3. **`/tdd-tests`** — agent writes failing tests from the feature Test Plan on the feature branch. Gate: architect approves the Red phase.
4. **`/implement`** — agent reads architecture + design doc, proposes numbered plan at commit granularity, then implements on the feature branch. Gate: architect approves plan, then each step. Agent stops with `[BLOCKED]` on conflicts.
5. **`/commit`** — agent groups feature-branch changes into atomic conventional commits (`type(scope): description`). Gate: architect approves before execution.
6. **`/feature-review`** — forked subagent reviews the committed feature-branch diff against `main`. Output: Critical issues + Suggestions. Gate: address criticals before merge.
7. **`/merge`** — agent merges the approved feature branch into `main` with a merge commit, removes the temporary feature spec/review docs in that merge commit, and deletes the local feature branch.
8. **`/full-review`** (periodic) — forked subagent scores codebase on 5 KPIs, produces `docs/review.md`.

### Example flow

```bash
> /feature user-auth                           # create/switch feat/user-auth and design
# architect reviews docs/features/user-auth.md
> /tdd-tests user-auth                         # write failing tests
# architect reviews failing tests and implementation plan
> /implement docs/features/user-auth.md        # implement on the feature branch
> /commit                                      # create atomic commits
> /feature-review user-auth                    # review (use different agent if possible)
> /merge user-auth                             # merge to main and delete the branch
```

## Constraints

1. **Agents do not make architectural decisions** — flag with `[BLOCKED]` or `[ARCH CHANGE NEEDED]` and wait.
2. **Dedicated feature branches** — create work on `feat/<name>`, not directly on `main`.
3. **Atomic conventional commits** — `type(scope): description`.
4. **No new dependencies** unless in the design doc.
5. **Concise documents** — no filler, no "TBD", no placeholders.
6. **Mermaid only** for diagrams.
7. **Cross-agent review** when practical.

## Open questions

- Installer script design: copy files, or symlink from a cloned robodev into the target project?
- How to handle agent-specific settings with no cross-tool equivalent (e.g., `.claude/settings.json`)?
- Should the installer also scaffold `docs/` structure in the target project?
