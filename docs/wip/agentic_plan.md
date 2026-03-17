# RoboDev Implementation Plan

## 1. TARGET WORKFLOW (from docs/architecture.md)

Agent-first, architect-led workflow with approval gates:

### Commands
| Command | Purpose | Runtime |
|---|---|---|
| `/architect` | Create/update `docs/architecture.md` from user stories | Inline (Opus) |
| `/feature <name>` | Create `feat/<name>` branch + spec | Inline (Opus) |
| `/develop <name>` | Orchestrate tests → implementation → commits → review | Claude: subagents; Copilot: sequential single-thread |
| `/feature-review <name>` | Standalone re-review | Inline (Opus) |
| `/merge <name>` | Merge approved feature into `main` + cleanup | Inline (Opus) |
| `/full-review` | Periodic whole-codebase audit | Inline (Opus) |

### Gates
- Architect approves architecture before features
- Architect approves feature spec before `/develop`
- Architect approves review output before `/merge`
- Agents flag ambiguity with `[BLOCKED]` or `[ARCH CHANGE NEEDED]`

### Key mechanics
- Feature branches: `feat/<name>` from `main`; never direct commits to `main`
- Atomic conventional commits: `type(scope): description`
- Feature specs: `docs/features/<name>.md` with `Status:` field (`draft` → `implemented` → `approved` / `changes-requested`)
- Review reports: `docs/reviews/<name>.md` (deleted on merge)
- Architecture doc is always current; human-owned, no approval mechanism needed

---

## 2. IMPLEMENTATION TODAY (What Actually Exists)

### Skills Fully Implemented
✅ **`/architect`** — `skills/architect/SKILL.md`
   - Reads user stories + existing architecture
   - Asks clarifying questions
   - Produces `docs/architecture.md` using template

✅ **`/feature`** — `skills/feature/SKILL.md`
   - Takes feature name argument
   - Runs `scripts/start_branch.sh` to create `feat/<name>` from `main`
   - Asks scope/acceptance criteria questions
   - Produces `docs/features/<name>.md` with `Status: draft`

✅ **`/tdd-tests`** — `skills/tdd-tests/SKILL.md`
   - Reads feature spec's Test Plan
   - Writes failing tests using pytest
   - Verifies Red phase confirmed

✅ **`/implement`** — `skills/implement/SKILL.md`
   - Creates numbered implementation plan at commit granularity
   - Implements step-by-step with architect approval
   - Updates feature spec status to `implemented`
   - Requires architect approval before code writing

✅ **`/commit`** — `skills/commit/SKILL.md`
   - Uses `scripts/status.sh` and `scripts/commit.sh`
   - Groups changes into atomic conventional commits
   - Proposes commits for approval before creating them

✅ **`/feature-review`** — `skills/feature-review/SKILL.md`
   - Takes feature name argument
   - Uses `scripts/diff.sh` to get committed diff
   - Compares against acceptance criteria, tests, code quality
   - Produces `docs/reviews/<feature-name>.md`
   - Updates feature spec status to `approved` or `changes-requested`

✅ **`/merge`** — `skills/merge/SKILL.md`
   - Takes feature name argument
   - Verifies feature status is `approved`
   - Uses `scripts/merge.sh` to merge into `main` + delete temp docs
   - Deletes local feature branch

✅ **`/full-review`** — `skills/full-review/SKILL.md`
   - Audits entire codebase against 5 KPIs (Maintainability, Extensibility, Testability, Robustness, Clarity)
   - Scores 0–10 per KPI
   - Produces `docs/review.md`

### Scripts Implemented
✅ `skills/feature/scripts/start_branch.sh` — Create or switch to `feat/<name>` from `main`
✅ `skills/commit/scripts/status.sh` — Show branch status + diff
✅ `skills/commit/scripts/commit.sh` — Stage files and create conventional commits
✅ `skills/merge/scripts/merge.sh` — Merge to `main`, remove temp docs, delete branch
✅ `skills/feature-review/scripts/diff.sh` — Show committed diff against `main`

### Infrastructure
✅ `install.sh` — Symlinks all skills from `skills/` into `.claude/skills/` and `.github/skills/`
✅ `tasks.py` — `invoke init` (clone agentskills) and `invoke validate` (validate all skills)
✅ `pyproject.toml` — Project metadata + dev dependencies
✅ Skill validation via `skills-ref` (vendored from agentskills)

### Documentation
✅ `README.md` — User-facing workflow guide with usage examples
✅ `docs/architecture.md` — Full architectural design, tool-specific behavior, constraints
✅ `CLAUDE.md` — Guidance for Claude Code when working on this repo
✅ Feature templates: `skills/feature/assets/template.md`, `skills/architect/assets/template.md`, `skills/full-review/assets/template.md`

---

## 3. GAPS

### ❌ `/develop` skill does not exist

Architecture describes `/develop` as the main delivery command orchestrating:
- Prerequisite validation (docs exist, branch correct)
- Implementation (tests + production code)
- Commit planning (atomic grouping + messages)
- Review (acceptance criteria, test coverage, merge readiness)
- Review loop (max 2 rounds, then `[BLOCKED]`)

Today the individual skills exist (`/tdd-tests`, `/implement`, `/commit`, `/feature-review`), but nothing orchestrates them.

### ❌ No Claude project subagents defined

