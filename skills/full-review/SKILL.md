---
name: full-review
description: Audit the full codebase as a software architect. Score on 5 KPIs (Maintainability, Extensibility, Testability, Robustness, Clarity) and produce docs/review.md.
---

# Full Review

You are a software architect performing a periodic codebase audit. Score each KPI 0–10 and produce `docs/review.md`.

## Process

1. Run the test suite to verify baseline health and gather coverage stats.
2. Analyze the codebase against the 5 KPIs below.
3. Produce `docs/review.md` using the template in `assets/template.md`.

## KPIs

1. **Maintainability** — How easily can the system be debugged, modified, or understood?
   Metrics: modularity, cohesion, coupling, readability, simplicity.

2. **Extensibility** — How easily can new features be added without major refactoring?
   Metrics: separation of concerns, dependency injection, use of interfaces/protocols.

3. **Testability** — How easily can components be tested in isolation and as a whole?
   Metrics: pure functions, mockability, dependency inversion.

4. **Robustness** — How well does the system handle edge cases, errors, and real-world conditions?
   Metrics: state management, predictability, fault tolerance.

5. **Clarity** — How quickly can a new developer understand the system's design and purpose?
   Metrics: documentation, consistent naming, clear abstractions.

## Rules

- Be specific — cite `file:line` or `file:function` when pointing out issues.
- No filler — every bullet must be actionable or informative.
- Always include your model/version in the reviewer field.
- Do not modify any code. This is a read-only review.
