---
title: "Introspective Development"
parent: "Automation"
nav_order: 8
permalink: /introspective-development/
---

# Introspective Development

> **Level: 🌳 Expert** | **Source:** [Claude Code Guide Plugin](https://github.com/OriNachum/claude-code-guide)

[← Back to Automating Your Workflows](../intermediate/automating-your-workflows.md)

Introspective Development is a paradigm where agents and humans examine their own work, their documentation, and their development environment — then act on what they find. The agent asks itself: **"How could I have done it better?"** and encodes the answer as durable improvements.

Documentation is code. NotebookLM is the compiler. Skills are the executable output.

## The Four Dimensions

### 1. Documentation Loop

Work produces documentation — CLAUDE.md updates, skill descriptions, changelogs. That documentation becomes context for the next session. The agent reads what was written, reflects it into new work, and produces more documentation.

```text
spec → plan → code → changelog → context for the next spec
```

This is **Natural Language Memory (NLM)** — agents use generated docs as durable memory across sessions. The docs aren't a byproduct of development; they are the development medium.

### 2. Self-Reflection

Examining what worked and what didn't:

- Did the session reveal misunderstandings or repeated corrections?
- Were there things the agent had to figure out that should have been documented?
- Did the user correct the agent's approach? That correction should become durable guidance.

Self-reflection feeds the improvement loop — observations become skills, hooks, or CLAUDE.md entries.

### 3. Active Documentation Review

After producing documentation, deliberately review it through different lenses:

- **Audio review** — feed docs into NotebookLM to generate podcast-style overviews, catch gaps and unclear explanations that aren't obvious when reading
- **AI conversations** — discuss docs with agents: "explain this back to me," "what's missing," "what would confuse a newcomer"
- **User-story demos** — write scenarios that walk through actual usage, revealing design gaps
- **Fix-forward cycle** — issues found flow back as tasks: bug fixes, doc rewrites, design improvements

This is the "documentation as code, NotebookLM as compiler" principle. If the compiled output (podcast, overview, summary) sounds wrong, the source docs need fixing.

### 4. Environment Self-Improvement

Working with agents reveals friction — tasks that take more effort than they should, patterns that repeat without automation, context that gets lost between sessions. Act on these observations:

- **Skills** — encode repeated workflows as slash commands
- **Hooks** — automate event-driven actions (post-tool, pre-commit, session-end)
- **MCP servers or agent skills** — wire external integrations for tools the agent needs
- **Sub-agents** — create specialists for tasks that benefit from dedicated context
- **CLAUDE.md updates** — capture hard-won project knowledge so future sessions start better
- **Scripts** — reduce cognitive complexity of common tasks

The loop: **work → notice friction → improve the environment → work better → notice new friction**.

## The Development Lifecycle

Introspective Development verifies that a project supports every phase of the development lifecycle:

| Phase | What "supported" means |
|---|---|
| **Plan** | Architecture docs exist, planning guidance in CLAUDE.md or a skill |
| **Implement** | Code is navigable — AGENT.md in key folders, conventions documented, scripts reduce complexity |
| **Test** | Test suite exists, CI runs it, agent knows how to invoke tests |
| **PR** | PR workflow documented or scripted — format, checks, reviewers |
| **Iterate** | Review feedback loop works — agent can read comments, fix, push |
| **Clear** | Agent knows how to clean up — compact history, archive, close |

Gaps in any phase create friction. Introspection finds those gaps and proposes fixes.

## Using the Introspect Skill

```text
/guide:introspect                    # Infers focus from context
/guide:introspect agent skills       # Focus on a specific area
/guide:introspect auto               # Enable auto-introspection after PRs
/guide:introspect remind             # Get reminders after PRs instead
/guide:introspect off                # Manual only
```

**Focus inference:**

- After recent work (plan completed, PR merged): focuses on that work
- On a clean project: asks "Cover the whole project?" for a full review
- With text: uses your text as the focus area

**The process:**

1. **Scan** — read project state (CLAUDE.md, skills, hooks, plugins, sub-agents, MCP/agent skills, scripts, tests, CI, linting, docs, git history)
2. **Analyze** — evaluate through the four dimensions
3. **Lifecycle check** — verify each phase is supported
4. **Report** — present findings in plan mode for your review
5. **Fix** — apply approved changes (create/update CLAUDE.md, AGENT.md, skill stubs, linting configs)

## Trigger Levels

Control whether introspection runs automatically:

| Level | Behavior |
|---|---|
| **off** (default) | You manually run `/guide:introspect` |
| **remind** | Agent reminds you after PR merge: "Want to introspect?" |
| **auto** | Agent runs introspection itself after PR merge |

Toggle with `/guide:introspect auto|remind|off` or natural language ("call it automatically", "stop running it by yourself").

The setting persists across plugin updates. After changing the trigger level, restart Claude Code for it to take effect.

## Origin

Introspective Development originated in the [Culture](https://github.com/OriNachum/culture) project as "Reflective Development" — a paradigm where agents develop by reflecting on real work, not by configuration. The concept evolved through several blog posts:

- **Workbench Development** — scoping agents to specific folders for reliable, isolated work
- **Agentic Folders** — placing AGENT.md in key directories so agents understand context per-folder
- **Code as Documentation** — skills as live, executable documentation that can't silently rot

The `/guide:introspect` skill packages these ideas into a practical tool any project can use.

## See Also

- [Hooks](../intermediate/hooks.md) — event-driven automation that introspection may suggest adding
- [Skills](../intermediate/skills.md) — the building blocks introspection creates
- [Sub Agents](sub-agents.md) — specialists introspection may recommend
- [Best Practices](../intermediate/best-practices.md) — patterns that reduce the friction introspection finds
