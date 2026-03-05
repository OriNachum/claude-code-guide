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

Claude will ask about your experience level and guide you through the relevant topics interactively. Topics covered include:

- **Setup** — CLAUDE.md, permissions, model selection, MCP servers
- **First session** — Permission modes, Plan Mode, the explore-plan-implement workflow
- **Model selection** — Opus 4.6, Sonnet 4.6, Haiku, effort levels
- **Best practices** — Self-testing loops, context management, effective prompting
- **Built-ins** — Slash commands, bundled skills, hook events, sub agents, tools
- **Automation** — Hooks, Skills, Sub Agents overview and deep dives
- **Plugins** — Installing, creating, and sharing plugins
- **Configuration** — Ongoing setup evolution
- **Agent Teams** — Experimental multi-agent coordination

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
