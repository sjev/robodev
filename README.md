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
| `/feature` | Create or switch to `feat/<name>`, then design the feature into `docs/features/<name>.md` |
| `/tdd-tests` | Write failing tests from a feature's Test Plan (Red phase) |
| `/implement` | Implement a feature design as code + tests |
| `/commit` | Stage and commit on the active feature branch with conventional messages |
| `/feature-review` | Review committed branch changes vs `main` |
| `/merge` | Merge the approved feature branch into `main` with a merge commit, then delete it |
| `/full-review` | Audit entire codebase on 5 KPIs |

**Typical flow:**

Create `docs/user_stories.md`. Write them in a form "As a ... I want ... So that ..."
See [docs/user_stories.md](docs/user_stories.md) for user stories for this project.

```bash
> /architect            # design or update architecture
> /feature my-feature   # create/switch feat/my-feature and write the spec
> /tdd-tests my-feature # write failing tests from the spec's Test Plan
> /implement docs/features/my-feature.md # make tests pass (Green phase)
> /commit               # create atomic commits on the feature branch
> /feature-review my-feature
> /merge my-feature
```

Each step requires explicit architect approval before the agent proceeds.

Notes:
- `docs/features/<name>.md` includes a `Status:` field. The normal progression is `draft` → `implemented` → `approved` or `changes-requested` → `merged`.
- `/feature` creates or switches to `feat/<name>` from `main`, so the feature branch becomes the workspace for `/tdd-tests`, `/implement`, and `/commit`.
- Feature specs are expected to include a Test Plan. `/feature-review` checks acceptance criteria and test coverage against the committed branch diff versus `main`.
- `/merge` uses a merge commit and deletes the local feature branch after success.
- `/tdd-tests` and `/implement` assume your project’s test command is `invoke test` (adjust the skills if you use a different runner).

See `docs/architecture.md` for the full workflow.

## Development

To contribute or validate skills locally, requires [uv](https://docs.astral.sh/uv/):

```bash
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clones agentskills/agentskills, installs skills-ref
invoke validate  # validate all skills
```
