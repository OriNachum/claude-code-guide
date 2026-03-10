---
title: "Hooks"
parent: "Automation"
nav_order: 2
permalink: /hooks/
---

# Hooks

> **Level: 🌿 Intermediate** | **Source:** [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks), [Hooks Guide](https://docs.anthropic.com/en/docs/claude-code/hooks-guide)

[← Back to Automating Your Workflows](automating-your-workflows.md)

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They are your primary tool for creating **guardrails, validation, logging, and automated reactions** to what Claude does.

## When to Use Hooks

Think "hooks" when you catch yourself saying:

- "Every time Claude writes a file, I want to run the linter"
- "I need to block any shell command that includes `rm -rf`"
- "After Claude finishes, I want to check that all tests still pass"
- "When a session starts, I want to load context from my issue tracker"
- "I want to auto-approve safe tools but block dangerous ones"

Hooks are reactive — they fire in response to events, not in response to prompts.

## Key Concepts

**Lifecycle events** — Hooks fire at specific points: before a tool runs (`PreToolUse`), after a tool runs (`PostToolUse`), when Claude finishes responding (`Stop`), when a session starts (`SessionStart`), and many more.

**Matchers** — You can filter which tool or event triggers your hook. For example, a `PreToolUse` hook with matcher `"Bash"` only fires before shell commands, not before file reads.

**Hook handlers** — The actual code that runs. Can be a shell command (`type: "command"`), an HTTP POST (`type: "http"`), an LLM evaluation (`type: "prompt"`), or an agentic verifier (`type: "agent"`). See [HTTP Hooks](../expert/hooks-http.md) for a dedicated guide on HTTP endpoint handlers.

**Decision control** — Hooks can allow, deny, or escalate actions. A `PreToolUse` hook can block a tool call; a `Stop` hook can force Claude to keep working.

## Getting Started: Your First Hook

The simplest hook is a `PostToolUse` hook that auto-lints after file edits. Add this to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint --fix \"$(echo $CLAUDE_PROJECT_DIR)/**/*.ts\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

This fires after every `Write` or `Edit` tool call, running ESLint on your TypeScript files.

## Common Patterns

### Block dangerous commands

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-dangerous.sh"
          }
        ]
      }
    ]
  }
}
```

Where `block-dangerous.sh` reads stdin JSON, checks the command, and exits with code 2 to block:

```bash
#!/bin/bash
COMMAND=$(jq -r '.tool_input.command')
if echo "$COMMAND" | grep -qE 'rm -rf|DROP TABLE|format'; then
  echo "Blocked dangerous command" >&2
  exit 2
fi
exit 0
```

### Force Claude to continue until tests pass

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if all tasks are complete: $ARGUMENTS. Respond with {\"ok\": true} to allow stopping or {\"ok\": false, \"reason\": \"what's missing\"} to continue."
          }
        ]
      }
    ]
  }
}
```

### Inject context on session start

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"Current branch: $(git branch --show-current). Recent commits: $(git log --oneline -5)\""
          }
        ]
      }
    ]
  }
}
```

## Where Hooks Live

| Location | Scope |
|---|---|
| `~/.claude/settings.json` | All your projects |
| `.claude/settings.json` | This project only (committable) |
| `.claude/settings.local.json` | This project only (gitignored) |
| Managed policy settings | Organization-wide |
| Plugin `hooks/hooks.json` | When the plugin is enabled |
| Skill/agent frontmatter | While that component is active |

## 🌳 Available Events

| Event | When it fires | Can block? |
|---|---|---|
| `SessionStart` | Session begins or resumes | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PostToolUse` | After a tool call succeeds | No (tool already ran) |
| `PostToolUseFailure` | After a tool call fails | No |
| `Notification` | Claude sends a notification | No |
| `SubagentStart` | A subagent is spawned | No |
| `SubagentStop` | A subagent finishes | Yes |
| `Stop` | Claude finishes responding | Yes |
| `InstructionsLoaded` | CLAUDE.md/memory files loaded | No |
| `ConfigChange` | Settings file changes | Yes |
| `TeammateIdle` | A teammate has no pending tasks | Yes |
| `TaskCompleted` | A background task finishes | Yes |
| `WorktreeCreate` | A worktree is created | Yes |
| `WorktreeRemove` | A worktree is removed | No |
| `PreCompact` | Before context compaction | No |
| `SessionEnd` | Session terminates | No |

## Next Steps

- Use `/hooks` inside Claude Code to interactively manage hooks
- Run `claude --debug` to see hook execution details
- See the [official hooks reference](https://code.claude.com/docs/en/hooks) for full event schemas and advanced features
- See [HTTP Hooks](../expert/hooks-http.md) for a dedicated guide on HTTP endpoint handlers
- Return to [Automating Your Workflows](automating-your-workflows.md) to compare with Skills and Sub Agents
