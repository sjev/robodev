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

## Install

Run this in your project directory (requires `git`):

```bash
curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh
```

This clones robodev to `~/.local/share/robodev/` and installs skills into:

- `.claude/skills/` — Claude Code
- `.github/prompts/` — GitHub Copilot

It also creates `docs/` and `CLAUDE.md` with workflow instructions.

**Options:**

```bash
# Claude Code only
curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh -s -- --claude

# GitHub Copilot only
curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh -s -- --copilot

# Skip docs/ and CLAUDE.md scaffolding
curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh -s -- --no-scaffold
```

Re-run the same command to update skills.

## Usage

After install, the following slash commands are available in your AI coding tool:

| Command | Description |
|---|---|
| `/architect` | Create or update `docs/architecture.md` from user stories |
| `/feature` | Design a feature into `docs/features/<name>.md` |
| `/implement` | Implement a feature design as code + tests |
| `/feature-review` | Review branch changes vs `main` |
| `/full-review` | Audit entire codebase on 5 KPIs |
| `/commit` | Stage and commit with conventional messages |

**Typical flow:**

```bash
git checkout -b feat/my-feature
> /architect          # design or update architecture
> /feature my-feature # design the feature
> /implement docs/features/my-feature.md
> /feature-review
> /commit
```

Each step requires explicit architect approval before the agent proceeds.

See `docs/architecture.md` for the full workflow.

## Development

To contribute or validate skills locally, requires [uv](https://docs.astral.sh/uv/):

```bash
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clones agentskills/agentskills, installs skills-ref
invoke validate  # validate all skills
```
