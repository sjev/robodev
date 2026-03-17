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
- `skills/instructions.md` — project instructions template, copied to target projects on install.
- `docs/architecture.md` — full workflow and design decisions.
- `tasks.py` — `invoke` tasks (`init`, `validate`).
- `vendor/` — cloned `agentskills/agentskills` repo (git-ignored, created by `invoke init`).

## Documentation

- [user stories](docs/user_stories.md)
- [architecture](docs/architecture.md)
- [claude code docs](https://code.claude.com/docs/llms.txt)
