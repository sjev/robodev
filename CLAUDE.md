# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Setup
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clone agentskills repo, install skills-ref validator

# Validate all skills
invoke validate
```

## Structure

- `skills/` — Skill definitions (Markdown). Each subdirectory is one skill (`SKILL.md` + optional `assets/`).
- `skills/instructions.md` — Meta-instructions template for target projects.
- `docs/` — Architecture, user stories, and agentic coding reference.
- `tasks.py` — `invoke` tasks for init and validation.
