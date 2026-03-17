# robodev

Workflow assets for architects steering AI coding agents, with a Claude-first delivery flow and a Copilot fallback.

## What is this?

Reusable workflow assets built on the [Agent Skills](https://agentskills.io) standard.

The core workflow stays portable across tools, but the best experience is on Claude Code: `robodev` installs shared skills plus project subagents so routine delivery work can be delegated automatically without losing architect control.

## Who is this for?

Architects who want AI agents to handle implementation while maintaining control and producing atomic, reviewable commits.


## Install

Run this in your project directory (requires `git`):

```bash
curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh
```


This installs workflow assets into:

- `.claude/skills/` — shared workflow skills for Claude Code
- `.claude/agents/` — Claude project subagents for orchestration
- `.github/skills/` — shared workflow skills for GitHub Copilot CLI

Re-run the same command to update skills.

## Usage

After install, the workflow is designed to feel like a short architect-led delivery loop rather than a long checklist of agent commands.

### Workflow overview

1. **`/architect`** turns user stories into `docs/architecture.md`.
2. **`/feature <name>`** creates or switches to `feat/<name>` and writes the feature spec in `docs/features/<name>.md`.
3. **`/develop <name>`** delivers the feature against the approved docs: tests, implementation, commit planning, and review.
4. **`/merge <name>`** merges the approved feature branch into `main`, removes the temporary feature docs in the merge commit, and deletes the local feature branch.

This keeps the architect in control of design and merge decisions while pushing routine delivery work into a repeatable flow.

### Approval gates

Architect approval happens at workflow gates instead of every micro-step:

- approve architecture before feature work
- approve the feature spec before delivery
- approve merge after reviewing the delivery output

If the work uncovers ambiguity or a design mismatch, the flow is expected to stop and surface it instead of silently expanding scope.

### Primary commands

| Command | Description |
|---|---|
| `/architect` | Create or update `docs/architecture.md` from user stories |
| `/feature` | Create or switch to `feat/<name>`, then design the feature into `docs/features/<name>.md` |
| `/develop` | Deliver the active feature by orchestrating tests, implementation, commit planning, and review |
| `/merge` | Merge the approved feature branch into `main` with a merge commit, then delete it and its temporary feature docs |
| `/feature-review` | Optional standalone re-review of a feature branch when you want another pass before merge |
| `/full-review` | Periodic whole-codebase audit on 5 KPIs |

### Branch and document lifecycle

- `docs/features/<name>.md` is the working feature spec and carries a `Status:` field while the feature is in progress.
- `/feature` creates or switches to `feat/<name>` from `main`, so feature work stays off the main branch.
- Feature specs are expected to include a Test Plan.
- `/develop` writes or updates `docs/reviews/<name>.md` as part of delivery.
- `/merge` removes `docs/features/<name>.md` and `docs/reviews/<name>.md` in the merge commit so `main` keeps the durable architecture but not temporary feature paperwork.

### Claude-first, Copilot-compatible

The workflow contract stays the same across tools, but the execution model differs:

- **Claude Code** is the best-supported runtime. The main conversation stays in the architect/coordinator role, and `/develop` can delegate implementation, commit planning, and review to specialized workers.
- **GitHub Copilot CLI** follows the same high-level phases and document contract, but runs them sequentially in one session instead of through project subagents.

Create `docs/user_stories.md` in the form "As a ... I want ... So that ...". See [docs/user_stories.md](docs/user_stories.md) for this project's example stories.

```bash
> /architect            # design or update architecture
> /feature my-feature   # create/switch feat/my-feature and write the spec
> /develop my-feature   # tests, implementation, commits, and review
> /merge my-feature
```

See `docs/architecture.md` for the full workflow design, runtime details, and constraints.

## Development

To contribute or validate skills locally, requires [uv](https://docs.astral.sh/uv/):

```bash
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clones agentskills/agentskills, installs skills-ref
invoke validate  # validate all skills
```
