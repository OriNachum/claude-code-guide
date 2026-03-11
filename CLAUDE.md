# CLAUDE.md — Agent Instructions

This file tells Claude Code (and other AI agents) how to work with this repository.

---

## What This Repo Is

A Claude Code guide, packaged as a plugin. There are four skills:

- **`/guide:onboard`** — Interactive getting-started walkthrough for new users
- **`/guide:ask`** — Q&A skill backed by comprehensive reference documentation in `skills/ask/references/`
- **`/guide:game-mode`** — Gamified usage tracker that rewards feature breadth and depth with a level system
- **`/guide:level-up`** — Feature roadmap and personalized next-step coaching

This repo serves two audiences: humans browsing the docs on GitHub, and Claude Code users who install it as a plugin to get guided help.

This is a **content-only** repo — no application code, no build system, no tests.

---

## Repository Structure

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
│       ├── track-prompt.sh ................ UserPromptSubmit handler — tracks slash-command usage
│       ├── track-stop.sh .................. Stop handler — token tracking, session counting, and Fibonacci nudges
│       └── migrate-data.sh ................ Lightweight schema migration on version upgrade
├── skills/
│   ├── onboard/
│   │   └── SKILL.md ...................... Interactive getting-started walkthrough
│   ├── ask/
│   │   ├── SKILL.md ...................... Q&A against reference docs
│   │   └── references/ ................... Reference docs organized by difficulty tier
│   │           ├── beginner/ ............. 🌱 Beginner feature docs
│   │           │   ├── built-ins.md
│   │           │   ├── choosing-your-model.md
│   │           │   ├── memory.md
│   │           │   ├── setting-your-environment.md
│   │           │   └── starting-to-work.md
│   │           ├── intermediate/ ......... 🌿 Intermediate feature docs
│   │           │   ├── automating-your-workflows.md
│   │           │   ├── best-practices.md
│   │           │   ├── configuring-your-claude.md
│   │           │   ├── github-actions.md
│   │           │   ├── hooks.md
│   │           │   ├── loop.md
│   │           │   ├── marketplace.md
│   │           │   ├── mcp.md
│   │           │   ├── plugin-examples.md
│   │           │   ├── plugins.md
│   │           │   └── skills.md
│   │           ├── expert/ ............... 🌳 Expert feature docs
│   │           │   ├── hooks-http.md
│   │           │   ├── ongoing-work.md
│   │           │   ├── sub-agents.md
│   │           │   └── team-mode.md
│   │           ├── daily-workflow.md ...... Story walkthrough
│   │           ├── starting-new-repo.md
│   │           ├── new-project-existing-repo.md
│   │           ├── auto-maintain-claude-md.md
│   │           ├── context-management-and-clear.md
│   │           ├── discovering-plugins.md
│   │           ├── memory-in-practice.md
│   │           ├── sub-agents-in-monolith.md
│   │           └── automated-briefings.md
│   ├── game-mode/
│   │   └── SKILL.md ...................... Gamified usage tracker with levels
│   └── level-up/
│       └── SKILL.md ...................... Feature roadmap and coaching hints
├── agents/
│   └── doc-verifier.md .................... On-demand reference doc accuracy verifier (Sonnet agent)
├── _config.yml ............................ Jekyll configuration (just-the-docs theme)
├── Gemfile ................................ Ruby dependencies
├── docs/
│   ├── getting-started.md ................. Nav parent: Getting Started
│   ├── automation.md ...................... Nav parent: Automation
│   ├── configuration.md ................... Nav parent: Configuration & Extensions
│   ├── ci-cd.md ........................... Nav parent: CI/CD
│   └── user-stories.md .................... Nav parent: User Stories
├── index.md ............................... Website landing page
├── .local/ ................................ Runtime data (gitignored)
│   └── game-data.json .................... Usage data (created at runtime)
├── CLAUDE.md .............................. This file — agent instructions
├── PRIVACY.md ............................. Privacy policy
├── LICENSE ................................ CC BY 4.0
└── README.md .............................. Human-facing entry point (GitHub only)
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

7. **Difficulty tiers** — Every reference doc has a `> **Level: 🌱/🌿/🌳**` badge after the title. Sections that differ from the file's overall level get an emoji prefix on the `##` heading. Only tag sections that differ — don't repeat the file-level tag on every heading.

---

## Versioning

The plugin version lives in `.claude-plugin/plugin.json` **and** `.claude-plugin/marketplace.json` (`"version": "X.Y.Z"`). **Bump both on every change** so the installed plugin cache stays in sync:

| Change type | Bump | Examples |
|---|---|---|
| **Major** (X) | Breaking changes, structural redesigns | Removing a skill, renaming hook events, changing game-data schema incompatibly |
| **Minor** (Y) | New features, new reference docs, new hook behaviors | Adding a skill, adding a tracking category, new reference doc |
| **Patch** (Z) | Bug fixes, wording tweaks, small improvements | Fixing a regex in a hook script, typo in a reference doc, adjusting a case branch |

Always bump the version in the same commit as the change itself — never leave a functional change without a version bump.

---

## Git Workflow

Before staging or committing changes, check the current branch. If you are on `main`, create a new descriptive branch first — never commit directly to `main`.

---

## How to Edit

- The onboarding skill lives at `skills/onboard/SKILL.md`
- The ask/Q&A skill lives at `skills/ask/SKILL.md`
- Reference docs live at `skills/ask/references/beginner/`, `intermediate/`, and `expert/` — organized by difficulty tier
- User stories live at `skills/ask/references/` (root level) — narrative scenario walkthroughs
- The plugin manifest is at `.claude-plugin/plugin.json` (plugin name: `guide`)
- README.md is the human-facing entry point
- This file (CLAUDE.md) provides agent context — update the structure tree when adding/removing references
