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

### The IKEA Analogy

Think of it like buying furniture from IKEA:

**Skills** are the flat-pack bundle you get — the instruction sheet plus all the parts and tools. Everything you need is in the box, but *you* (Claude in your main conversation) still have to follow the steps and assemble it yourself, one piece at a time.

**Sub Agents** are the flat-pack bundle *plus a handyperson* who takes it to another room and builds it for you. You hand off the box, they do the work in their own space, and come back with the finished piece. Need three bookshelves? They can build them in parallel while you focus on something else.

**Hooks** are things that happen at specific moments during assembly — whether you're building it yourself or the handyperson is. When you open the package, when you pick up the screwdriver, when you start a new step, when you finish. You can attach rules to any of these moments: "every time someone picks up the screwdriver, check that the bit is correct", "when the package is opened, verify all parts are present", "when assembly finishes, inspect the result." Hooks fire the same way regardless of who's doing the building.

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

Back to the IKEA analogy: your skills are the instruction manuals your team has written for every type of furniture. Your sub agents are the handypersons who can work from those manuals independently. And your hooks are the checkpoints built into the workshop itself — every time anyone picks up a tool, opens a package, or finishes a build, the same checks fire automatically.

Each page linked above walks you through how to get started, from zero to a working automation.

### Taking it further: Agent Teams (experimental)

[Agent teams](team-mode.md) take this combination to the next level. Instead of one Claude session orchestrating skills, hooks, and sub agents, you get multiple full Claude instances — each with access to all your skills and hooks — working together with a shared task list and direct communication. One teammate can run your `/review` skill while another implements a fix, with hooks firing on both, and the teammates can discuss findings with each other without going through you.

Agent teams are still experimental, but they point to where this is heading: your skills define the playbooks, your hooks enforce the rules, and agent teams provide the workforce — all coordinating autonomously. See [Agent Teams](team-mode.md) for details.

---

## Packaging with Plugins

[Plugins](plugins.md) aren't a fourth automation mechanism — they're the packaging layer that sits on top of the three. A plugin is a bundle that can contain any combination of skills, sub agents, hooks, and MCP servers, distributed as a single installable package.

Think of it this way: hooks, skills, and sub agents are the individual pieces you build. Plugins are how you ship them together. When you install a plugin via `/plugin`, you get all of its bundled automation at once — the skills appear in your `/` menu, the agents become available for delegation, the hooks start firing, and any MCP servers connect automatically.

This matters for two reasons. First, it means you can adopt someone else's entire automation setup without configuring each piece individually. Second, once your own skills, agents, and hooks have matured, you can package them into a plugin so your team (or the community) can install everything with one command.

See [Plugins](plugins.md) for details on installing, creating, and sharing plugins.

---

## Running in CI: GitHub Actions

The three automation mechanisms work the same way whether Claude Code runs on your
laptop or in a CI pipeline. [GitHub Actions](github-actions.md) is the primary way
to run Claude Code in CI — on schedules, pull request events, or issue comments.

Common CI use cases:
- **Automated PR review** — Claude reviews every pull request
- **Scheduled maintenance** — periodic doc freshness checks, configuration audits
- **Issue triage** — Claude classifies and responds to new issues

Your skills, hooks, and permissions carry over — the same automation you build
locally works in CI. See [GitHub Actions](github-actions.md) for setup and
[Ongoing Work](ongoing-work.md) for automated maintenance strategies.

---

## All Documentation

### Getting Started
- [Setting Your Environment](setting-your-environment.md) — Initial setup: CLAUDE.md, permissions, model selection, MCP servers, and customization
- [Starting to Work](starting-to-work.md) — When to use Plan Mode, Accept Edits, and Normal mode
- [Choosing Your Model](choosing-your-model.md) — Opus 4.6, Sonnet 4.6, Haiku, and effort levels
- [Best Practices](best-practices.md) — Self-testing loops, context management, and effective prompting

### Automation Deep Dives
- [Hooks](hooks.md) — Lifecycle automation, guardrails, and validation
- [HTTP Hooks](hooks-http.md) — Dedicated guide for HTTP endpoint hook handlers
- [Skills](skills.md) — Reusable prompts, coding standards, and slash commands
- [Sub Agents](sub-agents.md) — Specialist assistants with isolated context
- [Built-ins](built-ins.md) — Everything Claude Code ships with out of the box
- [Agent Teams](team-mode.md) — Coordinated multi-agent sessions with shared task lists and direct messaging (experimental)

### Configuration & Extensions
- [Configuring Your Claude](configuring-your-claude.md) — Ongoing configuration: when to build skills, agents, hooks, and plugins, and how they evolve over time
- [Plugins](plugins.md) — Installing, creating, and sharing plugin packages
- [GitHub Actions](github-actions.md) — Running Claude Code in CI
- [Ongoing Work](ongoing-work.md) — Automated maintenance patterns
