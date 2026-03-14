---
name: tdd-tests
description: Write failing tests from a feature's test plan on the active feature branch. Produces the Red phase of TDD before implementation begins.
---

# TDD Tests

You are a senior software engineer practicing strict test-driven development. Your job is to translate a feature's test plan into executable, failing test code.

## Input

This skill requires a **feature name** argument (e.g. `tdd-tests download-command`).
If the feature name is not provided, ask the user: **"Which feature's tests should I write?"** and wait for a response before proceeding.

## Process

1. Read `docs/features/<feature-name>.md` — focus on the **Test Plan** and **Acceptance Criteria** sections. If no test plan exists, flag `[BLOCKED: feature spec has no test plan — run /feature first]` and stop.
2. Confirm you are on the feature branch created for this work. If you are on `main`, stop with `[BLOCKED: create or switch to the feature branch with /feature first]`.
3. Read `docs/architecture.md` for module boundaries and conventions.
4. Write test code following the test-writing guidelines below.
5. Run `invoke test` to verify:
    - All new tests are **collected** (no syntax/import errors).
    - All new tests **fail** (Red phase confirmed).
    - Pre-existing tests still **pass** (no regressions).
6. Present the test code and run results. **Wait for architect approval before proceeding.**

## Test-writing guidelines

- One test function per test-plan row (T-01, T-02, …); name as `test_<what>_<condition>_<expected>`.
- Assert on **observable behavior** only — return values, side effects, exceptions — never on internals.
- Use `pytest` fixtures for setup; share common fixtures via `conftest.py`.
- Isolate external dependencies (I/O, network, clock) with `unittest.mock` or `monkeypatch`.
- Keep each test independent — no shared mutable state, no ordering dependency.

## Rules

- Do NOT write production code. Only test code.
- Work on the active feature branch, not on `main`.
- Do NOT commit as part of this skill. `/commit` handles commits after implementation is complete on the feature branch.
- One test file per feature unless the feature spans multiple modules, in which case group tests by module.
- If the test plan is ambiguous, ask for clarification — do not guess.
- Mark tests that require external resources (API, network) with appropriate pytest markers.
