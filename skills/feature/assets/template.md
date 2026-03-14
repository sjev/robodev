# Design: [Feature Name]

Status: draft

## Summary
One paragraph: what this feature does and why.

## Scope
- **In scope:** [list]
- **Out of scope:** [list]

## Acceptance criteria
AC-01: ...
AC-02: ...

## Data model changes
New or modified entities, fields, and relationships. Mermaid ER diagram if schema changes are involved.

## Execution flow

### Happy path
Describe the primary success flow.

### Error paths
Describe the most important failure scenarios.

## API / interface changes
For each new or modified interface (function, endpoint, event):
- Signature with full types
- Input validation rules
- Return values and error codes

## Affected modules
Which modules from the architecture doc are touched, and how.

## Test plan

Derive test cases from acceptance criteria. Each AC should map to at least one test.
Focus on observable behavior, not implementation details.

| ID | AC | Test description | Given | When | Then |
|----|-----|-----------------|-------|------|------|
| T-01 | AC-01 | ... | ... | ... | ... |
| T-02 | AC-01 | ... (error path) | ... | ... | ... |
| T-03 | AC-02 | ... | ... | ... | ... |

### Boundaries

List what is NOT tested here and why (e.g., covered by integration tests, out of scope).

## Implementation notes
Patterns to follow, pitfalls to avoid, anything non-obvious.

## Open questions
Items that must be resolved before or during implementation.
