# The architect's guide to agentic Claude Code

**The most effective agentic developers in 2025–2026 aren't writing more code — they're writing better specs, curating context, and reviewing at scale.** Claude Code's custom commands, Skills system, and CLAUDE.md hierarchy provide the infrastructure for disciplined AI-assisted development, while practitioners like Wes McKinney have demonstrated that multi-agent, adversarially-reviewed workflows outperform unstructured "vibe coding" by orders of magnitude. The emerging consensus is clear: the human stays in the architect seat, and the AI handles implementation under tight supervision. This report covers all four dimensions — custom commands, the Skills/CLAUDE.md system, McKinney's stack, and the architect-overseer model — as an integrated playbook.

---

## Claude Code custom commands turn workflows into one-liners

Custom slash commands are **Markdown files** stored in specific directories that Claude Code discovers and exposes as `/command-name` shortcuts. The filename (minus `.md`) becomes the command. A file at `.claude/commands/review.md` becomes `/review`. There are two scopes: **project commands** in `.claude/commands/` (version-controlled, shared with the team, labeled "(project)" in `/help`) and **personal commands** in `~/.claude/commands/` (available across all your projects, labeled "(user)"). Subdirectories work for organization — `.claude/commands/frontend/component.md` creates `/component` tagged "(project:frontend)" — but don't namespace the command name itself.

The file format supports YAML frontmatter between `---` markers at the top, followed by the prompt body in Markdown. Frontmatter fields include `description` (shown in `/help` and required for model-invoked use), `allowed-tools` (scoping which tools the command can use, e.g., `Bash(git add:*)`), `argument-hint` (autocomplete hints like `[filename] [priority]`), `model` (force a specific model like `claude-3-5-haiku-20241022` for cheap tasks), and `disable-model-invocation` (prevents Claude from calling the command autonomously).

Arguments use a `$ARGUMENTS` placeholder for the full argument string, or **positional placeholders** `$1`, `$2`, `$3` for structured input. For example:

```markdown
---
allowed-tools: Bash(git add:*), Bash(git commit:*)
argument-hint: [message]
description: Create a git commit
model: claude-3-5-haiku-20241022
---
Create a git commit with message: $ARGUMENTS
```

Two powerful advanced features stand out. **Bash execution** via `!` prefix runs shell commands before the prompt is sent — `!git diff HEAD` injects the current diff as context. **File references** via `@` prefix inline file contents — `@src/utils/helpers.js` pulls that file into the prompt. Together, these let you build rich, context-aware commands that gather dynamic information before Claude even starts thinking.

Claude Code also ships **~30 built-in commands** including `/init` (bootstraps a CLAUDE.md), `/compact` (compresses conversation), `/memory` (edits memory files), `/review` (code review), and `/context` (visualizes context usage). Two bundled multi-agent skills deserve special mention: **`/simplify`** spawns three parallel review agents to check recently changed files for quality issues, and **`/batch`** orchestrates large-scale changes across a codebase in parallel worktrees.

Best practices: start with your three most common workflows, always include `description` frontmatter, scope `allowed-tools` narrowly, use cheaper models for simple tasks like commits, and commit project commands to version control for team consistency.

---

## CLAUDE.md and Skills form a layered memory architecture

CLAUDE.md is Claude Code's **persistent memory system** — a Markdown file automatically loaded into the context window at every session start. But it's not a single file; it's a four-tier hierarchy with enterprise, user, project, and local scopes, all loaded automatically with more specific levels taking precedence.