Architecture describes three subagents:
- **Implementer** (Sonnet) — tests + production code
- **Commit planner** (Haiku) — atomic commit grouping
- **Reviewer** (Opus) — acceptance criteria + code quality review

No agent definitions exist. Source definitions need to live in the robodev repo and be installed into target projects by `install.sh`.

### ❌ `install.sh` does not install agents

Currently only symlinks skills. Must also install agent definitions into `.claude/agents/` in target projects.

### ⚠️ `/tdd-tests` vs `/implement` overlap

Both skills cover test writing. Resolution: under `/develop` orchestration, the **implementer subagent handles both tests and production code** (per architecture.md Step 3). `/tdd-tests` remains available as a standalone skill for manual use outside `/develop`.

---

## 4. IMPLEMENTATION

### New files

1. **`skills/develop/SKILL.md`**
   - Tool-agnostic orchestration skill. Describes the phases and their contracts, not runtime-specific branching.
   - Takes `<feature-name>` argument.
   - Validates prerequisites: `docs/architecture.md` exists, `docs/features/<name>.md` exists with `Status: draft`, active `feat/<name>` branch.
   - Phase 1 — **Implement**: write/update tests from feature test plan, then implement production code until acceptance criteria are satisfied or a blocker is found.
   - Phase 2 — **Commit**: inspect the diff, propose atomic commit groups and conventional commit messages, create commits after architect approval.
   - Phase 3 — **Review**: compare committed diff against feature spec, check acceptance criteria, test coverage, merge readiness, write `docs/reviews/<name>.md`.
   - Phase 4 — **Loop**: if review returns `changes-requested`, loop back to Phase 1 with review findings. Maximum 2 review rounds; stop with `[BLOCKED]` if issues persist.
   - On Claude Code, each phase is delegated to a project subagent (see below). On other runtimes, all phases run sequentially in one thread.

2. **`agents/implementer.md`** (source; installed to `.claude/agents/` in target projects)
   - Model: Sonnet
   - Reads `docs/architecture.md` and `docs/features/<name>.md`.
   - Writes or updates tests from the feature test plan.
   - Implements production code until acceptance criteria are satisfied or a blocker is found.
   - Runs tests after each logical step; reports pass/fail.
   - Stops on blockers with `[BLOCKED]`.
   - Does NOT commit — leaves changes in the working tree for the commit planner.

3. **`agents/commit-planner.md`** (source; installed to `.claude/agents/` in target projects)
   - Model: Haiku
   - Inspects the working tree diff.
   - Proposes atomic commit groups and conventional commit messages.
   - Waits for architect approval of the proposed plan.
   - Creates commits after approval using selective staging.
   - Uses `scripts/commit.sh` from the commit skill.

4. **`agents/reviewer.md`** (source; installed to `.claude/agents/` in target projects)
   - Model: Opus
   - Compares committed diff against feature spec.
   - Checks acceptance criteria, test coverage, code quality.
   - Writes `docs/reviews/<name>.md`.
   - Sets feature spec `Status:` to `approved` or `changes-requested`.
   - Maximum 10 actionable items; all must cite specific locations.

### Modified files

1. **`install.sh`**
   - Add agent installation: copy files from `agents/` to `.claude/agents/` in the target project.
   - Skills continue to be symlinked; agents are copied (they may be customized per project).

2. **`skills/implement/SKILL.md`**
   - Add note: when invoked standalone, handles both tests and production code (same as when called by `/develop`).
   - `/tdd-tests` is an alternative for Red-phase-only work outside `/develop`.

3. **`CLAUDE.md`**
   - Update structure section: add `agents/` directory description.
   - Remove stale `instructions.md` reference (already done).

### No changes needed

- `skills/tdd-tests/SKILL.md` — remains as standalone Red-phase skill.
- `skills/commit/SKILL.md` — commit planner agent reuses its scripts.
- `skills/feature-review/SKILL.md` — reviewer agent reuses its logic; standalone use unchanged.
- `skills/feature/SKILL.md` — already handles feature creation correctly.
- `skills/architect/SKILL.md` — already handles architecture correctly.
- `skills/merge/SKILL.md` — already handles merge correctly.
- `skills/full-review/SKILL.md` — already handles full review correctly.

---

## IMPLEMENTATION ORDER

1. **`skills/develop/SKILL.md`** — the orchestration skill (tool-agnostic phases + contracts)
2. **`agents/implementer.md`**, **`agents/commit-planner.md`**, **`agents/reviewer.md`** — Claude subagent definitions
3. **`install.sh`** — add agent installation to target projects
4. **`skills/implement/SKILL.md`** — clarify TDD integration note
5. **`CLAUDE.md`** — update structure section
6. End-to-end test on a sample feature

---

## SUMMARY

**Gap:** The orchestration skill (`/develop`) and Claude subagent definitions are the critical missing pieces. Everything else is ready.

**Key design decisions resolved:**
- `/develop` skill is tool-agnostic (describes phases); Claude-specific routing lives in agent definitions only.
- Agent source files live in `agents/` in the robodev repo; `install.sh` copies them to `.claude/agents/` in target projects.
- The implementer subagent handles both tests and production code. `/tdd-tests` remains a standalone skill for manual use.
- Commit planner proposes groups, waits for architect approval, then creates commits.
- Review loop is capped at 2 rounds; escalates to `[BLOCKED]` after that.

**Next step:** Implement in order listed above.
