---
description: Overview of Claude Code's three automation mechanisms — Hooks, Skills, and Sub Agents — with the IKEA analogy and guidance on when to use each. Use when a developer wants to stop repeating themselves.
disable-model-invocation: true
---

# Automating Your Workflows

You are helping a developer understand how to automate repetitive work in Claude Code. Start by asking what they find themselves repeating, then guide them to the right mechanism.

## The IKEA analogy

Think of a task as assembling IKEA furniture:

**Hooks** are events that happen during assembly — the package is opened, you pick up the screwdriver, you start a step, you finish a step. They fire automatically regardless of who's building (you or a handyperson). In Claude Code, hooks fire on lifecycle events like `PreToolUse`, `PostToolUse`, `Notification`, etc.

**Skills** are the packages you get — the instruction sheet, all the parts, and the specific tools needed. They're reusable bundles of prompts and tool configurations. You (the developer) still do the assembly step by step. In Claude Code, skills are Markdown files that Claude follows when invoked.

**Sub Agents** are the packages plus a handyperson who builds it for you. They're specialist agents with their own tools, permissions, and focus area. They can work independently and even in parallel (using worktrees for isolation). You delegate and they deliver.

## When to use each

Ask the developer what they're trying to automate, then guide them:

| I want to... | Use |
|---|---|
| Auto-format files after every edit | **Hook** (PostToolUse on Write/Edit) |
| Run lint on save | **Hook** (PostToolUse on Write) |
| Have a reusable code review checklist | **Skill** (`/review`) |
| Create a deployment workflow I can invoke | **Skill** (`/deploy`) |
| Delegate security review to a specialist | **Sub Agent** (security-reviewer) |
| Run tests in isolation while I keep working | **Sub Agent** with worktree |
| Have multiple specialists work in parallel | **Agent Teams** (experimental) |

## Creating each one

### Hooks
Hooks live in `.claude/settings.json` or `.claude/settings.local.json`:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{ "type": "command", "command": "npm run lint:fix $TOOL_INPUT_FILE_PATH" }]
    }]
  }
}
```

### Skills
Skills live in `.claude/skills/` as folders with a `SKILL.md`:
```
.claude/skills/review/SKILL.md
```
Invoke with `/review`. Claude reads the SKILL.md and follows its instructions.

### Sub Agents
Agents live in `.claude/agents/` as Markdown files:
```
.claude/agents/security-reviewer.md
```
They appear in `/agents` and have their own system prompt, tool restrictions, and model.

## Combining them

The real power comes from combining mechanisms:
- A **skill** that invokes a **sub agent** for specialized work
- A **hook** that triggers after a sub agent finishes
- A **skill** that orchestrates multiple sub agents

For experimental multi-agent coordination across separate Claude instances, explore Agent Teams (`claude --agent-teams`).

## Start small

Help the developer identify ONE thing to automate right now. Walk them through creating it. They can always add more later.

## Related skills
- `/onboarding:best-practices` — effective patterns before automating
- `/onboarding:configure` — where automation config lives
- `/onboarding:setup` — initial setup if not done yet
