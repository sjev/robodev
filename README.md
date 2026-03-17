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

After install, the primary workflow commands are:

| Command | Description |
|---|---|
| `/architect` | Create or update `docs/architecture.md` from user stories |
| `/feature` | Create or switch to `feat/<name>`, then design the feature into `docs/features/<name>.md` |
| `/develop` | Orchestrate test writing, implementation, commit planning, and review for the active feature |
| `/merge` | Merge the approved feature branch into `main` with a merge commit, then delete it and its temporary feature docs |
| `/feature-review` | Optional standalone re-review of a feature branch when you want another pass before merge |
| `/full-review` | Audit the entire codebase on 5 KPIs |

**Typical flow:**

Create `docs/user_stories.md`. Write them in a form "As a ... I want ... So that ..."
See [docs/user_stories.md](docs/user_stories.md) for user stories for this project.

```bash
> /architect            # design or update architecture
> /feature my-feature   # create/switch feat/my-feature and write the spec
> /develop my-feature   # tests, implementation, commits, and review
> /merge my-feature
```

Architect approval happens at workflow gates instead of every micro-step:

- approve architecture before feature work
- approve the feature spec before delivery
- approve merge after reviewing the delivery output

### Claude orchestration

On Claude Code, the main conversation acts as the long-lived **architect/coordinator** and uses **Opus**.

- `/architect` stays in the main Opus thread because it is decision-heavy and requires direct back-and-forth with the human architect.
- `/feature` also stays in the main Opus thread so scope, acceptance criteria, and test plan quality are shaped in the highest-judgment context.
- When `/develop` starts, the main Opus architect reads the approved architecture and feature spec, validates branch state, and then spawns workers in sequence:
  - **Implementer** on **Sonnet** for test writing and production code changes
  - **Commit planner** on **Haiku** for fast, cheap commit grouping and message drafting
  - **Reviewer** on **Opus** for acceptance-criteria checks, test-coverage checks, and merge-readiness review
- If the Opus reviewer returns `changes-requested`, the architect sends the work back to the Sonnet implementer, then reruns the Opus reviewer (maximum 2 rounds).
- `/feature-review` and `/full-review` use the same **Opus** reviewer profile when run standalone.

Notes:
- `docs/features/<name>.md` includes a `Status:` field while the feature is in progress. The normal progression is `draft` → `implemented` → `approved` or `changes-requested`.
- `/feature` creates or switches to `feat/<name>` from `main`, so the feature branch becomes the workspace for `/develop`.
- `/develop` is the main delivery command. On Claude Code it delegates internally from the main Opus architect thread to project subagents. On Copilot CLI it follows the same contract in one command without project subagents.
- Feature specs are expected to include a Test Plan. `/develop` writes or updates `docs/reviews/<name>.md` as part of the delivery flow; `/feature-review` is available when you want to rerun the reviewer independently.
- `/merge` uses a merge commit, deletes `docs/features/<name>.md` and `docs/reviews/<name>.md` in that merge commit, and then deletes the local feature branch after success.

See `docs/architecture.md` for the full workflow.

## Development

To contribute or validate skills locally, requires [uv](https://docs.astral.sh/uv/):

```bash
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clones agentskills/agentskills, installs skills-ref
invoke validate  # validate all skills
```
