# Claude Code Guide

A Claude Code guide — interactive onboarding and Q&A on setup, best practices, automation, and effective workflows, packaged as a plugin.

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

Once installed, two skills are available:

- **`/guide:onboard`** — Interactive getting-started walkthrough. Guides you through environment setup, your first session, and best practices.
- **`/guide:ask`** — Ask any question about Claude Code features. Reads relevant reference docs to give accurate, detailed answers.

## Documentation

### Getting Started

- [Setting Your Environment](skills/ask/references/setting-your-environment.md) — CLAUDE.md, permissions, model selection, MCP servers, customization
- [Starting to Work](skills/ask/references/starting-to-work.md) — Permission modes, Plan Mode, Accept Edits, the explore-plan-implement workflow
- [Choosing Your Model](skills/ask/references/choosing-your-model.md) — Opus 4.6, Sonnet 4.6, Haiku, effort levels, when to use each
- [Best Practices](skills/ask/references/best-practices.md) — Self-testing loops, context management, effective prompting, common failure patterns

### Automation

- [Automating Your Workflows](skills/ask/references/automating-your-workflows.md) — Overview of the three automation mechanisms: Hooks, Skills, Sub Agents
- [Hooks](skills/ask/references/hooks.md) — Lifecycle event automation — triggers, handlers, matchers, common patterns
- [Hooks HTTP](skills/ask/references/hooks-http.md) — HTTP-based hook patterns and integrations
- [Skills](skills/ask/references/skills.md) — Creating reusable prompt workflows as Markdown skill files
- [Sub Agents](skills/ask/references/sub-agents.md) — Specialist agent delegation with scoped permissions, worktree isolation
- [Agent Teams](skills/ask/references/team-mode.md) — ⚠️ Experimental: coordinated multi-agent sessions with shared task lists

### Configuration & Extensions

- [Configuring Your Claude](skills/ask/references/configuring-your-claude.md) — Ongoing configuration — when to build skills, agents, hooks, and how they evolve
- [Plugins](skills/ask/references/plugins.md) — Installing, creating, and sharing Claude Code plugins
- [MCP](skills/ask/references/mcp.md) — MCP (Model Context Protocol) — when to use it, the restaurant analogy, server setup and scopes
- [Built-ins](skills/ask/references/built-ins.md) — Built-in slash commands, bundled skills, hook events, sub agents, and tools
- [Ongoing Work](skills/ask/references/ongoing-work.md) — Managing long-running tasks, resuming work, and session continuity

### CI/CD

- [GitHub Actions](skills/ask/references/github-actions.md) — Running Claude Code in CI/CD pipelines with GitHub Actions

### User Stories

Narrative walkthroughs showing Claude Code in real-world scenarios:

- [Daily Workflow](skills/ask/references/stories/daily-workflow.md) — A typical day using Claude Code, from morning context to end-of-day
- [Getting Started with Claude Code](skills/ask/references/stories/starting-new-repo.md) — Your first days on an existing team — /init, building skills organically
- [New Project in Existing Repo](skills/ask/references/stories/new-project-existing-repo.md) — Adding a new module/service within an existing codebase
- [Auto-Maintain CLAUDE.md](skills/ask/references/stories/auto-maintain-claude-md.md) — GitHub Actions cron job to keep CLAUDE.md fresh weekly
- [Context Management](skills/ask/references/stories/context-management-and-clear.md) — When to use /clear, /compact, and how to manage context
- [Sub Agents in a Monolith](skills/ask/references/stories/sub-agents-in-monolith.md) — Using sub agents to navigate and work within a large monolith

## Repository structure

```
claude-code-guide/
├── .claude-plugin/
│   ├── plugin.json              Plugin manifest
│   └── marketplace.json         Marketplace manifest
├── skills/
│   ├── onboard/
│   │   └── SKILL.md             Interactive getting-started walkthrough
│   └── ask/
│       ├── SKILL.md             Q&A against reference docs
│       └── references/
│           ├── stories/         Narrative user-story walkthroughs (6 files)
│           ├── ...              Detailed reference docs (16 files)
├── CLAUDE.md                    Agent instructions
├── PRIVACY.md                   Privacy policy
├── LICENSE                      CC BY 4.0
└── README.md                    This file
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=OriNachum/claude-code-guide&type=Date)](https://www.star-history.com/#OriNachum/claude-code-guide&Date)


## Contributing

Contributions welcome! The skills are at `skills/onboard/SKILL.md` and `skills/ask/SKILL.md`. Reference docs are in `skills/ask/references/`.

## License

CC BY 4.0 — see [LICENSE](LICENSE) for details.
