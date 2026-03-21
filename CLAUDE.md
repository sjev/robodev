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
| Implementation + commits | Sonnet | Heavy coding path, good balance of speed and quality |

### Subagent lifecycle

The main Opus thread is the only long-lived process. During `/develop` it:

1. Creates feature branch and writes lightweight spec (Phase 0–1)
2. Spawns **implementer** (Sonnet) — writes tests, production code, and commits atomically (Phase 2)
3. Reviews the result inline — compares diff against spec (Phase 3)
4. If fixable issues found, loops back to implementer once
5. Merges to main and cleans up the feature branch (Phase 4)

Other commands (`/architect`, `/commit`, `/review`) run in the main Opus thread without spawning subagents.

### Copilot runtime

Same workflow, no subagents or model routing. `/develop` runs all phases sequentially in one thread.

### Constraints

1. **Flag, don't ask** — agents make assumptions and flag with `[ASSUMPTION]`, only stop for genuine blockers
2. **Auto-branching** — feature branches are created and merged automatically by `/develop`
3. **Atomic conventional commits** — reviewable history even in automated workflows
4. **Self-review before merge** — automatic, internal to `/develop`
5. **No silent scope expansion** — no new dependencies or modules without flagging as `[ASSUMPTION]`
