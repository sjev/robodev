# CLAUDE.md

## Commands

```bash
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clone agentskills repo into vendor/, install skills-ref validator
invoke validate  # validate all skills
```

## What this repo is

**robodev** is a source of reusable workflow skills for AI coding agents. Skills live in `skills/` and are installed into target projects via `install.sh`.

## Structure

- `skills/` — one subdirectory per skill, each with a `SKILL.md`
- `agents/` — Claude Code subagent definitions (installed to `.claude/agents/` in target projects)
- `tasks.py` — `invoke init` and `invoke validate`

## Skill format

Each skill directory contains:
- `SKILL.md` — YAML frontmatter (`name`, `description`) + Markdown instructions
- `assets/` — optional supporting files (templates, scripts)
