---
title: "Built-ins"
parent: "Configuration & Extensions"
nav_order: 6
permalink: /built-ins/
---

# Built-ins

> **Level: 🌱 Beginner** | **Source:** [CLI Reference](https://docs.anthropic.com/en/docs/claude-code/cli-reference), [Features](https://docs.anthropic.com/en/docs/claude-code/features-overview)

[← Back to Automating Your Workflows](../intermediate/automating-your-workflows.md)

Claude Code ships with built-in slash commands, bundled skills, hook events, and built-in sub agents out of the box. This page is a reference for everything available without any custom configuration.

## Built-in Slash Commands

Type `/` in Claude Code to see all available commands. Some commands depend on your platform, plan, or environment. Here are the key categories:

### Session Management

| Command | Purpose |
|---|---|
| `/clear` | Clear conversation history and free up context (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus instructions |
| `/resume [session]` | Resume a conversation by ID or name (alias: `/continue`) |
| `/fork [name]` | Fork the current conversation at this point |
| `/export [filename]` | Export conversation as plain text |
| `/rename [name]` | Rename the current session |
| `/rewind` | Rewind conversation/code to a previous point (alias: `/checkpoint`) |

### Configuration & Status

| Command | Purpose |
|---|---|
| `/config` | Open the Settings interface (alias: `/settings`) |
| `/model [model]` | Select or change the AI model |
| `/permissions` | View or update permissions (alias: `/allowed-tools`) |
| `/status` | Show version, model, account, and connectivity |
| `/context` | Visualize current context usage as a colored grid |
| `/cost` | Show token usage statistics |
| `/usage` | Show plan usage limits and rate limit status |
| `/doctor` | Diagnose and verify your Claude Code installation |
| `/fast [on\|off]` | Toggle fast mode on or off |

### Tools & Integrations

| Command | Purpose |
|---|---|
| `/hooks` | Manage hook configurations for tool events |
| `/agents` | Manage agent configurations |
| `/mcp` | Manage MCP server connections |
| `/memory` | View and edit [auto memory](memory.md) files |
| `/init` | Initialize project with CLAUDE.md guide |
| `/ide` | Manage IDE integrations |
| `/plugin` | Manage Claude Code plugins |
| `/skills` | List available skills |

### 🌿 Git & Code Review

| Command | Purpose |
|---|---|
| `/diff` | Interactive diff viewer for uncommitted changes and per-turn diffs |
| `/review` | Review a pull request for quality, correctness, security, and test coverage |
| `/pr-comments [PR]` | Fetch and display comments from a GitHub PR |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/install-github-app` | Set up the Claude GitHub Actions app |

### Session Features

| Command | Purpose |
|---|---|
| `/desktop` | Continue session in Claude Code Desktop app (alias: `/app`) |
| `/vim` | Toggle between Vim and Normal editing modes |
| `/theme` | Change the color theme |
| `/terminal-setup` | Configure terminal keybindings |
| `/statusline` | Configure status line |
| `/output-style [style]` | Switch output styles (standard, explanatory, learning) |
| `/plan` | Enter plan mode directly from the prompt |
| `/tasks` | List and manage background tasks |
| `/loop [interval] [command]` | Run a prompt or command on a recurring interval (default: 10 minutes) |
| `/keybindings` | Open keybindings configuration file |
| `/stats` | Visualize daily usage, session history, streaks |
| `/insights` | Generate a report analyzing your sessions |

### Account & Meta

| Command | Purpose |
|---|---|
| `/login` | Sign in to your Anthropic account |
| `/logout` | Sign out |
| `/upgrade` | Open the upgrade page |
| `/help` | Show help and available commands |
| `/feedback [report]` | Submit feedback (alias: `/bug`) |
| `/release-notes` | View the full changelog |
| `/privacy-settings` | View and update privacy settings |
| `/copy` | Copy the last assistant response to clipboard |
| `/exit` | Exit the CLI (alias: `/quit`) |

## 🌿 Bundled Skills

Bundled skills ship with Claude Code and are available in every session. Unlike slash commands which execute fixed logic, bundled skills are prompt-based playbooks that use Claude's tools.

| Skill | What it does |
|---|---|
| `/simplify` | Reviews your recently changed files for code reuse, quality, and efficiency issues, then fixes them. Spawns three review agents in parallel. Run after implementing a feature or bug fix. |
| `/batch <instruction>` | Orchestrates large-scale changes across a codebase in parallel. Decomposes work into 5-30 independent units, spawns one agent per unit in isolated git worktrees, each opens a PR. Requires a git repo. |
| `/debug [description]` | Troubleshoots your current session by reading the session debug log. Optionally describe the issue to focus analysis. |

There is also a bundled **developer platform skill** that activates automatically when your code imports the Anthropic SDK — no manual invocation needed.

## 🌿 Built-in Hook Events

Claude Code provides these lifecycle events that you can hook into. No hooks are configured by default — you add them yourself — but these are the events available:

| Event | When it fires | Can block? |
|---|---|---|
| `SessionStart` | Session begins or resumes | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PostToolUse` | After a tool call succeeds | No |
| `PostToolUseFailure` | After a tool call fails | No |
| `Notification` | Claude sends a notification | No |
| `SubagentStart` | A subagent is spawned | No |
| `SubagentStop` | A subagent finishes | Yes |
| `Stop` | Claude finishes responding | Yes |
| `TeammateIdle` | Agent team teammate goes idle | Yes |
| `TaskCompleted` | Task is marked as completed | Yes |
| `ConfigChange` | Configuration file changes | Yes (except policy) |
| `WorktreeCreate` | Worktree is being created | Yes |
| `WorktreeRemove` | Worktree is being removed | No |
| `PreCompact` | Before context compaction | No |
| `SessionEnd` | Session terminates | No |

Hook handlers can be shell commands (`type: "command"`), HTTP endpoints (`type: "http"`), LLM prompts (`type: "prompt"`), or agentic verifiers (`type: "agent"`).

See [Hooks](../intermediate/hooks.md) for how to get started, or the [official hooks reference](https://code.claude.com/docs/en/hooks) for full schemas.

## 🌳 Built-in Sub Agents

Claude Code includes built-in sub agents that Claude automatically uses when appropriate:

| Agent | Model | Tools | Purpose |
|---|---|---|---|
| **Explore** | Haiku (fast) | Read-only | File discovery, code search, codebase exploration. Claude delegates when it needs to search or understand a codebase without changes. |
| **Plan** | Inherits | Read-only | Codebase research for planning. Used during plan mode to gather context before presenting a plan. |
| **General-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications. Used when a task requires both exploration and action. |
| **Bash** | Inherits | Bash | Running terminal commands in a separate context. |
| **Claude Code Guide** | Haiku | Read-only | Answers questions about Claude Code features. |

These agents are used automatically. You don't need to configure them, but you can override them with custom agents of the same name, or disable them via permissions:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(Plan)"]
  }
}
```

See [Sub Agents](../expert/sub-agents.md) for how to create your own custom agents.

## Built-in Tools

Claude Code has access to these internal tools (used by both the main conversation and sub agents):

| Tool | What it does |
|---|---|
| `Bash` | Execute shell commands |
| `Read` | Read file contents |
| `Write` | Create or overwrite a file |
| `Edit` | Replace a string in an existing file |
| `Glob` | Find files matching a pattern |
| `Grep` | Search file contents with regex |
| `WebFetch` | Fetch and process web content |
| `WebSearch` | Search the web |
| `Agent` | Spawn a sub agent |
| `Skill` | Invoke a skill |

MCP servers can add additional tools with the naming pattern `mcp__<server>__<tool>`.

## Quick Reference Shortcuts

| Prefix | What it does |
|---|---|
| `/` | Invoke a command or skill |
| `!` | Run a bash command directly (bash mode) |
| `@` | File path mention with autocomplete |

## Next Steps

- Type `/` to explore all available commands in your environment
- Run `/doctor` to verify your installation
- Run `/init` to set up CLAUDE.md for your project
- Return to [Automating Your Workflows](../intermediate/automating-your-workflows.md) to learn about custom automation
