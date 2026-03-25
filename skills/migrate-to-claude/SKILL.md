---
description: Migrate your AI coding assistant config (Cursor, Windsurf, Copilot, Continue, Aider, Cody, Codex) to Claude Code. Discovers existing configs, trims bloat, and proposes a clean migration plan.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
---

# Migrate to Claude Code

You are helping a developer migrate their AI coding assistant configuration to Claude Code. This is a multi-phase process: discover what they have, analyze it, propose a clean migration plan, and — only after approval — execute it.

**Key principle:** don't just copy configs verbatim. Condense, deduplicate, and restructure for Claude Code's strengths. Less is more — a clean CLAUDE.md beats a bloated one.

Branch on `$ARGUMENTS`:

## `help`

Present the available commands:

| Command | What it does |
|---|---|
| `/guide:migrate-to-claude` | Full migration: discover, analyze, plan, then pause for your approval |
| `/guide:migrate-to-claude scan` | Discovery only — report what was found, no plan |
| `/guide:migrate-to-claude apply` | Execute a previously presented migration plan |
| `/guide:migrate-to-claude help` | Show this help |

## `scan`

Run Phase 1 (Discovery) only. Present the discovery table and stop. Do not analyze or propose a plan.

## `apply`

Execute the migration plan that was previously presented in this conversation. If no plan was presented yet, tell the user to run `/guide:migrate-to-claude` first.

Re-read the discovered source files and apply the planned changes as described in Phase 4 (Execution) and Phase 5 (Summary) below.

## (empty arguments) — Full migration flow

Run all phases in order: Discovery → Analysis → Plan → pause for approval.

---

## Phase 1 — Discovery

Scan the project root for config files from other AI coding assistants. Use Glob for file detection, then Read to inspect contents.

### Paths to scan

| Tool | Paths |
|---|---|
| Cursor | `.cursorrules`, `.cursor/rules/*.md`, `.cursor/mcp.json`, `.cursor/settings.json` |
| Windsurf | `.windsurfrules`, `.windsurf/rules/*.md`, `.windsurf/mcp.json` |
| Copilot | `.github/copilot-instructions.md`, `.github/copilot-chat.yml` |
| Continue | `.continue/config.json`, `.continue/config.yaml`, `.continue/rules/*.md` |
| Cody | `.cody/cody.json`, `cody.json` |
| Aider | `.aider.conf.yml`, `.aiderignore` |
| Codex (OpenAI) | `AGENTS.md`, `.codex/config.toml`, `.codex/AGENTS.md` |
| Existing Claude Code | `CLAUDE.md`, `CLAUDE.local.md`, `.claude/settings.json`, `.claude/settings.local.json`, `.mcp.json` |

Also check for `AGENTS.override.md` and `TEAM_GUIDE.md` at the project root (Codex fallback filenames).

### Discovery output

Present a formatted discovery table:

```text
+=======================================================+
|  DISCOVERY RESULTS                                    |
+=======================================================+
|  Tool           Files Found  Total Lines              |
|  -------------- ------------ -----------              |
|  Cursor         3            287                      |
|  Copilot        1            42                       |
|  Codex          1            65                       |
|  Claude Code    1 (existing) 28                       |
+=======================================================+
|  Tools not found: Windsurf, Continue, Cody, Aider    |
+=======================================================+
```

If no config files are found from any AI tool (excluding existing Claude Code configs), tell the user:

> No AI coding assistant configs found in this project. If you have configs elsewhere, copy them into the project root and try again. Or use `/guide:onboard` to set up Claude Code from scratch.

Then stop.

---

## Phase 2 — Analysis

Read each discovered file. Classify every piece of content into one of these categories:

| Content type | Claude Code target |
|---|---|
| Project instructions, coding rules, conventions | `CLAUDE.md` (append if exists, create if not) |
| File-scoped rules (e.g., "for *.tsx files…") | `.claude/rules/<name>.md` with `globs:` frontmatter |
| MCP server configurations | `.mcp.json` (project scope) or `claude mcp add` command (local/user scope) |
| Permission or safety rules | `.claude/settings.json` `permissions.allow` / `permissions.deny` |
| Personal preferences (editor style, name) | `CLAUDE.local.md` (personal — remind user to add to `.gitignore`) |
| Codex AGENTS.md content | `CLAUDE.md` (direct 1:1 equivalent) |
| Codex config.toml MCP servers | `.mcp.json` or `claude mcp add` (same as other MCP sources) |
| Ignored file patterns (.aiderignore) | Note only — no direct equivalent in Claude Code |
| Tool-specific settings (model, temperature, sandbox) | Note only — use `/model` and permission modes instead |
| Tool-specific instructions ("when using Cursor…") | Drop entirely |

### Condensation heuristics

Apply these rules to keep the migrated config clean:

1. **Trim boilerplate** — If a source file is over 200 lines, extract only the actionable rules. Drop introductions, explanations of what the tool is, and filler text.
2. **Deduplicate** — If the same rule appears in multiple source files (e.g., "use TypeScript" in both .cursorrules and copilot-instructions), keep it once.
3. **Drop tool-specific instructions** — Anything like "when using Cursor", "in this IDE", "as a Copilot assistant" — drop entirely with a note.
4. **Drop inferable rules** — If the project has `tsconfig.json`, don't migrate "this is a TypeScript project." If it has `package.json`, don't migrate "this uses npm." Note what was dropped and why.
5. **Condense verbose rules** — "When writing code, please always make sure to use descriptive variable names that clearly convey the purpose of the variable" → "Use descriptive variable names."
6. **Separate personal from project** — Personal preferences (name, style) go to `CLAUDE.local.md`, not `CLAUDE.md`.
7. **Target ≤100 lines** — The CLAUDE.md additions should be concise. If the condensed result exceeds 100 lines, aggressively prioritize: keep build commands, conventions, and architecture notes; trim style preferences and obvious rules.

