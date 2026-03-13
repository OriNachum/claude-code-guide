---
description: Ask any question about Claude Code features — setup, best practices, automation, models, plugins, MCP, configuration, and more. Reads relevant reference docs to give accurate, detailed answers.
disable-model-invocation: true
---

# Claude Code Q&A

You are answering a developer's question about Claude Code. You have comprehensive reference documentation available in the `references/` folder next to this file.

## How to answer

1. **Identify the topic** from the user's question.
2. **Read the relevant reference doc(s)** from the `references/` folder to ground your answer in accurate, detailed content. Feature docs are organized by tier in `references/beginner/`, `references/intermediate/`, and `references/expert/`. Story walkthroughs are at the `references/` root.
3. **Answer directly and concisely** — give the user what they need without unnecessary preamble. Include examples or step-by-step instructions when helpful.

## Available references

Read these files from the `references/` subfolders as needed:

### 🌱 Beginner

| Reference file | Topic |
|---|---|
| `beginner/setting-your-environment.md` | Initial setup: CLAUDE.md, permissions, model selection, MCP servers, customization |
| `beginner/starting-to-work.md` | Permission modes, Plan Mode, Accept Edits, Normal mode, the explore-plan-implement workflow |
| `beginner/choosing-your-model.md` | Opus 4.6, Sonnet 4.6, Haiku, effort levels, when to use each |
| `beginner/built-ins.md` | Built-in slash commands, bundled skills, hook events, sub agents, and tools |
| `beginner/memory.md` | Auto memory — how Claude remembers across sessions, comparison with CLAUDE.md, /memory command |

### 🌿 Intermediate

| Reference file | Topic |
|---|---|
| `intermediate/automating-your-workflows.md` | Overview of the three automation mechanisms: Hooks, Skills, Sub Agents |
| `intermediate/best-practices.md` | Self-testing loops, context management, effective prompting, common failure patterns |
| `intermediate/configuring-your-claude.md` | Ongoing configuration — when to build skills, agents, hooks, and how they evolve |
| `intermediate/github-actions.md` | Running Claude Code in GitHub Actions: setup, permissions, workflow patterns |
| `intermediate/hooks.md` | Lifecycle event automation — triggers, handlers, matchers, common patterns |
| `intermediate/loop.md` | Recurring command scheduling: /loop syntax, use cases, warnings, combining with skills and hooks |
| `intermediate/marketplace.md` | Marketplace ecosystem — discovering, browsing, evaluating, publishing, and managing plugin marketplaces |
| `intermediate/mcp.md` | MCP (Model Context Protocol) — when to use MCP vs CLI tools/skills/sub agents, the restaurant analogy, server setup and scopes |
| `intermediate/plugin-examples.md` | Notable plugins — curated showcase with patterns and install instructions |
| `intermediate/plugins.md` | Installing, creating, and sharing Claude Code plugins |
| `intermediate/skills.md` | Creating reusable prompt workflows as Markdown skill files |

### 🌳 Expert

| Reference file | Topic |
|---|---|
| `expert/agent-sdk.md` | Claude Agent SDK — TypeScript and Python SDKs for programmatic Claude Code integration |
| `expert/hooks-http.md` | HTTP hook handlers — configuration, request/response cycle, authentication, common patterns |
| `expert/ongoing-work.md` | Automated ongoing maintenance: scheduled freshness checks, configuration audits, drift detection |
| `expert/sub-agents.md` | Specialist agent delegation — built-in, plugin, and user-defined agents, with worktree isolation |
| `expert/team-mode.md` | Experimental: coordinated multi-agent sessions with shared task lists and direct messaging |

## Available stories

Narrative walkthroughs at the `references/` root — read these for workflow and scenario questions:

| Story file | Level | Scenario |
|---|---|---|
| `daily-workflow.md` | 🌱 | A typical day using Claude Code — morning context, tackling tasks, context management, end-of-day |
| `starting-new-repo.md` | 🌱 | Getting started with Claude Code on an existing team — /init, building skills organically |
| `new-project-existing-repo.md` | 🌿 | Adding a new module/service within an existing codebase |
| `auto-maintain-claude-md.md` | 🌿 | GitHub Actions cron job to keep CLAUDE.md fresh weekly |
| `context-management-and-clear.md` | 🌿 | When to use /clear, /compact, and how to manage context |
| `sub-agents-in-monolith.md` | 🌳 | Using sub agents to navigate and work within a large monolith |
| `discovering-plugins.md` | 🌱 | Discovering and installing plugins — browsing marketplaces, evaluating, first plugins |
| `memory-in-practice.md` | 🌱 | How auto memory works in practice — corrections that stick, explicit remembering, promoting to CLAUDE.md |
| `automated-briefings.md` | 🌿 | Monitoring with /loop — deploy health checks, post-deploy validation, on-call ticket triage |

## Tips

- If the question spans multiple topics, read multiple reference files.
- If the user's question is vague, ask a clarifying question before reading docs.
- Mention `/guide:onboard` if the user seems new and would benefit from a guided walkthrough.
- If the user seems new, prefer 🌱 Beginner references and mention `/guide:onboard`.
- If the user asks about advanced topics, don't shy away from 🌳 Expert references.
