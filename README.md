# robodev

Structured AI-assisted development. You design, AI delivers.

Software engineering solved the decompose-then-verify problem decades ago — break down on the left, verify on the right, gate each transition. AI can now own the lower layers (implementation and testing) while you keep the architecture. The feature spec is the interface between human intent and AI execution.

## The workflow loop

```mermaid
flowchart TD

    %% ==== DOCUMENTS ====
    US[/user_stories.md/]
    ARCH_DOC[/architecture.md/]
    BACKLOG[/feature_backlog.md/]
    FEAT_DOC[/features/feature.md/]
    FEAT_REV[/reviews/feature.md/]
    FULL_REV[/full_review.md/]

    %% ==== ACTIONS ====
    ARCH("architect")
    PLAN("plan")
    FEAT("define feature")
    DEV("develop")
    MERGE("merge")
    FULL("full review")
    UPDATE("update arch")

    %% ==== FLOW ====
    US --> ARCH --> ARCH_DOC
    ARCH_DOC --> PLAN --> BACKLOG
    BACKLOG --> FEAT --> FEAT_DOC
    FEAT_DOC --> DEV --> FEAT_REV
    FEAT_REV --> MERGE --> FULL
    FULL --> FULL_REV --> UPDATE --> ARCH_DOC

    %% ==== STYLING (theme-safe) ====
    classDef doc fill:transparent,stroke:#888,stroke-width:1.5px;
    classDef cmd fill:transparent,stroke:#3b82f6,stroke-width:1.5px;
    classDef manual fill:transparent,stroke:#22c55e,stroke-width:2px;

    class US,ARCH_DOC,BACKLOG,FEAT_DOC,FEAT_REV,FULL_REV doc;
    class FEAT,DEV,MERGE,FULL cmd;
    class ARCH,PLAN,UPDATE manual;
```

## What `/develop` automates

```mermaid
flowchart TD
    I["implement<br>(tests + code)"] --> C["commit<br>(plan + create)"] --> R["review<br>(spec compliance)"]
    R -->|"changes requested<br>(max 2×)"| I
```

On Claude Code, each phase runs as a separate subagent with model routing. On Copilot, the same phases run sequentially in one thread.

## Install

Run in your project directory:

```bash
curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh
```

Create `docs/user_stories.md` with your requirements, then:

```bash
/architect            # design from user stories
/feature user-auth    # create branch + spec
/develop user-auth    # AI implements, tests, commits, reviews
/merge user-auth      # merge to main
```

## Commands

| Command | Purpose |
|---|---|
| `/architect` | Create/update architecture from user stories |
| `/feature <name>` | Branch + feature spec |
| `/develop <name>` | Implement, test, commit, review |
| `/merge <name>` | Merge approved feature to main |
| `/feature-review` | Optional standalone review |
| `/full-review` | Periodic codebase audit |

## Development

Requires [uv](https://docs.astral.sh/uv/):

```bash
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clones agentskills repo, installs skills-ref
invoke validate  # validate all skills
```
