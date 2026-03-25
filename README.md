# robodev

Structured AI-assisted development. You design, AI delivers.

Define what you want built. The agent writes the spec, implements it, commits, reviews, and merges — fully autonomous. You review the result on `main`; `git revert` if needed.

## Install

Run in your project directory:

```bash
curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh
```

## Commands

| Command | Purpose |
|---|---|
| `/architect` | Create/update architecture from user stories |
| `/plan` | Break architecture into a prioritized feature backlog |
| `/develop <description>` | Autopilot: spec → implement → commit → review (stops for manual testing) |
| `/merge <NNN-slug>` | Merge reviewed feature branch to main |
| `/commit` | Ad-hoc atomic conventional commits |
| `/review` | Periodic codebase audit (5 KPIs) |

## How `/develop` works

```
/develop "add CSV export for reports"
```

```mermaid
flowchart LR
    S[Setup<br>create branch] --> SP[Spec<br>write feature spec]
    SP --> I[Implement<br>tests + code + commits]
    I --> R[Review<br>check against spec]
    R -->|pass| T[Ready<br>manual testing]
    R -->|fixable| I
    T -->|/merge| M[Merge<br>to main]
```

| Phase | What happens | Model |
|---|---|---|
| **Setup** | Create `feat/<slug>` branch | Opus |
| **Spec** | Write lightweight feature spec, flag assumptions | Opus |
| **Implement** | Write tests, production code, commit atomically | Sonnet |
| **Review** | Compare diff against spec, check tests pass | Opus |

After review passes, `/develop` stops so you can test the branch manually. Run `/merge <NNN-slug>` when ready.

## Workflow overview

```mermaid
flowchart TD
    US[/user_stories.md/] --> ARCH("/architect") --> ARCH_DOC[/architecture.md/]
    ARCH_DOC --> PLAN("/plan") --> BACKLOG[/feature_backlog.md/]
    BACKLOG --> DEV("/develop") --> FEAT[feat branch]
    FEAT --> MRG("/merge") --> MAIN[main branch]
    MAIN --> REV("/review") --> REV_DOC[/review.md/]

    classDef doc fill:transparent,stroke:#888,stroke-width:1.5px;
    classDef cmd fill:transparent,stroke:#3b82f6,stroke-width:1.5px;

    class US,ARCH_DOC,BACKLOG,REV_DOC doc;
    class ARCH,PLAN,DEV,MRG,REV cmd;
```

## Development

Requires [uv](https://docs.astral.sh/uv/):

```bash
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
invoke init      # clones agentskills repo, installs skills-ref
invoke validate  # validate all skills
```
