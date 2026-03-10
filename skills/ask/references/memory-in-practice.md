---
title: "Memory in Practice"
parent: "User Stories"
nav_order: 8
permalink: /stories/memory-in-practice/
---

# Memory in Practice

> **Level: 🌱 Beginner** | **Related:** [Memory](https://docs.anthropic.com/en/docs/claude-code/memory)

[← Back to Auto Memory](beginner/memory.md) · [← Back to Setting Your Environment](beginner/setting-your-environment.md)

Sarah has been using Claude Code for a couple of weeks on a Node.js project. She has a CLAUDE.md, but keeps finding herself correcting Claude on the same things — the package manager, naming conventions, test patterns. She doesn't realize Claude has been learning from those corrections all along.

---

## Step 1: Claude Already Knows

Monday morning. Sarah opens a new session and asks Claude to add a utility function with tests.

Claude creates the function and runs the tests:

```text
pnpm vitest run src/utils/format-date.test.ts
```

Sarah pauses. She didn't tell Claude to use `pnpm` — her CLAUDE.md just says "run tests before committing." But last week, she'd corrected Claude: "Use pnpm, not npm." Claude remembered.

She also notices Claude used `camelCase` for the function name — another correction she made days ago. These small things used to require re-explaining every session. Now they just work.

---

## Step 2: Making a Correction That Sticks

Later that day, Claude generates an API handler and names the file `formatDate.handler.ts`.

Sarah corrects it: "We use kebab-case for filenames — it should be `format-date.handler.ts`."

Claude fixes the filename and saves the convention to memory. From now on, every session on this project will use kebab-case filenames without being told.

---

## Step 3: Explicitly Asking Claude to Remember

While debugging a deployment issue, Sarah discovers something that isn't in any docs: the staging environment requires a specific header (`X-Staging-Auth`) for API calls to work.

She tells Claude directly:

```text
Remember that staging API calls need the X-Staging-Auth header.
The value comes from the STAGING_TOKEN env var.
```

Claude saves this to memory. Next time she (or Claude) works on anything involving staging, the information is there — no digging through Slack threads or deployment docs.

---

## Step 4: Checking What Claude Knows

A few days later, Sarah is curious what Claude has accumulated. She runs:

```text
/memory
```

Her MEMORY.md looks like this:

```markdown
# Project Memory

## Build & Test
- Uses pnpm, not npm
- Test runner: vitest (not jest)
- Run pnpm vitest run for tests

## Conventions
- camelCase for variables and functions
- kebab-case for filenames
- API routes under /api/v2/

## Environment
- Staging API needs X-Staging-Auth header (from STAGING_TOKEN env var)
- Local dev requires Redis: docker compose up redis

## Preferences
- Prefers concise commit messages
- Wants test files co-located with source (not in separate __tests__ dir)
```

Some of these she told Claude explicitly. Others Claude picked up from corrections during normal work. All of them save her time every session.

---

## Step 5: Promoting Memory to CLAUDE.md

Sarah notices that the kebab-case filename convention and the `pnpm` requirement aren't just her preferences — they're team standards. But they're only in her personal auto memory, so other developers using Claude Code won't benefit.

She opens CLAUDE.md and adds:

```markdown
## Conventions
- Use kebab-case for filenames (e.g., format-date.handler.ts)
- Use pnpm for all package operations (not npm or yarn)
- Test files live alongside source files, not in __tests__/
```

Then she runs `/memory` and removes the now-redundant entries from her auto memory. The team-wide conventions live in CLAUDE.md (shared via git), while her personal notes (like the staging header quirk) stay in auto memory.

---

## Key Takeaways

- **Memory works automatically.** Claude saves corrections and patterns without you asking. You don't need to set anything up.
- **Memory is personal.** Your auto memory is yours alone — it doesn't affect teammates or other projects.
- **You can be explicit.** Tell Claude to remember (or forget) anything. It's not limited to things Claude discovers on its own.
- **Review periodically.** Run `/memory` every few weeks to prune outdated entries and spot things worth promoting.
- **Promote team knowledge.** When a memory entry applies to everyone, move it to CLAUDE.md so it's shared and versioned.
- **Memory complements CLAUDE.md.** CLAUDE.md is the team playbook. Auto memory is your personal notebook. Together they give Claude full context every session.
