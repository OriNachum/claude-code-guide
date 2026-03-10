---
title: "Auto Memory"
parent: "Getting Started"
nav_order: 5
permalink: /memory/
---

# Auto Memory

> **Level: 🌱 Beginner** | **Source:** [Memory](https://docs.anthropic.com/en/docs/claude-code/memory)

[← Back to Setting Your Environment](setting-your-environment.md)

Claude Code remembers things about your project across sessions — automatically. When you correct Claude, share a preference, or Claude discovers something useful, it saves a note so the same lesson doesn't need repeating.

This happens without any setup. Auto memory is on by default.

---

## How Claude Remembers: Two Systems

Claude Code has two complementary memory systems:

| Aspect | CLAUDE.md | Auto Memory |
|---|---|---|
| **Who writes it** | You (or `/init`) | Claude |
| **Contains** | Project instructions, conventions, rules | Observations, corrections, patterns Claude learned |
| **Where it lives** | `./CLAUDE.md` (in your repo) | `~/.claude/projects/<project>/memory/MEMORY.md` |
| **Shared with team?** | Yes (committed to git) | No (personal, outside repo) |
| **When it's read** | Every session | Every session |
| **How to edit** | Any text editor, or ask Claude | `/memory` command, or ask Claude |

**Analogy:** CLAUDE.md is the team onboarding document — shared instructions everyone follows. Auto memory is your personal notebook — things Claude learned from working specifically with you on this project.

---

## What Gets Saved

Claude saves things it learns during your sessions:

- **Build commands**: "This project uses `pnpm` not `npm`"
- **Debugging insights**: "The auth service needs Redis running locally"
- **Corrections you make**: "Use camelCase for variables, not snake_case"
- **Preferences**: "User prefers Vitest over Jest"
- **Patterns**: "API routes follow the `/api/v2/` prefix convention"
- **Environment details**: "Staging deploys require VPN connection"

### What a real MEMORY.md looks like

```markdown
# Project Memory

## Build & Test
- Uses pnpm, not npm
- Test command: pnpm vitest run
- Lint must pass before commits (pre-commit hook)

## Conventions
- camelCase for variables and functions
- PascalCase for React components
- API routes use /api/v2/ prefix

## Debugging
- Auth tests need Redis running: docker compose up redis
- E2E tests flaky on CI — retry once before investigating

## User Preferences
- Prefers concise commit messages (one line)
- Wants tests written alongside implementation, not after
```

---

## Where Memory Lives

Auto memory files are stored outside your project repository:

```text
~/.claude/projects/<project-hash>/memory/MEMORY.md
```

MEMORY.md is the entrypoint, but you can create additional **topic files** (e.g., `debugging.md`, `patterns.md`) in the same directory and link to them from MEMORY.md. This keeps the main file concise while preserving detailed notes in dedicated files.

> **200-line limit:** The first 200 lines of MEMORY.md are loaded at the start of every conversation. Content beyond line 200 is not loaded at session start — use topic files for detailed notes.

This means:

- **Memory is personal** — each developer has their own memory for each project
- **Memory stays out of git** — it won't clutter your repo or appear in diffs
- **Memory is per working tree** — all worktrees within the same git repo share one auto memory directory, but Claude's memories for project A don't leak into project B
- **Memory persists across sessions** — start a new conversation and Claude still knows

---

## Viewing and Editing Memory

### The /memory command

The quickest way to see what Claude has saved:

```text
/memory
```

This opens your memory files for viewing and editing. You can add, modify, or delete any entries.

### Ask Claude to remember something

Just tell Claude in natural language:

```text
"Remember that our staging API is at staging.example.com and requires the VPN"
```

```text
"Always use pnpm in this project, never npm"
```

Claude saves these to auto memory so future sessions have the information.

### Ask Claude to forget something

```text
"Forget about the Redis requirement — we switched to an in-memory cache"
```

```text
"Stop using snake_case — we changed to camelCase last week"
```

Claude removes or updates the relevant memory entry.

### Check what Claude knows

```text
"What do you remember about this project?"
```

```text
"What's in your memory about our test setup?"
```

Claude reads its memory and tells you what it has stored.

---

## 🌿 How Memory and CLAUDE.md Work Together

Auto memory and CLAUDE.md form a layered configuration system. Each layer has a role:

| Layer | Who it's for | What belongs there |
|---|---|---|
| **CLAUDE.md** | The whole team | Project conventions, build commands, architecture decisions |
| **CLAUDE.local.md** | You, for this project | Personal overrides, local environment quirks |
| **Auto memory** | You, learned by Claude | Corrections, patterns Claude discovered, things you told Claude to remember |

Claude reads all three every session. They complement each other:

- **CLAUDE.md** says "run `pnpm test` before committing" → the team standard
- **CLAUDE.local.md** says "I use port 3001 instead of 3000" → your local tweak
- **Auto memory** says "user prefers verbose test output with `--reporter=verbose`" → Claude learned this from you

### When to promote memory to CLAUDE.md

Watch for memory entries that should really be team knowledge:

- A convention that every developer should follow, not just you
- A build command or environment requirement that's project-wide
- An architectural decision that Claude should always know about

When you spot these, move them from auto memory into CLAUDE.md so the whole team benefits.

---

## 🌿 The Full Configuration Picture

Auto memory is one piece of Claude Code's layered configuration. Here's where everything fits:

| Source | Scope | Who writes | Shared? | Purpose |
|---|---|---|---|---|
| Managed settings | Organization | IT/admin | Enforced | Enterprise policy |
| CLAUDE.md | Project | You/team | Yes (git) | Project instructions |
| CLAUDE.local.md | Project | You | No | Personal project overrides |
| `.claude/settings.json` | Project | You/team | Yes (git) | Permissions, model, tools |
| `.claude/settings.local.json` | Project | You | No | Personal setting overrides |
| `~/.claude/settings.json` | Global | You | No | Your preferences, all projects |
| **Auto memory** | Project | Claude | No | Learned patterns and corrections |

Auto memory is unique in this list: it's the only layer that Claude writes. Everything else is configured by humans.

---

## Tips

- **Don't over-correct.** If Claude gets something wrong once, a quick correction in the conversation is fine. If it keeps getting the same thing wrong, *then* tell it to remember.

- **Review periodically.** Run `/memory` every few weeks. Remove entries that are outdated or no longer accurate. Stale memories can steer Claude in the wrong direction.

- **Use CLAUDE.md for team knowledge.** Auto memory is personal. If a convention matters for everyone on the team, put it in CLAUDE.md where it's versioned and shared.

- **Let Claude learn naturally.** You don't need to front-load everything into memory. Claude picks up patterns as you work together — corrections, preferences, and project details accumulate organically over time.

- **Memory has a size limit.** MEMORY.md is loaded into context every session. Keep it focused and concise, just like CLAUDE.md. If memory grows too large, prune entries that Claude could figure out on its own.

---

## Next Steps

- See [Setting Your Environment](setting-your-environment.md) for the full initial setup walkthrough
- See [Configuring Your Claude](../intermediate/configuring-your-claude.md) for how configuration evolves over time
- See [Sub Agents](../expert/sub-agents.md) for how sub agents interact with memory
- See the [official memory docs](https://code.claude.com/docs/en/memory) for the full reference
