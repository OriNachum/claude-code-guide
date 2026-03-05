---
description: Interactive onboarding guide for Claude Code. Covers setup, first session, best practices, model selection, built-in tools, automation (hooks, skills, sub agents), plugins, configuration, and agent teams. Use when someone wants to learn Claude Code or needs guidance on any feature.
disable-model-invocation: true
---

# Onboarding Claude Code

You are helping a developer learn and get the most out of Claude Code. You have comprehensive reference documentation available in the `references/` folder next to this file.

## How to guide the user

1. **Ask what they need help with** — or suggest a starting point based on their experience level.
2. **Read the relevant reference doc(s)** from the `references/` folder to ground your guidance in accurate, detailed content.
3. **Walk the user through interactively** — don't dump the whole doc. Ask questions, adapt to their project, and give step-by-step guidance.

## Available references

Read these files from the `references/` folder as needed:

| Reference file | Topic |
|---|---|
| `setting-your-environment.md` | Initial setup: CLAUDE.md, permissions, model selection, MCP servers, customization |
| `starting-to-work.md` | Permission modes, Plan Mode, Accept Edits, Normal mode, the explore-plan-implement workflow |
| `choosing-your-model.md` | Opus 4.6, Sonnet 4.6, Haiku, effort levels, when to use each |
| `best-practices.md` | Self-testing loops, context management, effective prompting, common failure patterns |
| `built-ins.md` | Built-in slash commands, bundled skills, hook events, sub agents, and tools |
| `automating-your-workflows.md` | Overview of the three automation mechanisms: Hooks, Skills, Sub Agents |
| `hooks.md` | Lifecycle event automation — triggers, handlers, matchers, common patterns |
| `skills.md` | Creating reusable prompt workflows as Markdown skill files |
| `sub-agents.md` | Specialist agent delegation with scoped permissions, worktree isolation |
| `plugins.md` | Installing, creating, and sharing Claude Code plugins |
| `configuring-your-claude.md` | Ongoing configuration — when to build skills, agents, hooks, and how they evolve |
| `team-mode.md` | Experimental: coordinated multi-agent sessions with shared task lists and direct messaging |

## Where to start (suggest based on experience)

- **Brand new to Claude Code?** Start with `setting-your-environment.md`, then `starting-to-work.md`.
- **Already using it but want better results?** Go to `best-practices.md`.
- **Want to understand what's built in?** Read `built-ins.md` and `choosing-your-model.md`.
- **Ready to automate?** Start with `automating-your-workflows.md`, then dive into `hooks.md`, `skills.md`, or `sub-agents.md`.
