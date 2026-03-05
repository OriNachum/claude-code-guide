# Onboarding Claude Code

An interactive onboarding guide for Claude Code — learn setup, best practices, automation, and effective workflows through guided skills.

## Install as a Claude Code Plugin

This repo is a **Claude Code plugin**. Install it to get interactive onboarding skills directly inside Claude Code.

### Quick install (from GitHub)

```
claude plugin add /path/to/onboarding-claude-code
```

Or clone and point to it:

```bash
git clone https://github.com/OriNachum/onboarding-claude-code.git
claude plugin add ./onboarding-claude-code
```

### Usage

Once installed, run:

```
/onboarding:guide
```

Claude will ask about your experience level and guide you through the relevant topics interactively.

## Documentation

### Getting Started

- [Setting Your Environment](skills/guide/references/setting-your-environment.md) — CLAUDE.md, permissions, model selection, MCP servers, customization
- [Starting to Work](skills/guide/references/starting-to-work.md) — Permission modes, Plan Mode, Accept Edits, the explore-plan-implement workflow
- [Choosing Your Model](skills/guide/references/choosing-your-model.md) — Opus 4.6, Sonnet 4.6, Haiku, effort levels, when to use each
- [Best Practices](skills/guide/references/best-practices.md) — Self-testing loops, context management, effective prompting, common failure patterns

### Automation

- [Automating Your Workflows](skills/guide/references/automating-your-workflows.md) — Overview of the three automation mechanisms: Hooks, Skills, Sub Agents
- [Hooks](skills/guide/references/hooks.md) — Lifecycle event automation — triggers, handlers, matchers, common patterns
- [Skills](skills/guide/references/skills.md) — Creating reusable prompt workflows as Markdown skill files
- [Sub Agents](skills/guide/references/sub-agents.md) — Specialist agent delegation with scoped permissions, worktree isolation
- [Agent Teams](skills/guide/references/team-mode.md) — Experimental: coordinated multi-agent sessions with shared task lists

### Configuration & Extensions

- [Configuring Your Claude](skills/guide/references/configuring-your-claude.md) — Ongoing configuration — when to build skills, agents, hooks, and how they evolve
- [Plugins](skills/guide/references/plugins.md) — Installing, creating, and sharing Claude Code plugins
- [Built-ins](skills/guide/references/built-ins.md) — Built-in slash commands, bundled skills, hook events, sub agents, and tools

## Repository structure

```
onboarding-claude-code/
├── .claude-plugin/
│   └── plugin.json                    Plugin manifest
├── skills/
│   └── guide/
│       ├── SKILL.md                   Interactive onboarding skill
│       └── references/                Detailed reference docs (12 files)
├── CLAUDE.md                          Agent instructions
├── LICENSE                            CC BY 4.0
└── README.md                          This file
```

## Contributing

Contributions welcome! The skill is at `skills/guide/SKILL.md` and reference docs are in `skills/guide/references/`.

## License

CC BY 4.0 — see [LICENSE](LICENSE) for details.
