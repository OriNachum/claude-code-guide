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

### Available skills

Once installed, type `/onboarding:guide` to see everything, or jump directly to any skill:

| Skill | What it does |
|---|---|
| `/onboarding:guide` | See all skills and where to start |
| `/onboarding:setup` | Environment configuration — CLAUDE.md, model selection, permissions |
| `/onboarding:first-session` | Guide your first real working session |
| `/onboarding:best-practices` | Self-testing, context management, prompting |
| `/onboarding:choose-model` | Pick the right model and effort level |
| `/onboarding:built-ins` | Tour of built-in commands, tools, and capabilities |
| `/onboarding:automate` | Overview of Hooks, Skills, and Sub Agents |
| `/onboarding:hooks` | Lifecycle event automation deep dive |
| `/onboarding:skills-guide` | Creating reusable prompt workflows |
| `/onboarding:sub-agents` | Specialist agent delegation |
| `/onboarding:team-mode` | Experimental multi-agent coordination |
| `/onboarding:plugins-guide` | Install, create, and share plugins |
| `/onboarding:configure` | Ongoing configuration and CLAUDE.md refinement |

## Repository structure

```
onboarding-claude-code/
├── .claude-plugin/
│   └── plugin.json              Plugin manifest
├── skills/                      All content lives here as interactive skills
│   ├── automate/SKILL.md
│   ├── best-practices/SKILL.md
│   ├── built-ins/SKILL.md
│   ├── choose-model/SKILL.md
│   ├── configure/SKILL.md
│   ├── first-session/SKILL.md
│   ├── guide/SKILL.md
│   ├── hooks/SKILL.md
│   ├── plugins-guide/SKILL.md
│   ├── setup/SKILL.md
│   ├── skills-guide/SKILL.md
│   ├── sub-agents/SKILL.md
│   └── team-mode/SKILL.md
├── CLAUDE.md                    Agent instructions
├── LICENSE                      CC BY 4.0
└── README.md                    This file
```

## Contributing

Contributions welcome! Each skill is a self-contained SKILL.md file in `skills/<name>/`. See `/onboarding:skills-guide` for the format.

## License

CC BY 4.0 — see [LICENSE](LICENSE) for details.
