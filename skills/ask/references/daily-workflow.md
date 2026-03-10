---
title: "Daily Workflow"
parent: "User Stories"
nav_order: 1
permalink: /stories/daily-workflow/
---

# A Day in the Life: Daily Workflow with Claude Code

> **Level: 🌱 Beginner** | **Related:** [Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)

[← Back to References](intermediate/best-practices.md)

## The Scenario

You're a backend engineer working on a mid-sized web application. You've been using Claude Code for a few weeks now. Today is a typical workday — you have a bug to fix, a feature to implement, and a code review to finish. This story walks through how Claude Code fits into your day, from first terminal to last commit.

---

## The Walkthrough

### Morning: Starting Fresh

You open your terminal and launch Claude Code in your project directory.

```
cd ~/projects/my-app
claude
```

Claude reads your `CLAUDE.md` and knows the project — the tech stack, test commands, key conventions. You don't need to re-explain anything.

You start with the bug from yesterday's standup:

```
> There's a bug where users see a 500 error when updating their profile with a long bio. The error is in the profile update endpoint. Fix it.
```

Claude explores the codebase — finds the route handler, reads the validation logic, spots that the database column is `VARCHAR(255)` but there's no length check in the API layer. It adds validation, writes a test, runs the test suite, and confirms everything passes.

> **What's Happening:** Claude follows the [explore-plan-implement workflow](beginner/starting-to-work.md) automatically — it reads relevant files before making changes, then verifies its work by running tests. The [self-testing loop](intermediate/best-practices.md) catches issues before you even review the diff.

### Mid-Morning: Tackling a Feature

The bug was quick. Now you move on to the feature: adding rate limiting to the API.

This is a bigger task. You switch to Plan Mode first:

```
> /plan Add rate limiting to all public API endpoints. We want 100 requests per minute per API key, with a Redis-backed store.
```

Claude reads the relevant files — the middleware stack, the Redis configuration, existing rate limiting (there's a basic in-memory one for auth endpoints). It produces a plan: extend the existing middleware, add Redis backing, configure per-route limits, add tests.

You review the plan, tweak one detail ("use sliding window, not fixed window"), and let Claude implement.

> **What's Happening:** [Plan Mode](beginner/starting-to-work.md) lets you review Claude's approach before it writes code. This is especially valuable for larger changes where you want to shape the architecture.

### Before Lunch: Context Check

You've been working for a few hours. Claude has read dozens of files and produced several diffs. You notice responses are getting slightly slower — a sign the context window is filling up.

You check the context usage in the status bar. It's at ~60%. The rate limiting feature is done and committed. Time to clear:

```
> /clear
```

Fresh context. Claude will re-read `CLAUDE.md` when you start your next task, but all the file contents and conversation history from this morning are gone — exactly what you want.

> **What's Happening:** [Context management](intermediate/best-practices.md) is the single most important habit for effective Claude Code usage. The context window is finite, and performance degrades as it fills. Clearing between unrelated tasks keeps Claude sharp. You didn't lose anything — the code is committed.

### Afternoon: Code Review with Focus

After lunch, you need to review a teammate's PR. You pull the branch and ask Claude:

```
> Review the changes in this branch compared to main. Focus on error handling and SQL injection risks.
```

Claude diffs the branch against main, reads each changed file, and gives you a focused review. It flags one SQL query that uses string interpolation instead of parameterized queries — a real issue.

You don't need Claude to fix it (it's your teammate's PR), so you copy the feedback into the PR review.

> **What's Happening:** Claude can read and analyze code without modifying it. Using it for review gives you a second pair of eyes that never gets tired and checks methodically.

### Late Afternoon: Quick Tasks

The rest of your day is small tasks. You `/clear` between each one:

- "Add a `created_at` index to the `orders` table migration"
- "Update the README to document the new rate limiting headers"
- "Write a script that exports daily active users to CSV"

Each task takes a few minutes. Claude handles them in isolation, with a fresh context each time.

> **What's Happening:** `/clear` between tasks isn't just about context management — it prevents cross-contamination. Claude won't accidentally reference files from an earlier task or carry forward assumptions that don't apply.

### End of Day: Tomorrow's Agenda

Before you wrap up, you want to know what's coming tomorrow. You have a skill for this — `/plan-tomorrow` — that reads your project tracker and sends a summary to Slack:

```
> /plan-tomorrow
```

The skill has two scripts under the hood:

1. **Pull the backlog** — a script that queries Jira for your sprint tickets, assigned items, and upcoming deadlines, and returns them as structured data for Claude to summarize.
2. **Send to Slack** — a script that posts a message to a Slack webhook, which publishes it directly to you as a DM.

Claude runs the first script, reads the backlog data, drafts a concise agenda (top priorities, blockers, deadlines), then runs the second script to send it straight to your Slack. You glance at the message on your phone over dinner. Tomorrow morning, you'll open your terminal already knowing what to tackle first.

> **What's Happening:** This is a [skill](intermediate/skills.md) — a reusable prompt workflow saved as a Markdown file. The skill bundles two shell scripts: one to pull data in, one to push a message out. Claude orchestrates between them — reading the Jira output, summarizing it, and sending the result. You wrote the skill once; now it runs in seconds every evening.

---

## Key Takeaways

- **Clear between unrelated tasks.** This is the highest-leverage habit. Fresh context = better results.
- **Use Plan Mode for bigger features.** Review the approach before Claude writes code — it's cheaper to fix a plan than to fix an implementation.
- **Let Claude self-test.** Always ensure it can run tests or verify its own work. The feedback loop is what makes it reliable.
- **Automate your routine with skills.** Recurring tasks like planning tomorrow's agenda are perfect for skills — write the prompt once, run it in seconds every day.
- **Match the tool to the task.** Quick bug? Just ask. Big feature? Plan Mode. Code review? Read-only analysis. Claude adapts to what you need.
