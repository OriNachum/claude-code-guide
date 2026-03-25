---
title: "Migrating from Other AI Tools"
parent: "User Stories"
nav_order: 10
permalink: /stories/migrating-from-other-tools/
---

# Migrating from Other AI Tools

> **Level: 🌿 Intermediate**

You've been using Cursor, Windsurf, Copilot, Continue, Aider, Cody, or OpenAI Codex — and now you want to move to Claude Code. Here's how everything maps over, what to trim, and how to keep your context clean.

## The configuration map

Every AI coding assistant has its own config format, but they all solve the same problems. Here's where things land in Claude Code:

| Concept | Cursor | Windsurf | Copilot | Continue | Aider | Codex | Claude Code |
|---|---|---|---|---|---|---|---|
| Project instructions | `.cursorrules` | `.windsurfrules` | `.github/copilot-instructions.md` | `.continue/config.json` | `.aider.conf.yml` | `AGENTS.md` | `CLAUDE.md` |
| File-scoped rules | `.cursor/rules/*.md` | `.windsurf/rules/*.md` | — | `.continue/rules/*.md` | — | — | `.claude/rules/*.md` |
| MCP servers | `.cursor/mcp.json` | `.windsurf/mcp.json` | — | config.json `mcpServers` | — | `config.toml` MCP section | `.mcp.json` |
| Personal settings | `.cursor/settings.json` | — | — | — | — | `~/.codex/config.toml` | `.claude/settings.local.json` |
| Global instructions | — | — | — | — | — | `~/.codex/AGENTS.md` | `~/.claude/CLAUDE.md` |
| Ignore patterns | — | — | — | — | `.aiderignore` | — | No direct equivalent |

## Tool-by-tool notes

### Cursor

Cursor's `.cursorrules` is the closest equivalent to `CLAUDE.md`. The key differences:

- Cursor rules often contain instructions like "you are a helpful AI assistant" — drop these, Claude Code doesn't need them
- `.cursor/rules/*.md` files with file-scoped rules map to `.claude/rules/*.md` — preserve the `globs:` pattern (Cursor uses `path:`, Claude Code uses `globs:`)
- `.cursor/mcp.json` maps directly to `.mcp.json` — the format is nearly identical

### Windsurf

Very similar to Cursor:

- `.windsurfrules` → `CLAUDE.md`
- `.windsurf/rules/*.md` → `.claude/rules/*.md`
- `.windsurf/mcp.json` → `.mcp.json`

### GitHub Copilot

- `.github/copilot-instructions.md` → `CLAUDE.md` — usually shorter and more concise than Cursor rules, so less trimming needed
- Copilot doesn't have MCP support, so there's nothing to migrate there

### Continue

- `.continue/config.json` or `.continue/config.yaml` contains both rules and MCP configs
- Extract the `systemMessage` or custom instructions → `CLAUDE.md`
- Extract `mcpServers` section → `.mcp.json`
- `.continue/rules/*.md` → `.claude/rules/*.md`

### Aider

- `.aider.conf.yml` contains model preferences and behavior settings — most are not directly applicable (use `/model` and permission modes instead)
- `.aiderignore` has no direct Claude Code equivalent — note this in your migration summary

### OpenAI Codex CLI

Codex is the closest in architecture to Claude Code:

- `AGENTS.md` → `CLAUDE.md` (direct 1:1 equivalent — same purpose, same layering concept)
- `.codex/config.toml` model and sandbox settings → not applicable (use `/model` and permission modes)
- `.codex/config.toml` MCP servers → `.mcp.json`
- `~/.codex/AGENTS.md` (global instructions) → Consider putting global rules in `~/.claude/CLAUDE.md`
- `AGENTS.override.md`, `TEAM_GUIDE.md` — check for these Codex fallback filenames too

## What to trim and why

The biggest mistake in migration is copying everything verbatim. A 500-line `.cursorrules` file should not become a 500-line `CLAUDE.md`. Here's what to cut:

### Drop tool-specific instructions

Anything that addresses the AI tool by name ("as a Cursor AI", "when generating code in this IDE") is irrelevant in Claude Code. Drop it entirely.

### Drop inferable rules

If the project has `tsconfig.json`, Claude Code already knows it's TypeScript. If there's a `package.json`, it knows the dependencies. Rules like "this project uses React and TypeScript" are wasted context.

### Condense verbose rules

Many rule files are written as conversations rather than directives. Condense:

- Before: "When writing code, please always make sure to follow the established coding conventions in this project, including using consistent indentation and naming patterns"
- After: "Follow existing code conventions for indentation and naming"

### Deduplicate across sources

If you're migrating from both Cursor and Copilot, the same rules often appear in both. Keep each rule once.

### Target: ≤100 lines for CLAUDE.md

A good CLAUDE.md is concise. Prioritize:

1. Build and test commands
2. Architecture decisions and conventions
3. Project-specific rules that aren't obvious from the code
4. Tech stack details that affect code generation

Deprioritize:

1. Style preferences Claude can infer
2. Generic best practices ("write clean code")
3. Boilerplate instructions

## MCP migration

MCP (Model Context Protocol) servers need scope decisions:

- **Project scope** (`.mcp.json`): servers that any team member should use — database tools, project-specific APIs
- **Local scope** (`claude mcp add --scope local`): servers with personal tokens — personal Notion, personal Slack
- **User scope** (`claude mcp add --scope user`): general utilities you use everywhere — web search, file converters

Some MCP servers may need re-authentication in Claude Code. After migration, run the servers to verify they connect.

## Handling the transition period

You don't have to delete old configs immediately. It's fine to keep `.cursorrules` alongside `CLAUDE.md` for a while:

- The old configs won't interfere with Claude Code — it only reads its own config files
- You can compare results between tools during the transition
- When you're satisfied, clean up the old files at your own pace

## Using the migration skill

Run `/guide:migrate-to-claude` and the skill will:

1. Scan your project for configs from all supported tools
2. Analyze and classify each piece of content
3. Condense and deduplicate rules
4. Present a detailed migration plan with exact file contents
5. Wait for your review — you can adjust anything before applying
6. Execute the migration and show a summary of what changed

The migration is additive — it never deletes your original config files.
