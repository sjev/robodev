# robodev

Tool-agnostic workflow skills for architects steering AI coding agents.

## What is this?

Reusable workflow skills using the [Agent Skills](https://agentskills.io) standard. Works with Claude Code CLI, Copilot CLI, and other compatible tools.

## Problems it solves

- **Prompt drift**: Single source of truth across tools
- **Loss of control**: Architect gates at each phase
- **Context bloat**: Minimal, focused instructions
- **Blind spots**: Cross-agent review

## Who is this for?

Architects who want AI agents to handle implementation while maintaining control and producing atomic, reviewable commits.

## Workflow skills

- `/architect` — Create architecture from user stories
- `/feature` — Design features into docs
- `/implement` — Implement designs as code
- `/feature-review` — Review branch changes
- `/full-review` — Audit entire codebase
- `/commit` — Create atomic conventional commits

See `docs/architecture.md` for details. 