### MCP scope heuristics

For each MCP server discovered in source configs:

- **Project-specific** (database URLs, project APIs, project-specific tools) → `.mcp.json` at project root (project scope)
- **Personal tokens** (has API keys, personal OAuth tokens) → suggest `claude mcp add --scope local` command
- **General utilities** (used across all projects) → suggest `claude mcp add --scope user` command

### Handling existing Claude Code config

If the project already has `CLAUDE.md` or `.mcp.json`:

- **CLAUDE.md exists**: propose APPENDING new rules below existing content, under a `## Migrated Rules` heading. Never overwrite existing content.
- **`.mcp.json` exists**: propose MERGING new servers into the existing file. Flag any duplicate server names.
- **`.claude/settings.json` exists**: note existing permissions; propose additions only, never removals.

---

## Phase 3 — Plan presentation

Present the complete migration plan in a structured format. Show BOTH the summary table AND the full proposed content of each file.

### Summary table

```text
+=======================================================+
|  MIGRATION PLAN                                       |
|  Sources: <tools>  |  Target: Claude Code             |
+=======================================================+
|                                                       |
|  CLAUDE.md (CREATE / APPEND)                          |
|  ─────────────────────────────────────────            |
|  + <description of added content> (N lines)           |
|  - TRIMMED: <what was dropped and why>                |
|                                                       |
|  .mcp.json (CREATE / MERGE)                           |
|  ─────────────────────────────────────────            |
|  + <server-name> (<scope>)                            |
|  ~ <server-name> (local scope — needs manual add)     |
|                                                       |
|  .claude/rules/<name>.md (CREATE)                     |
|  ─────────────────────────────────────────            |
|  + File-scoped rules for <glob pattern>               |
|                                                       |
|  CLAUDE.local.md (CREATE)                             |
|  ─────────────────────────────────────────            |
|  + Personal preferences extracted from <source>       |
|                                                       |
|  SKIPPED (not applicable to Claude Code)              |
|  ─────────────────────────────────────────            |
|  · <item> — <reason>                                  |
|                                                       |
+=======================================================+
|  N rules migrated | N lines trimmed | N servers added |
|  Say "apply" or run /guide:migrate-to-claude apply    |
+=======================================================+
```

### Full proposed content

After the summary table, show the **exact content** that will be written to each file, with any sensitive values **redacted**:

- For new files: show the full file content in a fenced code block
- For appended files (e.g., CLAUDE.md): show only the new lines to be appended, with a note like "Appended below existing content at line N"
- For merged files (e.g., .mcp.json): show the full merged result
- **Never** display or write raw secrets (API keys, access tokens, passwords) — replace with placeholders like `<YOUR_API_KEY>` and suggest `claude mcp add` with user-provided auth instead

### Trimming report

After the proposed content, show what was trimmed:

```text
Trimmed from migration:
  · 45 lines of boilerplate introductions (from .cursorrules)
  · 12 lines of Cursor-specific instructions (dropped — not applicable)
  · "This is a TypeScript project" (inferable from tsconfig.json)
  · 3 duplicate rules consolidated into 1
```

### STOP HERE

**Do NOT proceed to execution.** Present the plan and tell the user:

> Review the plan above. You can ask me to adjust anything — add, remove, or rephrase rules before applying. When you're satisfied, say **"apply"** or run `/guide:migrate-to-claude apply` to execute.

---

## Phase 4 — Execution

Only run after the user explicitly confirms (says "apply", "yes", "go ahead", "do it", or runs `/guide:migrate-to-claude apply`).

For each planned change:

1. **New files**: Use Write to create them
2. **Appending to CLAUDE.md**: Use Edit to append below existing content
3. **Merging .mcp.json**: Read existing file, merge new servers, Write the result
4. **File-scoped rules**: Create `.claude/rules/` directory if needed, then Write each rule file
5. **Local/user MCP servers**: Output the `claude mcp add` commands for the user to run manually (cannot run these on behalf of the user)

**Never delete original source config files.** The migration is purely additive. The user can clean up old files themselves when they're ready.

---

## Phase 5 — Summary

After execution, present a final summary:

```text
+=======================================================+
|  MIGRATION COMPLETE                                   |
+=======================================================+
|  Created / Modified:                                  |
|    <file> .............. <description>                |
|    <file> .............. <description>                |
|                                                       |
|  Trimmed (from originals):                            |
|    <N> lines of boilerplate                           |
|    <N> lines of tool-specific instructions            |
|    <N> duplicate rules consolidated                   |
|                                                       |
|  Manual steps needed:                                 |
|    · <action needed, if any>                          |
|                                                       |
|  Original configs preserved — nothing was deleted.    |
|  Tip: /guide:onboard for a full Claude Code intro     |
+=======================================================+
```

Include:

- Every file created or modified, with line counts
- What was trimmed and why (grouped by reason)
- Any manual steps the user needs to take (MCP auth, reviewing CLAUDE.local.md)
- Reminder that original configs are preserved
- Pointer to `/guide:onboard` if the user is new to Claude Code
