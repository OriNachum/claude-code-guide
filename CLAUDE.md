# CLAUDE.md — Agent Instructions

This file tells Claude Code (and other AI agents) how to work with this repository.

---

## What This Repo Is

A Claude Code guide, packaged as a plugin. There are two skills:

- **`/guide:onboard`** — Interactive getting-started walkthrough for new users
- **`/guide:ask`** — Q&A skill backed by comprehensive reference documentation in `skills/ask/references/`

This repo serves two audiences: humans browsing the docs on GitHub, and Claude Code users who install it as a plugin to get guided help.

This is a **content-only** repo — no application code, no build system, no tests.

---

## Repository Structure

```
claude-code-guide/
├── .claude-plugin/
│   ├── plugin.json ........................ Plugin manifest (name: "guide", version, metadata)
│   └── marketplace.json .................. Marketplace manifest
├── skills/
│   ├── onboard/
│   │   └── SKILL.md ...................... Interactive getting-started walkthrough
│   └── ask/
│       ├── SKILL.md ...................... Q&A against reference docs
│       └── references/ ................... Detailed reference docs read by the ask skill as needed
│               ├── stories/ .............. Narrative user-story walkthroughs
│               │   ├── daily-workflow.md
│               │   ├── starting-new-repo.md
│               │   ├── new-project-existing-repo.md
│               │   ├── auto-maintain-claude-md.md
│               │   ├── context-management-and-clear.md
│               │   └── sub-agents-in-monolith.md
│               ├── automating-your-workflows.md
│               ├── best-practices.md
│               ├── built-ins.md
│               ├── choosing-your-model.md
│               ├── configuring-your-claude.md
│               ├── github-actions.md
│               ├── hooks.md
│               ├── hooks-http.md
│               ├── mcp.md
│               ├── ongoing-work.md
│               ├── plugins.md
│               ├── setting-your-environment.md
│               ├── skills.md
│               ├── starting-to-work.md
│               ├── sub-agents.md
│               └── team-mode.md
├── CLAUDE.md .............................. This file — agent instructions
├── PRIVACY.md ............................. Privacy policy
├── LICENSE ................................ CC BY 4.0
└── README.md .............................. Human-facing entry point
```

---

## Critical Rules for Content

These rules MUST be followed when editing or creating skills:

1. **Slash commands are a subset of Skills** — never list them as a separate category. They are the same mechanism.

2. **Three automation mechanisms only**: Hooks, Skills, Sub Agents. Agent Teams are NOT a fourth mechanism — they are architecturally distinct (separate full Claude instances) and always flagged as experimental.

3. **Worktrees are an isolation layer**, not a coordination mechanism. They provide git-level isolation for parallel work.

4. **Agent Teams are experimental** — always flag them with ⚠️ and note they may change.

5. **The onboarding skill is interactive**, not a reference dump. It walks users through setup step by step. The ask skill answers questions by reading reference docs.

6. **IKEA analogy**: Hooks = assembly events (they fire during the process), Skills = packages with instruction sheets (reusable, pre-written), Sub Agents = packages + a handyperson (delegate and they deliver).

---

## How to Edit

- The onboarding skill lives at `skills/onboard/SKILL.md`
- The ask/Q&A skill lives at `skills/ask/SKILL.md`
- Reference docs live at `skills/ask/references/` — one file per topic
- User stories live at `skills/ask/references/stories/` — narrative scenario walkthroughs
- The plugin manifest is at `.claude-plugin/plugin.json` (plugin name: `guide`)
- README.md is the human-facing entry point
- This file (CLAUDE.md) provides agent context — update the structure tree when adding/removing references
