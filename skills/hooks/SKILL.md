---
description: Deep dive into Claude Code hooks — lifecycle event automation that fires automatically on PreToolUse, PostToolUse, Notification, and more. Use when a developer wants to automate actions that should happen every time a specific event occurs.
---

# Hooks — Lifecycle Event Automation

You are helping a developer understand and create hooks in Claude Code. Hooks are the event system — things that happen automatically during Claude's work, regardless of whether the developer or a sub agent triggers them.

## The IKEA analogy

In the IKEA furniture assembly analogy: hooks are the events that happen during assembly — the package is opened, you pick up the screwdriver, you start a step, you finish a step. They fire regardless of who's building (you or the handyperson). They're not a separate role — they're moments in the process.

## Available hook events

Walk the developer through the lifecycle events they can hook into:

| Event | When it fires | Common use |
|---|---|---|
| `PreToolUse` | Before Claude uses a tool (Write, Edit, Bash, etc.) | Validation, blocking dangerous operations |
| `PostToolUse` | After Claude uses a tool | Linting, formatting, notifications |
| `Notification` | When Claude sends a notification | Custom alerts, logging |
| `Stop` | When Claude finishes a task | Cleanup, summary generation |
| `SubAgentStop` | When a sub agent finishes | Aggregating results |

## Creating a hook

Hooks live in `.claude/settings.json` (project-level) or `~/.claude/settings.json` (global):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint:fix $TOOL_INPUT_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

### Key parts:
- **Event** (`PostToolUse`) — when to fire
- **Matcher** (`Write|Edit`) — which tools trigger it (regex pattern)
- **Command** — what to run. Receives hook input as JSON on stdin.

## Practical examples

Help the developer pick a hook for their needs:

**Auto-format on save:**
```json
{
  "matcher": "Write|Edit",
  "hooks": [{ "type": "command", "command": "prettier --write $TOOL_INPUT_FILE_PATH" }]
}
```

**Auto-lint after edits:**
```json
{
  "matcher": "Write|Edit",
  "hooks": [{ "type": "command", "command": "eslint --fix $TOOL_INPUT_FILE_PATH" }]
}
```

**Block writes to protected files:**
```json
{
  "matcher": "Write",
  "hooks": [{
    "type": "command",
    "command": "jq -r '.tool_input.file_path' | grep -q 'config/production' && echo 'BLOCK: Cannot modify production config' && exit 1 || exit 0"
  }]
}
```

## Hooks vs skills vs sub agents

Hooks are automatic and event-driven — they fire without being asked. Skills are invoked deliberately by the developer. Sub agents are delegated to by Claude. Use hooks for things that should ALWAYS happen (lint on save, format on write). Use skills for things you choose to do.

## Start with one hook

Ask what they want to automate. Help them write and test a single hook. They can add more later.

## Related skills
- `/onboarding-claude-code:automate` — overview of all three mechanisms
- `/onboarding-claude-code:skills-guide` — creating reusable prompt workflows
- `/onboarding-claude-code:sub-agents` — delegating to specialist agents
- `/onboarding-claude-code:configure` — where hook config lives
