---
description: Show all available onboarding skills and suggest where to start based on experience level. Use when someone first installs the plugin or wants to see what's available.
disable-model-invocation: true
---

# Onboarding Claude Code — Skill Guide

Welcome! This plugin helps you learn and get the most out of Claude Code through interactive guided skills.

## Available skills

Here's what you can invoke:

| Skill | What it does | Best for |
|---|---|---|
| `/onboarding:setup` | Walk through environment configuration — CLAUDE.md, model selection, permissions, first verification | New projects, new machines, fresh setups |
| `/onboarding:first-session` | Guide your first real working session — explore→plan→code, course-correction, specificity | Developers who have Claude Code but haven't used it for real work |
| `/onboarding:best-practices` | Self-testing loops, context management, effective prompting, CLAUDE.md improvement | Anyone wanting better results from Claude Code |
| `/onboarding:choose-model` | Help pick the right Claude model and effort level for the task at hand | When unsure which model to use or optimizing cost vs quality |
| `/onboarding:built-ins` | Tour of built-in commands, tools, and capabilities available out of the box | Discovering what Claude Code can do natively |
| `/onboarding:automate` | The three automation mechanisms (Hooks, Skills, Sub Agents) with guidance on when to use each | Developers who find themselves repeating instructions |
| `/onboarding:hooks` | Deep dive into lifecycle event automation — triggers, handlers, and practical examples | Automating actions on file save, pre-commit, post-tool events |
| `/onboarding:skills-guide` | Creating reusable prompt workflows as Markdown skill files | Building team-shared or personal skill libraries |
| `/onboarding:sub-agents` | Delegating work to specialist agents with scoped permissions and focus areas | Breaking large tasks into parallel specialist work |
| `/onboarding:team-mode` | ⚠️ Experimental: Running multiple independent Claude instances coordinated via shared files | Large-scale parallel work (use with caution — experimental feature) |
| `/onboarding:plugins-guide` | Installing, creating, and sharing Claude Code plugins | Packaging skills for distribution or using community plugins |
| `/onboarding:configure` | Ongoing configuration — CLAUDE.md refinement, settings layers, building agent personality | Developers who want to improve how Claude works in their project |

## Where to start

**Brand new to Claude Code?** Start with `/onboarding:setup`, then `/onboarding:first-session`.

**Already using Claude Code but want better results?** Go straight to `/onboarding:best-practices`.

**Want to understand what's built in?** Try `/onboarding:built-ins` and `/onboarding:choose-model`.

**Ready to automate?** Jump to `/onboarding:automate`, then explore `/onboarding:hooks`, `/onboarding:skills-guide`, or `/onboarding:sub-agents`.
