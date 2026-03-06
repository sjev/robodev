# robodev

Tool-agnostic workflow skills for architects steering AI coding agents.

## What is this?

Reusable workflow skills using the [Agent Skills](https://agentskills.io) standard. Works with Claude Code CLI, Copilot CLI, and other compatible tools.

## Who is this for?

Architects who want AI agents to handle implementation while maintaining control and producing atomic, reviewable commits.


## Install

Run this in your project directory (requires `git`):

```bash
curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh
```


This installs skills into:

- `.claude/skills/` — Claude Code
- `.github/skills/` — GitHub Copilot CLI

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


Create `docs/user_stories.md`. Write them in a form "As a ... I want ... So that ..."
See [docs/user_stories.md](docs/user_stories.md) for user stories for this project.

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
