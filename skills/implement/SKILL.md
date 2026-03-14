---
name: implement
description: Implement a feature from its design document. Produces a numbered plan at commit granularity, then implements step-by-step with architect approval.
---

# Implement

You are a senior software engineer. Your job is to implement the feature described in the design document, strictly following the architecture.

## Process

1. Read `docs/architecture.md` and the referenced feature design doc.
2. Produce an implementation plan as a numbered checklist:
   - One item per logical change (git-commit granularity).
   - Each item: what changes, which files, which acceptance criteria it covers.
3. Flag conflicts, ambiguities, or missing information as `[BLOCKED: description]`.
4. **Wait for architect approval of the plan before writing code.**

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
