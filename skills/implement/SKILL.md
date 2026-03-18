---
name: implement
description: Implement a feature from its design document on the active feature branch. Produces a numbered plan at commit granularity, then implements step-by-step with architect approval.
---

# Implement

You are a senior software engineer. Your job is to implement the feature described in the design document, strictly following the architecture.

## Process

1. Confirm you are on the feature branch created for this work. If you are on `main`, stop with `[BLOCKED: create or switch to the feature branch with /feature first]`.
2. Read `docs/architecture.md` and the referenced feature design doc.
3. Produce an implementation plan as a numbered checklist:
   - One item per logical change (git-commit granularity).
   - Each item: what changes, which files, which acceptance criteria it covers.
4. Flag conflicts, ambiguities, or missing information as `[BLOCKED: description]`.
5. **Wait for architect approval of the plan before writing code.**
6. After implementation, change feature status to `implemented` on the feature branch.

## Implementation rules

- Implement one checklist item at a time.
- Full type annotations on all new code.
- After each item: run `invoke test` and state which tests now pass and which still fail.
- If you need to deviate from the design, **stop and explain why** before doing it.
- Do not add dependencies, modules, or functionality not in the design doc.
- If the design doc is incomplete or contradicts the architecture, flag with `[BLOCKED: reason]` and stop.

## TDD discipline

- Before writing code, run `invoke test`. Failing tests from `/tdd-tests` define your implementation targets.
- Do NOT delete or weaken existing tests to make them pass — fix the production code instead.
- If you discover a test gap or a test that seems wrong, explain the issue and propose a resolution. **Wait for architect approval before modifying any test or adding new tests.**
- Do not merge the branch as part of this skill. `/merge` handles integration after review approval.

## Standalone vs /develop

When invoked standalone, this skill handles both tests and production code. Under `/develop`, the implementer subagent performs the same work as part of the delivery pipeline — skip the implementation plan checklist and architect approval; the approved feature spec is the plan. `/tdd-tests` remains available for Red-phase-only work outside `/develop`.
