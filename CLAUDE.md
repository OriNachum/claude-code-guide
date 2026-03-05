# CLAUDE.md — Agent Instructions

This file tells Claude Code (and other AI agents) how to work with this repository.

---

## What This Repo Is

An interactive onboarding guide for Claude Code, packaged as a plugin. All content lives in `skills/` as SKILL.md files — interactive instructions that Claude follows when invoked.

This repo serves two audiences: humans browsing the skills on GitHub, and Claude Code users who install it as a plugin to get guided onboarding.

This is a **content-only** repo — no application code, no build system, no tests. Skills are Markdown files designed to be read by Claude and followed interactively.

---

## Repository Structure

```
onboarding-claude-code/
├── .claude-plugin/
│   └── plugin.json ............... Plugin manifest (name: "onboarding", version, metadata)
├── skills/
│   ├── automate/SKILL.md ......... Three automation mechanisms overview
│   ├── best-practices/SKILL.md ... Self-testing, context, prompting patterns
│   ├── built-ins/SKILL.md ........ Built-in commands and tools tour
│   ├── choose-model/SKILL.md ..... Model selection guidance
│   ├── configure/SKILL.md ........ Ongoing configuration guide
│   ├── first-session/SKILL.md .... First working session walkthrough
│   ├── guide/SKILL.md ............ Skill directory and starting point
│   ├── hooks/SKILL.md ............ Lifecycle event automation deep dive
│   ├── plugins-guide/SKILL.md .... Plugin installation and creation
│   ├── setup/SKILL.md ............ Environment setup walkthrough
│   ├── skills-guide/SKILL.md ..... Creating reusable prompt workflows
│   ├── sub-agents/SKILL.md ....... Specialist agent delegation
│   └── team-mode/SKILL.md ....... Experimental agent teams
├── CLAUDE.md ..................... This file — agent instructions
├── LICENSE ....................... CC BY 4.0
└── README.md ..................... Human-facing entry point
```

---

## Critical Rules for Content

These rules MUST be followed when editing or creating skills:

1. **Slash commands are a subset of Skills** — never list them as a separate category. They are the same mechanism.

2. **Three automation mechanisms only**: Hooks, Skills, Sub Agents. Agent Teams are NOT a fourth mechanism — they are architecturally distinct (separate full Claude instances) and always flagged as experimental.

3. **Worktrees are an isolation layer**, not a coordination mechanism. They provide git-level isolation for parallel work.

4. **Agent Teams are experimental** — always flag them with ⚠️ and note they may change.

5. **Skills are interactive instructions**, not reference docs. Every skill starts with "You are helping a developer..." and guides Claude to interact with the user step-by-step.

6. **IKEA analogy**: Hooks = assembly events (they fire during the process), Skills = packages with instruction sheets (reusable, pre-written), Sub Agents = packages + a handyperson (delegate and they deliver).

---

## Skill File Format

Every skill must follow this structure:

```markdown
---
description: One-line description of what this skill does and when to use it.
disable-model-invocation: true
---

# Title

You are helping a developer [do X]. [Context for Claude as the guide.]

## Sections with actionable guidance

[Interactive, step-by-step instructions]

## Related skills

- \`/onboarding:other-skill\` — brief description
```

Key requirements:
- YAML frontmatter with `description` (required) and `disable-model-invocation: true` (required for all tutorial skills)
- Cross-references use `/onboarding:skill-name` format
- Content is onboarding-focused, not exhaustive reference

---

## How to Edit

- Each skill is self-contained in `skills/<name>/SKILL.md`
- The plugin manifest is at `.claude-plugin/plugin.json` (plugin name: `onboarding`)
- README.md is the human-facing entry point — keep the skill table in sync
- This file (CLAUDE.md) provides agent context — update the structure tree when adding skills