| Scope | Location | Shared with |
|-------|----------|-------------|
| Enterprise policy | `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS) | All org users |
| User memory | `~/.claude/CLAUDE.md` | You, all projects |
| Project memory | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via git |
| Project local | `./CLAUDE.local.md` | You, this project only |

Claude Code **walks up the directory tree** from the current working directory, loading CLAUDE.md at each level. Subdirectory CLAUDE.md files load on demand when Claude reads files in those directories — a lazy-loading mechanism that keeps context lean. The `@path/to/file` import syntax lets you pull in additional files, with recursive imports supported up to **5 levels deep**. This enables modular architectures where the root CLAUDE.md stays under 200 lines while referencing detailed docs elsewhere.

For larger projects, `.claude/rules/` provides **topic-specific rule files** that are discovered recursively. Rules can be globally loaded or scoped to specific file patterns using `paths:` frontmatter — for instance, a rule with `paths: ["src/api/**/*.ts"]` only activates when Claude touches API files. This is the right place for path-specific conventions rather than cluttering the main CLAUDE.md.

### Skills are the formal evolution beyond commands

**Agent Skills are an official feature**, not a community convention. Anthropic has published an open standard at agentskills.io and maintains a reference repository at github.com/anthropics/skills. A skill is a **directory** containing a `SKILL.md` file plus optional supporting files (scripts, templates, reference docs), stored in `.claude/skills/skill-name/`. The critical difference from commands: skills support **automatic discovery** — Claude reads skill descriptions at startup (~50 tokens each) and autonomously invokes relevant skills based on context, without the user typing a command.

The `SKILL.md` frontmatter includes `name`, `description` (max 1024 chars, critical for auto-discovery), `allowed-tools`, and optional flags like `disable-model-invocation: true` (manual-only) or `user-invocable: false` (reference material Claude loads but users can't invoke). Skills support progressive disclosure: only metadata loads at startup; full instructions load on demand. This matters because **instruction-following quality degrades uniformly as context grows** — research shows Claude doesn't just ignore new instructions, it begins ignoring all of them, making conciseness essential.

The practical guidance for what goes where: **CLAUDE.md holds "nouns"** — project overview, architecture, build commands, domain terminology. **Skills and commands hold "verbs"** — specific workflows like deploy, review, test. **Rules hold path-scoped conventions.** **Auto memory** (stored in `~/.claude/projects/<project>/memory/`) is where Claude writes its own notes across sessions — build commands it discovered, debugging insights, architecture observations. The `/memory` command lets you inspect and edit all memory layers.

---

## Wes McKinney's agentic stack is architect-led and adversarially reviewed

Wes McKinney — creator of pandas, co-creator of Apache Arrow, currently Principal Architect at Posit — went from self-described AI skeptic to burning **over 10 billion tokens per month** across Claude Code, Codex, and Gemini. His transformation began when Claude Code launched in April 2025, which he compared to his original discovery of Python in 2007. His writings, particularly "The Mythical Agent-Month" (early 2026), have become essential reading for anyone structuring agentic workflows.

McKinney's core thesis revisits Fred Brooks: **coding agents dramatically reduce accidental complexity, but essential complexity — design, product scoping, taste — remains unchanged and is now the primary bottleneck.** He warns of the "agentic tar pit" where parallel Claude Code sessions and git worktrees "are engaged in combat with the code bloat and incidental complexity generated by their virtual colleagues." At ~100K lines of code, agents "begin to chase their own tails and contextually choke on the bloated codebases they have generated." This is, as he puts it, "technical debt on an unprecedented scale, accrued at machine speed."

His practical stack centers on a **multi-agent adversarial workflow**:

1. **Claude Code writes code and commits** — his primary implementation agent
2. **A different agent (typically Codex or Gemini) immediately reviews the commit** via roborev, his custom tool
3. **Review findings feed back into the Claude session**, which fixes issues and commits again
4. **The cycle repeats** until review passes

He built **roborev** (roborev.io) specifically for this — a continuous, non-invasive background code reviewer that hooks into git commits, runs automated reviews, and feeds findings back to agents for auto-fix. He's run over **3,000 reviews in three weeks** with it. The key insight: "Different agents have different perspectives. Claude made the code, so it's less likely to see its own bugs. But Gemini or Codex, reviewing the same work, spots patterns Claude missed."

McKinney explicitly rejects the term "vibe coding": "I don't describe the way I work now as 'vibe coding' as this sounds like a pejorative 'prompt and chill' way of building AI slop software projects." Instead, he frames the architect's role through Brooks's "chief surgeon" model: "The developers who thrive in this new agentic era won't be the ones who run the most parallel sessions or burn the most tokens. They'll be the ones who are able to hold their projects' conceptual models in their mind, who are shrewd about what to build and what to leave out, and exercise taste over the enormous volume of output."

On language choice, McKinney now favors **Go over Python for new agentic projects** because agents need fast write-build-test loops. Go's instant compilation, fast test suites, and static binaries create tighter feedback cycles than Python's slower test execution. "Python is so successful because it's good for humans. But in a world where agents are writing all of the code... the agents don't care about that."

His recommended reading for the agentic era: Martin Fowler's refactoring work, Bob Martin's Clean Code, and design patterns literature — "not because you'll implement them by hand, but because you need to explain them to agents and evaluate their suggestions." He argues that software development is becoming more like English literature: "We're gonna be studying software programs and understanding what makes them good so that we can explain better to our agents what we want."

---

## The architect-overseer model demands specs before code

The central principle across all practitioner accounts is identical: **front-load thinking, because execution is now cheap.** Anthropic's own best practices formalize this as the explore-plan-code-commit workflow:

1. **Explore**: Ask Claude to read files, images, and URLs — explicitly tell it not to write code yet
2. **Plan**: Ask Claude to make a plan; use `Shift+Tab` to enter Plan Mode (read-only); save the plan as a document
3. **Code**: Implement in small increments, verifying as you go
4. **Commit**: Create atomic commits with clear messages, update docs

"Steps 1–2 are crucial," Anthropic notes. "Without them, Claude tends to jump straight to coding a solution." This mirrors what every experienced practitioner reports: the failure mode is letting the AI skip the thinking phase.

### Spec-driven development is the dominant framework

GitHub's Spec Kit implements a **four-phase gated workflow: Specify → Plan → Tasks → Implement**, with human validation required between each phase. Thoughtworks describes this as separating "the design and implementation phases" with requirements formalized into Markdown files reviewed iteratively. The spec becomes the source of truth — when something doesn't make sense, you go back to the spec, not the code.

Effective specs cover six core areas identified from GitHub's analysis of 2,500+ agent configuration files: **commands** (full executable commands with flags), **testing** (framework, locations, coverage expectations), **project structure** (explicit directory layout), **code style** (real code snippets showing conventions), **git workflow** (branch naming, commit format, PR requirements), and **boundaries** (what the agent must never touch).

Boundaries deserve special emphasis. Addy Osmani recommends encoding three tiers directly into specs: **✅ Always** (run tests before commits, follow naming conventions), **⚠️ Ask first** (database schema changes, adding dependencies), and **🚫 Never** (commit secrets, edit vendor directories, modify CI config without approval).

### Commit discipline and review gates prevent drift

Small, atomic commits are non-negotiable. Osmani writes: "I commit early and often, even more than I would in normal hand-coding. After each small task, I'll make a git commit with a clear message... small commits with good messages essentially document the development process." The recommended pattern: create dedicated AI branches, run all AI commits through linting and human review, then squash into clean commits before merging. One fintech startup reported this approach **reduced AI-related bugs by 70%** in Q4 2025.

**Git worktrees** have emerged as the standard mechanism for parallel agent sessions. Spin up a fresh worktree for each feature, run independent Claude Code sessions without interference, and merge back through review gates. McKinney, Ronacher (Flask creator), and Anthropic all recommend this pattern.

### The expertise requirement is higher, not lower

Dave Kiss frames it precisely: "This requires *more* expertise, not less. You need to know the subject deeply enough to catch errors at 10x the volume." The architect's job becomes **supervision at scale** — reviewing what agents produce, redirecting when output is technically impressive but misses the point, questioning unnecessary abstraction layers, and recommending deletion over backward compatibility for code that should die.

The risks of abandoning this oversight are well-documented. A December 2025 benchmark of five vibe-coding tools across 15 applications found **69 vulnerabilities total**, including critical API authorization flaws. Studies show **34% of developers** report losing code comprehension after six months of heavy, undisciplined AI use. And a recurring horror story: agents that write tests and code simultaneously often produce tests that amount to `expect(true).to.be(true)` — circular validation that passes CI but verifies nothing.

---

## Conclusion: the emerging playbook

The agentic development playbook crystallizing across the ecosystem has five layers, each reinforcing the others. **First**, use CLAUDE.md and Skills to encode your project's architecture, conventions, and domain knowledge into persistent context that survives across sessions. Keep it lean — under 200 lines in the root file, with `@imports` and `.claude/rules/` for modularity. **Second**, define custom commands and Skills for your team's most common workflows — code review, commit, deploy, test — so these become one-keystroke operations with proper tool scoping. **Third**, adopt spec-first discipline: write the spec before any code, decompose into small tasks, and enforce human review gates between phases. **Fourth**, implement adversarial multi-agent review, as McKinney demonstrates with roborev — never let the agent that wrote the code be the only one reviewing it. **Fifth**, maintain commit discipline with atomic commits, dedicated AI branches, and squash-before-merge policies.

The thread connecting all of this is McKinney's riff on Brooks: the agents handle the accidental complexity, but the essential complexity — knowing what to build, recognizing when an abstraction is wrong, exercising taste — remains stubbornly, irreducibly human. The developers who thrive won't be the ones prompting hardest. They'll be the ones who hold the conceptual model in their head and know exactly when to say no.

## References

### Anthropic / Claude Code Official Docs
- [Slash Commands — Claude Code Docs](https://code.claude.com/docs/en/slash-commands)
- [Agent Skills — Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Manage Claude's Memory — Claude Code Docs](https://code.claude.com/docs/en/memory)
- [Claude Code: Best Practices for Agentic Coding — Anthropic Engineering](https://www.anthropic.com/engineering/claude-code-best-practices)

### Wes McKinney
- [The Mythical Agent-Month — wesmckinney.com](https://wesmckinney.com/blog/mythical-agent-month/)
- [Can LLMs give us AGI if they are bad at arithmetic? — wesmckinney.com](https://wesmckinney.com/blog/llms-arithmetic/)
- [Wes McKinney — Spicytakes](https://wesm.spicytakes.org/)
- [roborev — GitHub](https://github.com/wesm/roborev)

### Spec-Driven Development
- [Spec-Driven Development with AI — GitHub Blog](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [How to Write a Good Spec for AI Agents — Addy Osmani](https://addyosmani.com/blog/good-spec/)
- [My LLM Coding Workflow Going into 2026 — Addy Osmani](https://medium.com/@addyosmani/my-llm-coding-workflow-going-into-2026-52fe1681325e)
- [Spec-Driven Development — Thoughtworks / Medium](https://thoughtworks.medium.com/spec-driven-development-d85995a81387)
- [A Practical Guide to Spec-Driven Development — Zencoder Docs](https://docs.zencoder.ai/user-guides/tutorials/spec-driven-development-guide)

### Skills & CLAUDE.md Deep Dives
- [Inside Claude Code Skills: Structure, Prompts, Invocation — Mikhail Shilkov](https://mikhail.io/2025/10/claude-code-skills/)
- [Claude Agent Skills: A First Principles Deep Dive — Lee Hanchung](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [Claude Skills: The Controllability Problem — Emergent Minds](https://paddo.dev/blog/claude-skills-controllability-problem/)
- [How to Create Claude Code Skills — Usagebar](https://usagebar.com/blog/how-to-create-claude-code-skills)
- [How to Write a Good CLAUDE.md File — Builder.io](https://www.builder.io/blog/claude-md-guide)
- [Writing a Good CLAUDE.md — HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [CLAUDE.md — Steve Kinney](https://stevekinney.com/courses/ai-development/claude-dot-md)
- [disable-model-invocation in Slash Commands — DevelopersIO](https://dev.classmethod.jp/en/articles/disable-model-invocation-claude-code/)
- [What are Skills? — Claude Help Center](https://support.claude.com/en/articles/12512176-what-are-skills)

### Agentic Coding Practices & Oversight
- [Agentic Coding Recommendations — Armin Ronacher (pocoo)](https://lucumr.pocoo.org/2025/6/12/agentic-coding/)
- [The Shame Isn't Gone — Dave Kiss](https://davekiss.com/blog/agentic-coding/)
- [Your Complete Guide to Slash Commands in Claude Code — Eesel AI](https://www.eesel.ai/blog/slash-commands-claude-code)
- [Cooking with Claude Code: The Complete Guide — Sid Bharath](https://www.siddharthbharath.com/claude-code-the-complete-guide/)
- [Claude Code: Practical Best Practices for Agentic Coding — Habib Mrad / Medium](https://medium.com/@habib.mrad.83/claude-code-practical-best-practices-for-agentic-coding-2be1b62cfeff)
- [Python Was Built for Humans. AI Just Changed Everything — Rill Data](https://www.rilldata.com/blog/the-day-pythons-most-famous-developer-realized-agents-dont-care-about-readability)
- [Version Control with AI: Managing AI-Generated Commits and Diffs — Brics-econ](https://brics-econ.org/version-control-with-ai-managing-ai-generated-commits-and-diffs)
- [Output from Vibe Coding Tools Prone to Critical Security Flaws — CSO Online](https://www.csoonline.com/article/4116923/output-from-vibe-coding-tools-prone-to-critical-security-flaws-study-finds.html)
- [Ask HN: Do you have any evidence that agentic coding works? — Hacker News](https://news.ycombinator.com/item?id=46691243)
- [Free AI Code Review Tool for Git Commits — Roborev / Scriptbyai](https://www.scriptbyai.com/ai-code-review-git-commits/)
