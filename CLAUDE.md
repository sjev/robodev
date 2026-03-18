# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Setup
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clone agentskills repo into vendor/, install skills-ref validator

# Validate all skills
invoke validate

# Validate a single skill
skills-ref validate skills/<skill-name>
```

## What this repo is

**robodev** is a source of reusable workflow skills for AI coding agents. Skills live in `skills/` (tool-agnostic) and are installed into target projects via `install.sh` — into `.claude/skills/` for Claude Code and `.github/skills/` for GitHub Copilot CLI.

This is **not** a target project. Do not put skills in `.claude/` here.

## Skill format

Each skill is a directory under `skills/` containing:
- `SKILL.md` — required. YAML frontmatter (`name`, `description`) + Markdown body with the skill's instructions.
- `assets/` — optional supporting files (e.g. `template.md`).

Validation is done by `skills-ref` (installed from `vendor/agentskills/skills-ref` via `invoke init`).

## Structure

- `skills/` — skill definitions; one subdirectory per skill.
- `agents/` — Claude Code subagent definitions; installed to `.claude/agents/` in target projects.
- `tasks.py` — `invoke` tasks (`init`, `validate`).
- `vendor/` — cloned `agentskills/agentskills` repo (git-ignored, created by `invoke init`).

## Documentation

- [user stories](docs/user_stories.md)
- [claude code docs](https://code.claude.com/docs/llms.txt)

## Workflow internals

These details are internal to robodev's execution layer — not user-facing.

### Model routing (Claude Code)

| Role | Model | Rationale |
|---|---|---|
| Architect/coordinator | Opus | Highest-judgment work, user-facing |
| Feature authoring | Opus | Acceptance criteria and test plans need careful reasoning |
| Implementation | Sonnet | Heavy coding path, good balance of speed and quality |
| Commit planning | Haiku | Low-risk grouping and message writing |
| Review | Opus | Spec compliance requires high judgment |

### Subagent lifecycle

The main Opus architect process is the only long-lived thread. It spawns subagents during `/develop`:

1. Validate prerequisites (architecture doc, feature spec with `Status: draft`, active `feat/<name>` branch)
2. Prepare delivery plan from approved docs
3. Spawn **implementer** (Sonnet) — writes/updates tests, then production code
4. Spawn **commit planner** (Haiku) — inspects diff, proposes atomic conventional commits
5. Spawn **reviewer** (Opus) — compares committed diff against feature spec, writes `docs/reviews/<name>.md`
6. If reviewer returns `changes-requested`, loop back to implementer (max 2 rounds, then `[BLOCKED]`)

Other commands (`/architect`, `/feature`, `/merge`, `/feature-review`, `/full-review`) run in the main Opus thread without spawning subagents.

### Copilot runtime

Same workflow contract, no subagents or model routing. `/develop` runs all phases sequentially in one thread on whatever model the Copilot session uses.

### Constraints

1. **Agents do not make architectural decisions** — flag with `[BLOCKED]` or `[ARCH CHANGE NEEDED]`
2. **Dedicated feature branches** — feature work on `feat/<name>`, never directly on `main`
3. **Atomic conventional commits** — reviewable commit history even when commit planning is internal to `/develop`
4. **Review before merge** — mandatory, but internal to `/develop`
5. **No silent scope expansion** — no new dependencies/modules/behavior unless in the approved design
6. **Concise documents** — no filler, no placeholders
7. **Mermaid only** for diagrams
