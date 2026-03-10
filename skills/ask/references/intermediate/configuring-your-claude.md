---
title: "Configuring Your Claude"
parent: "Configuration & Extensions"
nav_order: 1
permalink: /configuring-your-claude/
---

# Configuring Your Claude

> **Level: 🌿 Intermediate** | **Source:** [Settings](https://docs.anthropic.com/en/docs/claude-code/settings), [Memory](https://docs.anthropic.com/en/docs/claude-code/memory)

[← Back to Automating Your Workflows](automating-your-workflows.md)

Your environment is set up (see [Setting Your Environment](../beginner/setting-your-environment.md) if you haven't done that yet). Now comes the part that never really ends: teaching Claude how to work the way *you* work.

This guide is about the mindset and rhythm of ongoing configuration — knowing *when* to reach for each tool and *how* your setup evolves over time. For the mechanics of each automation mechanism (syntax, config options, lifecycle events), see [Automating Your Workflows](automating-your-workflows.md) and the individual deep-dive pages linked there.

---

## Recognizing the Signals

The best configurations grow organically. Don't try to automate everything up front. Instead, watch for these signals during your daily work:

**"I keep explaining the same thing to Claude"** → Time to create a [Skill](skills.md). If you've told Claude the same convention, process, or checklist more than twice, write it down once as a skill so every future session has it.

**"I wish this would just happen automatically"** → Time to create a [Hook](hooks.md). If you find yourself manually linting, running tests, or checking output after Claude acts, automate that reaction.

**"This task generates too much noise"** → Time to create a [Sub Agent](../expert/sub-agents.md). If test output, log analysis, or code review diffs are flooding your main conversation, delegate to a specialist that returns only a summary.

**"My team keeps reinventing the same setup"** → Time to create a [Plugin](plugins.md). If your skills, agents, and hooks have stabilized, package them so others get everything with one install.

---

## How Configuration Evolves

Configuration isn't a one-time task. Here's what a typical progression looks like:

### Week 1–2: Foundations

You've done the initial setup from [Setting Your Environment](../beginner/setting-your-environment.md). You're working with Claude daily and noticing friction:

- You keep telling Claude about your test conventions → **Create your first skill** (e.g., a `write-tests` skill with your project's patterns)
- Files aren't linted after edits → **Create your first hook** (e.g., a PostToolUse hook that runs ESLint on Write|Edit)
- You install the LSP plugin for your language via `/plugin`

### Month 1–2: Specialization

Patterns are clearer now. You start building specialists:

- Code reviews produce verbose diffs → **Create a code-reviewer sub agent** that runs on Sonnet in an isolated context
- You add a deployment skill (`/deploy`), a PR summary skill, and a code review checklist skill
- You add a SessionStart hook that loads the current sprint's context
- A PreToolUse hook blocks dangerous commands (`rm -rf`, `DROP TABLE`)

### Month 3+: Maturity

Your automation works well. Now you focus on sharing and refining:

- Package your best skills, agents, and hooks into an **internal plugin** for your team
- New team members get your entire setup by running `/plugin`
- Add agents with persistent memory that learn your project's style over time (see [Auto Memory](../beginner/memory.md))
- Review and prune — remove skills that are no longer accurate, update hooks for new workflows

---

## 🌳 How the Pieces Work Together

The real power comes from combining mechanisms. Here are three examples of what a mature setup looks like:

### Automated code review pipeline

1. **Skill** (`/review`) defines what a code review should cover — your team's checklist
2. **Sub Agent** runs the review in isolated context, keeping verbose diffs out of your main conversation
3. **Hook** (PostToolUse) auto-lints every file Claude modifies
4. **Hook** (Stop) runs the test suite before Claude finishes, forcing it to continue if anything fails
5. **Plugin** packages all of the above for your team

### Safe database operations

1. **Sub Agent** provides read-only database access on Haiku
2. **Hook** (PreToolUse) validates every shell command, blocking anything that could modify production data
3. **Skill** (`/db-report`) provides templated queries for common reports
4. **Hook** (PostToolUse) logs all queries to an audit trail via HTTP webhook

### Onboarding a new developer

1. **CLAUDE.md** gives project context that every session loads ([Setting Your Environment](../beginner/setting-your-environment.md))
2. **Skills** make team conventions discoverable via `/`
3. **Sub Agents** provide pre-built specialists for code review, testing, and debugging
4. **Plugins** give one-command install of the entire team's automation
5. **Hooks** add guardrails that prevent common mistakes before they happen

---

## Keeping It Maintainable

**Don't over-automate early.** Let patterns emerge naturally before codifying them. A premature skill is worse than no skill — it adds context tokens to every session and may steer Claude in the wrong direction.

**Document your skills.** A skill's `description` field should be clear enough that both you and Claude understand when to use it. If Claude keeps triggering a skill at the wrong time, the description needs work.

**Test your hooks.** Run `claude --debug` to see hook execution in real time. A broken hook can silently block tool calls or inject bad context.

**Version your agents.** Since agents live in `.claude/agents/`, they're tracked by git. Use commit messages to explain changes so your team understands the evolution.

**Review on a rhythm.** Weekly: notice new patterns. Monthly: update stale configs. Quarterly: consider packaging into plugins.

---

## Next Steps

- See [Automating Your Workflows](automating-your-workflows.md) for the comparison of automation mechanisms and links to each deep dive
- See [Setting Your Environment](../beginner/setting-your-environment.md) for initial setup if you haven't done it yet
- See [Plugins](plugins.md) for packaging and sharing your configuration
- See [Ongoing Work](../expert/ongoing-work.md) for automated maintenance that keeps your configuration healthy
