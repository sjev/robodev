# User stories

As an **architect** I want to:

## Workflow

- Define specs and plans before any code is written, so I can steer implementation rather than react to it.
- Follow a consistent phased workflow (spec → plan → implement → review), so I can validate and course-correct at each gate.
- Decompose work into small, scoped tasks, so agents produce reviewable, mergeable increments.

## Coding agents

- Use LLMs to handle implementation, so I can focus on architecture and trade-offs.
- Switch between tools like Claude Code and Copilot, so I'm not locked into a single provider.
- Use lighter models for simple tasks (commits, formatting), so I can control costs.


## Review and quality

- Have agent output reviewed by a different agent, so blind spots from the authoring agent get caught.
- Enforce atomic commits with clear messages, so the development history stays navigable.
- Define explicit boundaries for what agents must never touch, so critical code and config stay safe.

## Context and documentation

- Keep project context (CLAUDE.md, rules, skills) concise and modular, so agents get focused instructions without context bloat.
- Keep documents consistent, brief, and clear, so I can review them efficiently.
- Define prompts and skills as a single source of truth that works across Claude Code and Copilot, so I don't duplicate or drift instructions per tool.
