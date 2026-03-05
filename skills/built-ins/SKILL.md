---
description: Tour of Claude Code's built-in commands, tools, and capabilities — what's available out of the box before any customization. Use when someone wants to know what Claude Code can do natively.
---

# Built-in Commands and Tools

You are giving a developer a tour of what Claude Code ships with out of the box — no plugins, no custom config needed.

## Essential commands

Walk them through the key slash commands:

### Session management
- `/help` — show all available commands
- `/compact` — compress conversation to free context. Can add a focus: `/compact Focus on the API changes`
- `/clear` — clear conversation and start fresh
- `/rewind` — restore previous conversation and code state

### Configuration
- `/model` — switch models (Opus, Sonnet, Haiku)
- `/config` — open settings
- `/permissions` — manage tool permissions

### Mode switching
- `Shift+Tab` — toggle Plan Mode (read-only exploration)
- `/review` — built-in code review

### Tools and integration
- `/mcp` — manage MCP server connections
- `/plugin` — browse and install plugins
- `/agents` — list available sub agents

## Built-in tools Claude can use

Claude Code has tools it can use without any configuration:

**File operations** — read, write, edit files. Claude asks permission in Normal mode.

**Shell commands** — run terminal commands, see output, react to errors.

**Search** — grep through codebases, find files, search for patterns.

**Web fetch** — retrieve documentation or API references from URLs.

**Sub agent delegation** — spin up focused sub agents for parallel tasks.

## What Claude reads automatically

At session start, Claude reads:
- **CLAUDE.md** files — project root, parent directories, and `~/.claude/CLAUDE.md`
- **Project structure** — file tree to understand the codebase layout
- **Git context** — current branch, recent changes, status

## Built-in skills vs custom skills

Claude comes with some built-in capabilities (like code review). Custom skills you create in `.claude/skills/` extend these with your own workflows. Slash commands (like `/review`) are actually a subset of the skills system.

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Shift+Tab` | Toggle Plan Mode |
| `Esc` | Stop current action |
| `Esc + Esc` | Open rewind menu |
| `Up arrow` | Recall previous message |

## Related skills
- `/onboarding-claude-code:setup` — initial setup that determines what's available
- `/onboarding-claude-code:automate` — extend built-ins with hooks, skills, and sub agents
- `/onboarding-claude-code:plugins-guide` — add more capabilities via plugins
