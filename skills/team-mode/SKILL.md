---
description: Guide to Agent Teams — experimental multi-agent coordination where multiple separate Claude instances work in parallel. Use when someone wants to understand or try the team mode feature.
---

# Agent Teams (Experimental)

You are introducing a developer to Agent Teams — an experimental feature for running multiple Claude instances in parallel. Flag clearly that this is experimental and may change.

## What Agent Teams are

Agent Teams let you run multiple independent Claude Code instances that coordinate on a shared task. Each instance is a full Claude session with its own context, tools, and focus area.

This is architecturally different from sub agents:
- **Sub agents** = helpers within a single session. They share the parent's context window.
- **Agent Teams** = separate full Claude instances. Each has its own context, running in parallel.

## How it works

Agent Teams use git worktrees for isolation. Each team member gets its own worktree (a separate checkout of the repo), works independently, and changes are merged back.

### Starting a team session

```bash
claude --agent-teams
```

Or within a session, Claude can spawn team members when given a task that benefits from parallelism.

### How coordination works

1. A lead agent breaks a task into parallel sub-tasks
2. Each team member gets assigned to a sub-task in its own worktree
3. Team members work independently and in parallel
4. Results are merged back when complete

## When to use Agent Teams

Agent Teams shine when:
- A task has clearly separable, independent parts
- Parallel execution would save significant time
- Each part requires substantial context (more than a sub agent can handle)
- The parts don't have tight dependencies on each other

Examples:
- Implementing multiple independent API endpoints simultaneously
- Writing tests for different modules in parallel
- Migrating multiple services at once

## When NOT to use Agent Teams

- Tasks with tight sequential dependencies
- Small tasks where overhead exceeds benefit
- When you need tight control over each step
- When the codebase has heavy file conflicts between tasks

## Relationship to other mechanisms

Agent Teams are an **operational mode**, not a fourth automation mechanism. The three mechanisms remain:
- **Hooks** — automatic event-driven actions
- **Skills** — reusable prompt workflows
- **Sub Agents** — specialist helpers within a session

Agent Teams represent a way of *combining* these at scale — multiple full sessions, each potentially using hooks, skills, and sub agents internally.

## Related skills
- `/onboarding-claude-code:sub-agents` — specialist agents within a single session
- `/onboarding-claude-code:automate` — overview of the three core mechanisms
- `/onboarding-claude-code:best-practices` — context management matters even more with teams
