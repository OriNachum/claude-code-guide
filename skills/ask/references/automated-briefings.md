---
title: "Automated Briefings"
parent: "User Stories"
nav_order: 9
permalink: /stories/automated-briefings/
---

# Production Monitoring with /loop

> **Level: 🌿 Intermediate** | **Related:** [Scheduled Tasks](https://docs.anthropic.com/en/docs/claude-code/scheduled-tasks)

[← Back to References](intermediate/loop.md)

## The Scenario

You're a developer with a busy day ahead: on-call in the morning, a major deploy in the afternoon. You'll use `/loop` across three monitoring patterns — on-call ticket triage, deploy health, and post-deploy validation — and discover the sub-agent upgrade path for context management along the way.

The emphasis: you're orchestrating agents and workflows, not writing application code. You set up skills, configure sub-agents, manage loops, and let Claude do the legwork while you make the decisions.

You have a **Slack notification webhook** configured — all loops post to Slack so you can monitor from your phone or stay focused on other work.

---

## The Walkthrough

### Step 1: Morning — On-Call Ticket Triage (Simple Loop)

You're on-call this morning. Instead of compulsively checking Jira, you create a simple skill:

```markdown
<!-- skills/ticket-triage/SKILL.md -->
---
description: Check for new on-call tickets and propose solutions
---

# Ticket Triage

1. Check Jira for new tickets assigned to me or the on-call queue
2. For each new ticket: read the description, check linked logs/errors
3. Propose a diagnosis and next steps
4. Post the summary to Slack
```

Start the loop:

```text
/loop 15m /ticket-triage
```

The first run executes immediately. From then on, every 15 minutes Claude checks for new tickets, reads the context, proposes solutions, and posts summaries to Slack. You review ticket summaries on your phone between other work. On-call goes from reactive interrupts to prepared, batch-processed triage.

> **What's Happening:** `/loop` at its most useful — not just polling for status, but actively preparing work. Claude reads each ticket, pulls context, and proposes a solution. You review and decide. The loop does the legwork; you make the calls.

### Step 2: The Context Problem

After a couple of hours, you notice the conversation is getting heavy. Each ticket-triage iteration dumps full Jira descriptions, log excerpts, and proposed solutions into the main context. You check `/tasks` — the loop is still running, but the context cost is adding up. Claude's responses are getting slower and a compaction warning appears.

The issue: the loop's output is too verbose for the main conversation.

> **What's Happening:** This is the key pain point with simple loops. Every iteration adds to the conversation context. When the loop does heavy work (reading tickets, fetching logs, analyzing errors), that output accumulates fast.

### Step 3: Upgrading to a Sub-Agent

You upgrade the ticket-triage skill to a **sub-agent** configured to use **Sonnet 4.6** for cost-efficient legwork:

```markdown
<!-- skills/ticket-triage/SKILL.md -->
---
description: Check for new on-call tickets and propose solutions
model: sonnet
allowed-tools: ["Bash", "WebFetch"]
---

# Ticket Triage

1. Check Jira for new tickets assigned to me or the on-call queue
2. For each new ticket: read the description, check linked logs/errors
3. Propose a diagnosis and next steps
4. Post the full analysis to Slack
5. Return ONLY a one-line summary to the main conversation (e.g., "3 new tickets, 1 critical — see Slack")
```

You restart the loop. Now each iteration spawns a Sonnet 4.6 sub-agent in its own context. The sub-agent does all the Jira fetching, log reading, and analysis — posts detailed results to Slack — and returns only a one-line summary to the main conversation (Opus 4.6). **The main context barely grows.**

> **What's Happening:** This is the **Loop + Sub Agent** pattern. Opus 4.6 acts as the manager — it fires on schedule and delegates to Sonnet 4.6, which does the heavy lifting in isolation. The sub-agent's full context (Jira data, log excerpts, analysis) stays in its own window and gets discarded when it returns. The main conversation only accumulates one-line summaries. Cheaper model for repetitive legwork, clean context for the orchestrator.

### Step 4: Afternoon — Deploy Monitoring

A major deploy is scheduled. You already know the sub-agent pattern, so you create a deploy-check agent skill from the start:

```markdown
<!-- skills/deploy-check/SKILL.md -->
---
description: Check deployment rollout status and report health
model: sonnet
allowed-tools: ["Bash", "WebFetch"]
---

# Deploy Check

1. Run `kubectl rollout status deployment/api --timeout=10s`
2. Run `kubectl get pods -l app=api --no-headers` — check for CrashLoopBackOff/Error
3. If migration is running, check `kubectl logs job/db-migration --tail=5`
4. Post detailed status to Slack (rollout progress, pod states, migration status)
5. Return one-line summary: "4/5 pods ready, migration 60% complete" or "2 pods in CrashLoopBackOff"
```

Start the loop:

```text
/loop 5m /deploy-check
```

You switch to **Explore mode** to design your next feature. Deploy status arrives on Slack; you glance at your phone. The main conversation stays clean — just one-line summaries from the sub-agent.

> **What's Happening:** You're not watching the terminal. You're designing a feature in Explore mode while the sub-agent monitors the deploy. This is the key shift — you orchestrate agents and workflows, not write code. `/loop` + sub-agents + Slack = hands-free production monitoring.

### Step 5: Set a One-Time Reminder

The migration is expected to take about 2 hours. You set a one-time reminder:

```text
remind me in 2 hours to check if the database migration completed and stop the deploy-check loop
```

This fires once at the specified time — no recurring cost, no context accumulation. It complements the deploy-check loop for time-boxed checkpoints.

> **What's Happening:** One-time reminders complement loops. They fire once for time-boxed checkpoints. See [Run prompts on a schedule](https://code.claude.com/docs/en/scheduled-tasks).

### Step 6: Post-Deploy Validation

The deploy completes. You stop the deploy-check loop and start a post-deploy monitor — same sub-agent pattern, now watching for regressions:

```text
/loop 10m /post-deploy-monitor
```

The `/post-deploy-monitor` skill (Sonnet 4.6 sub-agent) checks error rates, p99 latency, compares to baseline, posts details to Slack, and returns a one-line summary.

You head to lunch. Monitoring production from your phone — Slack pings arrive as the sub-agent checks in every 10 minutes. If something spikes, you'll know immediately. You're not at the terminal, but you're reachable.

> **What's Happening:** `/loop` doesn't require you to be at the terminal. Pair it with Slack + sub-agents and you can monitor from anywhere. The session stays alive on your machine; the notifications reach you wherever you are.

### Step 7: End of Day — Cleanup

Back from lunch, you check `/tasks` and stop the remaining loops. You review the day: three different monitoring patterns, all orchestrated from one session — on-call triage, deploy health, post-deploy validation. No YAML files written, no CI pipelines configured — just skills, sub-agents, and loops.

> **What's Happening:** Check `/tasks` regularly; stop loops when they've served their purpose. Context accumulates silently, and each iteration costs tokens. Active loop management is part of the workflow.

### Step 8: When /loop Isn't the Right Tool

If this monitoring should run overnight, on weekends, or without anyone's session open, that's [GitHub Actions](intermediate/github-actions.md) territory. `/loop` and CI serve different purposes: `/loop` is for when someone is reachable. CI is for when nobody needs to be.

---

## Key Takeaways

- **`/loop` is a session-scoped production companion** — deploy monitoring, post-deploy validation, on-call triage. It's the fastest way to set up temporary recurring monitoring — no config files, no deployment.
- **Pair with sub-agents to prevent context bloat.** Sonnet 4.6 does the legwork in isolation, Opus 4.6 orchestrates. The main conversation only sees one-line summaries.
- **Pair with Slack/Discord for phone-friendly monitoring.** You don't need to be at the terminal — the session stays alive on your machine, notifications reach you wherever you are.
- **The dev orchestrates, not implements.** Setting up skills, configuring sub-agents, managing loops — you're designing the automation, not writing application code.
- **Check `/tasks` regularly.** Stop loops when they've served their purpose. Context accumulates silently.
- **Know the hard limits.** Session-scoped, 3-day auto-expiry, no catch-up for missed fires. These aren't bugs — they keep `/loop` safe by default.
- **`/loop` and CI serve different purposes.** `/loop` for when you're reachable. [GitHub Actions](intermediate/github-actions.md) for when nobody needs to be.
