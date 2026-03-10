---
title: "Context Management"
parent: "User Stories"
nav_order: 5
permalink: /stories/context-management-and-clear/
---

# Mastering Context: When to /clear, /compact, and Manage Your Window

> **Level: 🌿 Intermediate** | **Related:** [Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)

[← Back to References](intermediate/best-practices.md)

## The Scenario

You're working on a complex feature and Claude's responses are getting slower and less focused. You've been in the same session for a while — reading files, running tests, iterating on code. Something feels off, but you're not sure whether to clear, compact, or push through. This story walks through context management as a deliberate practice, not an afterthought.

---

## The Walkthrough

### Understanding the Constraint

Think about how you work through a long day. After hours of deep focus on one problem, you need to clear your head before switching to something new. You grab a coffee, take a walk, maybe jot down where you left off — then you sit down fresh and ready for the next thing. Without that reset, everything bleeds together: you're still mentally in the last task, your focus is split, and your work suffers.

Claude works the same way. Its context window is like working memory — finite, and **everything counts**. Every file Claude reads, every command output, every message you send, every response Claude generates — it all accumulates. When the context fills up:

- Claude starts losing track of earlier parts of the conversation
- Responses become less focused and more generic
- Claude may "hallucinate" details from files it can no longer fully see
- Tool calls become less precise

Just like you wouldn't try to hold ten tasks in your head at once, Claude works best when it can focus on what's in front of it. The tools below — `/clear`, `/compact`, and a few patterns — are how you help Claude change gears between tasks, get a refresher when things get hazy, and make room for the work that matters right now.

> **What's Happening:** The [best practices guide](intermediate/best-practices.md) identifies context management as the single most important factor in Claude Code effectiveness. Every technique below serves this principle.

### Scenario 1: The Natural Breakpoint (/clear)

You've just finished implementing and testing a new API endpoint. Tests pass, code is committed. Now you need to refactor a completely unrelated utility module.

```
> /clear
```

This is the simplest and most powerful context management tool. `/clear` wipes the entire conversation history. Claude starts fresh — it'll re-read your `CLAUDE.md` on the next interaction, but everything else is gone.

**When to /clear:**
- Between unrelated tasks (different features, different parts of the codebase)
- After committing a completed piece of work
- When you notice Claude referencing stale information from earlier in the conversation
- At the start of your workday, even if you left a session open

**The cost of /clear:** Zero, if you've committed your work. Claude doesn't maintain state between sessions anyway — it rebuilds context from `CLAUDE.md` and the files it reads. The only thing you "lose" is conversation history, which was consuming context you need for the next task.

> **What's Happening:** `/clear` is a [built-in command](beginner/built-ins.md) that resets the conversation. It's the most common context management technique because most tasks are naturally independent.

### Scenario 2: The Long Task (/compact)

You're in the middle of a complex refactoring — you've been working through a chain of 12 files that all need coordinated changes. You're on file 8. Clearing would lose all the context about files 1-7 and the overall plan. But the context window is getting full.

```
> /compact
```

`/compact` takes your entire conversation history, creates a summary, and **replaces** the old context with that summary. The old messages are gone — but the key information is preserved in condensed form. This is different from `/clear`, which gives you a totally blank slate. After compacting, Claude has a fresh context window with just the summary preloaded.

**When to /compact:**
- Mid-task when context is filling but you're not done
- During long refactors that span many files
- At natural breakpoints within a larger task — don't wait for auto-compact

**About auto-compact:** Auto-compact kicks in when the context window approaches its limit, but it tends to fire at the worst possible moment — mid-thought, mid-implementation. It's much better to compact manually at natural breakpoints than to let it trigger randomly.

**The tradeoff:** After compacting, specific code snippets and verbose details are gone — only summaries remain. Claude will remember "we decided to use the factory pattern for the service layer" but might not have the exact code from earlier. If you need precise code after compacting, re-read the files.

**Directing what gets preserved:** You can pass a message to `/compact` to control what's kept:

```
> /compact preserve the coding patterns we established and the migration strategy
```

This tells the compaction process what to prioritize in the summary. Use it to anchor the specific decisions and context that matter for your next steps.

### Scenario 3: The Sprawling Investigation

You're debugging a production issue. You've been reading logs, tracing code paths, checking configuration files, and running diagnostic commands. The context is full of output from 15 different files and 10 command results. You've identified the root cause but haven't started fixing it yet.

This is the worst case for context management — you need the knowledge you've built up, but the raw data is consuming all your space. This is exactly what `/compact` is for:

```
> /compact preserve the root cause analysis, affected files, and the fix we identified
```

Claude summarizes everything — the root cause, the affected files, the planned fix — and replaces the bloated context with that condensed summary. All the raw log output, the dozen file reads, the command results — gone. But the conclusions you reached are preserved and ready to act on.

Now you continue in the same session with a clean context:

```
> Now implement the fix based on what we found.
```

Claude has the summary from the investigation and full context capacity for the implementation.

> **What's Happening:** `/compact` shines in investigation-to-implementation transitions. The investigation phase is read-heavy and fills context fast, but the implementation phase needs room to work. Compacting at the transition point preserves your findings while freeing up space. Use the `/compact [message]` syntax to direct what gets kept — especially important when the investigation touched many files but only a few matter for the fix.

### Scenario 4: Proactive Prevention

The best context management is proactive. Here are habits that keep you from hitting context limits:

**Be specific about what to read.** Instead of:
```
> Look at the src/ directory and understand the architecture
```

Try:
```
> Read src/services/payment-service.ts and src/routes/payments.ts — I need to modify the refund logic
```

The first prompt might cause Claude to read dozens of files. The second reads exactly what's needed.

**Keep command output focused.** Instead of:
```
> Run the full test suite
```

When you only changed one module:
```
> Run the tests in tests/payments/
```

Full test suite output can consume enormous context. Targeted test runs give you the same signal with a fraction of the context.

**Commit frequently.** Every commit is a safe point where you can `/clear` without anxiety. If you go an hour without committing, you're accumulating context debt.

---

## Key Takeaways

- **/clear is your default tool.** Use it between tasks, after commits, and whenever you switch context. It's free if your work is saved.
- **/compact summarizes and replaces.** It clears the old context but preserves key info as a summary. Use `/compact [message]` to direct what gets kept. Compact manually at natural breakpoints — don't wait for auto-compact.
- **Compact at phase transitions.** When switching from investigation to implementation, `/compact` preserves your findings while freeing context for the actual work.
- **Prevent context bloat proactively.** Be specific in what you ask Claude to read and run. Every unnecessary file read or verbose output is context you'll miss later.
- **Commit frequently.** Commits are save points that make `/clear` safe. The more often you commit, the more freely you can manage context.
