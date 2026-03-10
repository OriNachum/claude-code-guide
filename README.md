# Claude Code Guide 🌿

A Claude Code Guide — interactive onboarding and Q&A on setup, best practices, automation, and effective workflows, packaged as a plugin.  
Designed with love for beginners 🌱 to experts. 🌳

**New!** Enable a proactive learning with **Game Mode**!  
Enable with `/guide:game-mode on`

> **Listen to this guide** — [NotebookLM audio overview](https://notebooklm.google.com/notebook/61c00692-3e07-4cac-887a-3360520d8f94) provides an AI-generated audio reflection of the guide content.

*⭐ Find this useful? Star the repo to follow updates and show support!* <a href="https://github.com/OriNachum/claude-code-guide/stargazers"><img src="https://img.shields.io/github/stars/OriNachum/claude-code-guide?style=social" alt="GitHub stars"></a>

<p align="center">
  <img width="384" height="256" alt="image" src="https://github.com/user-attachments/assets/5330f813-6539-4e15-bb94-0e1994edd94c" />
</p>

## Install as a Claude Code Plugin

This repo is a **Claude Code plugin**. Install it to get interactive guide skills directly inside Claude Code.

> **Requires Claude Code v1.0.33 or later.** Run `claude --version` to check. See [setup docs](https://code.claude.com/docs/en/quickstart#step-1-install-claude-code) to install or update.

### Quick start (load for current session)

Clone the repo and launch Claude Code with the `--plugin-dir` flag:

```bash
git clone https://github.com/OriNachum/claude-code-guide.git
claude --plugin-dir ./claude-code-guide
```

This loads the plugin for the current session only. You can also use an absolute path:

```bash
claude --plugin-dir /path/to/claude-code-guide
```

### Permanent install (via marketplace)

To install permanently, add this repo as a marketplace from within Claude Code, then install the plugin:

```shell
/plugin marketplace add ./claude-code-guide
/plugin install guide@claude-code-guide
```

Or from the CLI:

```bash
claude plugin marketplace add ./claude-code-guide
claude plugin install guide@claude-code-guide
```

### From GitHub (without cloning first)

From within Claude Code:

```shell
/plugin marketplace add OriNachum/claude-code-guide
/plugin install guide@claude-code-guide
```

> **After installing, restart Claude Code** for the plugin skills to become available.

### Usage

Once installed, four skills are available:

- **`/guide:onboard`** — Interactive getting-started walkthrough. Guides you through environment setup, your first session, and best practices.
- **`/guide:ask`** — Ask any question about Claude Code features. Reads relevant reference docs to give accurate, detailed answers.
- **`/guide:game-mode`** — Enable Game Mode. The guide locally tracks your usage of Claude, assigns a level per feature area, and helps you master Claude Code.
- **`/guide:level-up`** — Feature roadmap and personalized next-step coaching. Shows what to learn next based on your current skill level.

<img width="1050" height="366" alt="image" src="https://github.com/user-attachments/assets/3643154f-00e9-4793-886e-e49adfee54ef" />

## Documentation

### User Stories

Learn by example — these narrative walkthroughs show Claude Code in realistic, end-to-end scenarios where multiple features come together. Each story follows a developer through a real workflow, so you can see how the pieces fit.

- [Daily Workflow](skills/ask/references/daily-workflow.md) — A typical day using Claude Code, from morning context to end-of-day
- [Getting Started with Claude Code](skills/ask/references/starting-new-repo.md) — Your first days on an existing team — /init, building skills organically
- [New Project in Existing Repo](skills/ask/references/new-project-existing-repo.md) — Adding a new module/service within an existing codebase
- [Auto-Maintain CLAUDE.md](skills/ask/references/auto-maintain-claude-md.md) — GitHub Actions cron job to keep CLAUDE.md fresh weekly
- [Context Management](skills/ask/references/context-management-and-clear.md) — When to use /clear, /compact, and how to manage context
- [Sub Agents in a Monolith](skills/ask/references/sub-agents-in-monolith.md) — Using sub agents to navigate and work within a large monolith
- [Discovering Plugins](skills/ask/references/discovering-plugins.md) — Browsing marketplaces, evaluating, and installing your first plugins
- [Memory in Practice](skills/ask/references/memory-in-practice.md) — How auto memory works — corrections that stick, promoting to CLAUDE.md
- [Automated Briefings](skills/ask/references/automated-briefings.md) — Production monitoring with /loop — deploys, post-deploy validation, on-call triage

### Getting Started

- [Setting Your Environment](skills/ask/references/beginner/setting-your-environment.md) — CLAUDE.md, permissions, model selection, MCP servers, customization
- [Starting to Work](skills/ask/references/beginner/starting-to-work.md) — Permission modes, Plan Mode, Accept Edits, the explore-plan-implement workflow
- [Choosing Your Model](skills/ask/references/beginner/choosing-your-model.md) — Opus 4.6, Sonnet 4.6, Haiku, effort levels, when to use each
- [Best Practices](skills/ask/references/intermediate/best-practices.md) — Self-testing loops, context management, effective prompting, common failure patterns
- [Auto Memory](skills/ask/references/beginner/memory.md) — How Claude remembers across sessions, comparison with CLAUDE.md

### Automation

- [Automating Your Workflows](skills/ask/references/intermediate/automating-your-workflows.md) — Overview of the three automation mechanisms: Hooks, Skills, Sub Agents
- [Hooks](skills/ask/references/intermediate/hooks.md) — Lifecycle event automation — triggers, handlers, matchers, common patterns
- [Hooks HTTP](skills/ask/references/expert/hooks-http.md) — HTTP-based hook patterns and integrations
- [Skills](skills/ask/references/intermediate/skills.md) — Creating reusable prompt workflows as Markdown skill files
- [Sub Agents](skills/ask/references/expert/sub-agents.md) — Specialist agent delegation with scoped permissions, worktree isolation
- [Agent Teams](skills/ask/references/expert/team-mode.md) — ⚠️ Experimental: coordinated multi-agent sessions with shared task lists

### Configuration & Extensions

- [Configuring Your Claude](skills/ask/references/intermediate/configuring-your-claude.md) — Ongoing configuration — when to build skills, agents, hooks, and how they evolve
- [Plugins](skills/ask/references/intermediate/plugins.md) — Installing, creating, and sharing Claude Code plugins
- [Marketplace](skills/ask/references/intermediate/marketplace.md) — Discovering, browsing, evaluating, publishing, and managing plugin marketplaces
- [Plugin Examples](skills/ask/references/intermediate/plugin-examples.md) — Curated showcase of notable plugins with patterns and install instructions
- [MCP](skills/ask/references/intermediate/mcp.md) — MCP (Model Context Protocol) — when to use it, the restaurant analogy, server setup and scopes
- [Built-ins](skills/ask/references/beginner/built-ins.md) — Built-in slash commands, bundled skills, hook events, sub agents, and tools
- [Ongoing Work](skills/ask/references/expert/ongoing-work.md) — Managing long-running tasks, resuming work, and session continuity

### CI/CD

- [GitHub Actions](skills/ask/references/intermediate/github-actions.md) — Running Claude Code in CI/CD pipelines with GitHub Actions

### Other

- [Loop](skills/ask/references/intermediate/loop.md) — Running recurring tasks with /loop — polling, deploy monitoring, on-call triage

## Repository structure

```text
claude-code-guide/
├── .claude-plugin/
│   ├── plugin.json ........................ Plugin manifest (name: "guide", version, metadata)
│   └── marketplace.json .................. Marketplace manifest
├── .github/
│   └── workflows/
│       ├── docs-freshness.yml ............. Automated docs accuracy checker
│       └── pages.yml ...................... Jekyll build + raw markdown deploy
├── _includes/
│   ├── footer_custom.html ................. Disclaimer footer
│   └── head_custom.html ................... Raw markdown <link> header
├── _sass/
│   └── color_schemes/
│       └── anthropic.scss ................. Anthropic cream color scheme
├── hooks/
│   ├── hooks.json ......................... Hook event configuration (PostToolUse, UserPromptSubmit, Stop)
│   └── scripts/
│       ├── track-usage.sh ................. PostToolUse handler — tracks feature usage
│       ├── track-prompt.sh ................ UserPromptSubmit handler — tracks /loop usage
│       ├── track-stop.sh .................. Stop handler — token tracking, session counting, and Fibonacci nudges
│       └── migrate-data.sh ................ Lightweight schema migration on version upgrade
├── skills/
│   ├── onboard/
│   │   └── SKILL.md ...................... Interactive getting-started walkthrough
│   ├── ask/
│   │   ├── SKILL.md ...................... Q&A against reference docs
│   │   └── references/ ................... Reference docs organized by tier
│   │           ├── beginner/ ............. 🌱 Beginner feature docs (5 files)
│   │           ├── intermediate/ ......... 🌿 Intermediate feature docs (11 files)
│   │           ├── expert/ ............... 🌳 Expert feature docs (4 files)
│   │           └── *.md .................. Story walkthroughs (9 files)
│   ├── game-mode/
│   │   └── SKILL.md ...................... Gamified usage tracker with levels
│   └── level-up/
│       └── SKILL.md ...................... Feature roadmap and coaching hints
├── docs/
│   ├── getting-started.md ................. Nav parent: Getting Started
│   ├── automation.md ...................... Nav parent: Automation
│   ├── configuration.md ................... Nav parent: Configuration & Extensions
│   ├── ci-cd.md ........................... Nav parent: CI/CD
│   └── user-stories.md .................... Nav parent: User Stories
├── _config.yml ............................ Jekyll configuration (just-the-docs theme)
├── Gemfile ................................ Ruby dependencies
├── index.md ............................... Website landing page
├── .local/ ................................ Runtime data (gitignored)
│   └── game-data.json .................... Usage data (created at runtime)
├── CLAUDE.md .............................. Agent instructions
├── PRIVACY.md ............................. Privacy policy
├── LICENSE ................................ CC BY 4.0
└── README.md .............................. This file
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=OriNachum/claude-code-guide&type=Date)](https://www.star-history.com/#OriNachum/claude-code-guide&Date)

## Contributing

Contributions welcome! The four skills live at `skills/onboard/`, `skills/ask/`, `skills/game-mode/`, and `skills/level-up/`. Reference docs are in `skills/ask/references/` and hooks are in `hooks/`.

## License

CC BY 4.0 — see [LICENSE](LICENSE) for details.
