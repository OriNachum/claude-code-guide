# CLAUDE.md — Agent Instructions

This file tells Claude Code (and other AI agents) how to work with this repository.

---

## What This Repo Is

An interactive onboarding guide for Claude Code, packaged as a plugin. There is a single skill (`/onboarding:guide`) backed by comprehensive reference documentation in `skills/guide/references/`.

This repo serves two audiences: humans browsing the docs on GitHub, and Claude Code users who install it as a plugin to get guided onboarding.

This is a **content-only** repo — no application code, no build system, no tests.

---

## Repository Structure

```
onboarding-claude-code/
├── .claude-plugin/
│   └── plugin.json ........................ Plugin manifest (name: "onboarding", version, metadata)
├── skills/
│   └── guide/
│       ├── SKILL.md ....................... The onboarding skill — entry point and interactive guide
│       └── references/ ................... Detailed reference docs read by the skill as needed
│           ├── automating-your-workflows.md
│           ├── best-practices.md
│           ├── built-ins.md
│           ├── choosing-your-model.md
│           ├── configuring-your-claude.md
│           ├── hooks.md
│           ├── plugins.md
│           ├── setting-your-environment.md
│           ├── skills.md
│           ├── starting-to-work.md
│           ├── sub-agents.md
│           └── team-mode.md
├── CLAUDE.md .............................. This file — agent instructions
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

5. **The guide skill is interactive**, not a reference dump. It starts with "You are helping a developer..." and reads reference docs as needed to guide the user step-by-step.

6. **IKEA analogy**: Hooks = assembly events (they fire during the process), Skills = packages with instruction sheets (reusable, pre-written), Sub Agents = packages + a handyperson (delegate and they deliver).

---

## How to Edit

- The single skill lives at `skills/guide/SKILL.md`
- Reference docs live at `skills/guide/references/` — one file per topic
- The plugin manifest is at `.claude-plugin/plugin.json` (plugin name: `onboarding`)
- README.md is the human-facing entry point
- This file (CLAUDE.md) provides agent context — update the structure tree when adding/removing references
