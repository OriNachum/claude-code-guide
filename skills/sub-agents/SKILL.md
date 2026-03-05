---
description: Deep dive into Claude Code sub agents — specialist agents with their own tools, permissions, and focus. Includes worktree isolation for parallel work. Use when a developer wants to delegate specialized tasks.
---

# Sub Agents — Specialist Delegation

You are helping a developer create and use sub agents in Claude Code. In the IKEA analogy, sub agents are the packages plus a handyperson who builds it for you. They work independently, can run in parallel, and have their own expertise.

## What sub agents are

A sub agent is a focused Claude instance with its own system prompt, tool restrictions, and optionally its own model. Claude spawns them to handle specialized work — security reviews, test writing, documentation — without polluting the main session's context.

Sub agents are architecturally distinct from Agent Teams (which are separate full Claude instances). Sub agents are helpers within a single session.

## Creating a sub agent

Sub agents live in `.claude/agents/` as Markdown files:

```markdown
# Security Reviewer

You are a security-focused code reviewer. Analyze code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Data exposure risks
- Insecure dependencies

Only flag real issues with evidence. No false positives.
Output a structured report with severity levels.
```

Save as `.claude/agents/security-reviewer.md`.

## Using sub agents

Once created, sub agents appear in `/agents`. Claude can delegate to them automatically, or you can reference them explicitly:

```
Review the auth module using the security-reviewer agent.
```

## Worktree isolation

For tasks that modify files, sub agents can work in git worktrees — isolated copies of the codebase. This means:
- The sub agent's changes don't interfere with your main workspace
- Multiple sub agents can work in parallel on different tasks
- Changes can be reviewed before merging back

Worktrees are an **isolation layer**, not a separate mechanism. They work alongside both sub agents and Agent Teams.

## When to use sub agents vs other mechanisms

| Situation | Use |
|---|---|
| Specialized review with different criteria | Sub agent |
| Parallel tasks that modify different files | Sub agent + worktree |
| Auto-run something after every edit | Hook |
| Reusable workflow I invoke manually | Skill |
| Multiple independent Claude instances | Agent Teams (experimental) |

## Practical examples

Help the developer create a sub agent for their needs:

**Test writer:**
```markdown
# Test Writer
Write comprehensive tests for the code provided.
Follow the project's existing test patterns.
Use the project's test framework (check package.json).
Aim for edge cases, not just happy paths.
```

**Documentation generator:**
```markdown
# Doc Writer
Generate clear, concise documentation for the code provided.
Include: purpose, parameters, return values, examples.
Follow JSDoc/docstring conventions for the language.
```

## Related skills
- `/onboarding-claude-code:hooks` — automatic event-driven automation
- `/onboarding-claude-code:skills-guide` — reusable prompt workflows
- `/onboarding-claude-code:team-mode` — experimental multi-agent coordination
- `/onboarding-claude-code:automate` — overview of all three mechanisms
