---
description: Walk through Claude Code environment setup — CLAUDE.md, model selection, permissions, and first configuration. Use when onboarding a new developer or setting up a new project.
disable-model-invocation: true
---

# Environment Setup Guide

You are helping a developer configure their Claude Code environment for a new project (or fine-tune an existing setup). They are already running Claude Code — that's how they invoked this skill. Skip installation checks and focus on making their environment effective.

## Step 1: Version and plugin check

Check they're on a current version and that plugins are working:
- Run `claude --version` and confirm they're on 1.0.33+ (required for plugin support)
- If they're on an older version, suggest `npm update -g @anthropic-ai/claude-code`
- Confirm this plugin loaded correctly — if they're reading this, it did

## Step 2: Authentication

- Ask if they've set up authentication for their target provider (`claude auth`)
- Help them choose the right auth method for their situation (API key vs. OAuth)
- If they're already authenticated, move on — don't re-verify what's working

## Step 3: Model selection

Help them pick the right model for their work:
- **Claude Opus 4** — deep reasoning, complex architecture, multi-step tasks. Best for senior-level work, but uses more context.
- **Claude Sonnet 4** — fast, capable, cost-effective. The default and the right choice for most daily work.
- **Claude Haiku** — lightweight, fast responses. Good for simple queries, not for code generation.

Ask what kind of work they primarily do, then recommend a model. Show them how to set it with `/model`.

## Step 4: Create CLAUDE.md

This is the single most impactful setup step. Help them create a CLAUDE.md file in their project root:
- Ask about their project (language, framework, conventions, test commands, build commands)
- Ask about their team's coding style preferences
- Generate a CLAUDE.md with: project overview, tech stack, key commands (build, test, lint), coding conventions, and any project-specific rules

Explain that Claude reads this file at the start of every session — it's how they teach Claude about their project.

## Step 5: Permission mode

Explain the three permission modes and help them choose:
- **Plan Mode** (`Shift+Tab`) — Claude can only read and suggest. Good for exploration.
- **Normal Mode** — Claude asks before writing files or running commands. The default.
- **Accept Edits** / **YOLO Mode** — Claude acts autonomously. Only for trusted, well-scoped tasks.

Recommend starting with Normal Mode until they're comfortable.

## Step 6: Verify the setup

Have them start a fresh session and try:
1. Ask Claude to read their project structure
2. Ask Claude to explain what it knows about the project (tests CLAUDE.md)
3. Try a small task in their codebase

## Related skills

- `/onboarding:first-session` — how to work effectively in their first real session
- `/onboarding:best-practices` — patterns that make Claude dramatically more effective
- `/onboarding:configure` — ongoing configuration as they learn what works
- `/onboarding:choose-model` — deep dive on model selection and switching
