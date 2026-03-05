# Automating Your Workflows

You have different ways to automate your workflows using Claude Code. Each approach fits different needs — from reacting to tool events, to creating reusable prompts, to delegating entire tasks to specialized agents.

**Note:** Slash commands (like `/compact`, `/help`, and custom `/my-command`) are a subset of Skills. Built-in slash commands are covered in the [Built-ins](built-ins.md) page. Custom slash commands are simply Skills with a name you invoke via `/`.

---

## The Three Automation Mechanisms

| Aspect | [Hooks](hooks.md) | [Skills](skills.md) | [Sub Agents](sub-agents.md) |
|---|---|---|---|
| **What it is** | Shell commands, HTTP endpoints, or LLM prompts that run automatically at lifecycle events | Markdown instruction files Claude loads as reusable prompts/playbooks | Independent AI agents with their own context, tools, and permissions |
| **When to think about it** | You want to *react* to something Claude does (before/after tool use, session start/end, permission requests) | You want to *teach* Claude how to do something (coding conventions, deploy steps, review checklists) | You want Claude to *delegate* a self-contained task to a specialist (code review, debugging, data analysis) |
| **Trigger** | Automatic — fires on lifecycle events (PreToolUse, PostToolUse, Stop, etc.) | Manual (`/skill-name`) or automatic (Claude matches your request to the skill's description) | Automatic (Claude delegates based on description) or manual ("use the debugger agent") |
| **Runs where** | Your shell / an HTTP endpoint / a fast LLM call | Inline in the current conversation, or forked into a sub agent | In a separate context window with its own system prompt |
| **Can modify Claude's behavior?** | Yes — can block tool calls, deny permissions, inject context, force Claude to continue | Yes — provides instructions Claude follows; can restrict tools with `allowed-tools` | Yes — has its own tool restrictions, permission mode, model, and hooks |
| **Complexity** | Medium — requires writing shell scripts or configuring JSON | Low — write a Markdown file with optional YAML frontmatter | Medium — write a Markdown file with YAML config for tools, model, permissions |
| **Best for** | Guardrails, validation, logging, auto-formatting, CI integration | Reusable prompts, coding standards, deployment playbooks, code generation templates | Isolated research, parallel exploration, specialized reviews, high-output tasks |

---

## How to Start Thinking About Automation

Ask yourself these questions:

**"I want to enforce a rule every time Claude uses a tool"** → Use [Hooks](hooks.md). For example, block `rm -rf` commands, auto-lint after file writes, or validate SQL queries before execution.

**"I want Claude to follow a specific process when I ask"** → Use [Skills](skills.md). For example, create a `/deploy` skill with step-by-step deployment instructions, or an `/explain-code` skill that always includes diagrams and analogies.

**"I want Claude to hand off work to a focused specialist"** → Use [Sub Agents](sub-agents.md). For example, delegate code reviews to a read-only reviewer agent, or run tests in an isolated debugging agent.

**"I want to know what Claude Code ships with out of the box"** → See [Built-ins](built-ins.md) for all built-in slash commands, bundled skills, built-in hooks events, and built-in sub agents.

---

## Combining Them

These mechanisms work together. A typical mature setup might include:

- **Skills** that define your team's coding conventions and deployment process
- **Hooks** that auto-lint after every file edit and block dangerous commands
- **Sub Agents** that run parallel code reviews and test suites in isolation

Each page linked above walks you through how to get started, from zero to a working automation.

---

## All Documentation

### Getting Started
- [Setting Your Environment](setting-your-environment.md) — Initial setup: CLAUDE.md, permissions, model selection, MCP servers, and customization
- [Starting to Work](starting-to-work.md) — When to use Plan Mode, Accept Edits, and Normal mode
- [Choosing Your Model](choosing-your-model.md) — Opus 4.6, Sonnet 4.6, Haiku, and effort levels

### Automation Deep Dives
- [Hooks](hooks.md) — Lifecycle automation, guardrails, and validation
- [Skills](skills.md) — Reusable prompts, coding standards, and slash commands
- [Sub Agents](sub-agents.md) — Specialist assistants with isolated context
- [Built-ins](built-ins.md) — Everything Claude Code ships with out of the box

### Configuration & Extensions
- [Configuring Your Claude](configuring-your-claude.md) — Ongoing configuration: building skills, agents, hooks, and plugins over time
- [Plugins](plugins.md) — Installing, creating, and sharing plugin packages
