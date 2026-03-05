# Claude Code Guide

A Claude Code guide — interactive onboarding and Q&A on setup, best practices, automation, and effective workflows, packaged as a plugin.

## Install as a Claude Code Plugin

This repo is a **Claude Code plugin**. Install it to get interactive guide skills directly inside Claude Code.

### From GitHub

```bash
git clone https://github.com/OriNachum/claude-code-guide.git
claude plugin add ./claude-code-guide
```

### From a local path

```
claude plugin add /path/to/claude-code-guide
```

### Usage

Once installed, two skills are available:

- **`/guide:onboarding`** — Interactive getting-started walkthrough. Guides you through environment setup, your first session, and best practices.
- **`/guide:ask`** — Ask any question about Claude Code features. Reads relevant reference docs to give accurate, detailed answers.

## Documentation

### Getting Started

- [Setting Your Environment](skills/guide/ask/references/setting-your-environment.md) — CLAUDE.md, permissions, model selection, MCP servers, customization
- [Starting to Work](skills/guide/ask/references/starting-to-work.md) — Permission modes, Plan Mode, Accept Edits, the explore-plan-implement workflow
- [Choosing Your Model](skills/guide/ask/references/choosing-your-model.md) — Opus 4.6, Sonnet 4.6, Haiku, effort levels, when to use each
- [Best Practices](skills/guide/ask/references/best-practices.md) — Self-testing loops, context management, effective prompting, common failure patterns

### Automation

- [Automating Your Workflows](skills/guide/ask/references/automating-your-workflows.md) — Overview of the three automation mechanisms: Hooks, Skills, Sub Agents
- [Hooks](skills/guide/ask/references/hooks.md) — Lifecycle event automation — triggers, handlers, matchers, common patterns
- [Skills](skills/guide/ask/references/skills.md) — Creating reusable prompt workflows as Markdown skill files
- [Sub Agents](skills/guide/ask/references/sub-agents.md) — Specialist agent delegation with scoped permissions, worktree isolation
- [Agent Teams](skills/guide/ask/references/team-mode.md) — Experimental: coordinated multi-agent sessions with shared task lists

### Configuration & Extensions

- [Configuring Your Claude](skills/guide/ask/references/configuring-your-claude.md) — Ongoing configuration — when to build skills, agents, hooks, and how they evolve
- [Plugins](skills/guide/ask/references/plugins.md) — Installing, creating, and sharing Claude Code plugins
- [MCP](skills/guide/ask/references/mcp.md) — MCP (Model Context Protocol) — when to use it, the restaurant analogy, server setup and scopes
- [Built-ins](skills/guide/ask/references/built-ins.md) — Built-in slash commands, bundled skills, hook events, sub agents, and tools

## Repository structure

```
claude-code-guide/
├── .claude-plugin/
│   ├── plugin.json              Plugin manifest
│   └── marketplace.json         Marketplace manifest
├── skills/
│   └── guide/
│       ├── onboarding/
│       │   └── SKILL.md         Interactive getting-started walkthrough
│       └── ask/
│           ├── SKILL.md         Q&A against reference docs
│           └── references/      Detailed reference docs (13 files)
├── CLAUDE.md                    Agent instructions
├── PRIVACY.md                   Privacy policy
├── LICENSE                      CC BY 4.0
└── README.md                    This file
```

## Contributing

Contributions welcome! The skills are at `skills/guide/onboarding/SKILL.md` and `skills/guide/ask/SKILL.md`. Reference docs are in `skills/guide/ask/references/`.

## License

CC BY 4.0 — see [LICENSE](LICENSE) for details.
