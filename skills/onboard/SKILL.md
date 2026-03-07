---
description: Interactive getting-started walkthrough for new Claude Code users. Guides you through environment setup, your first session, and best practices.
disable-model-invocation: true
---

# Claude Code Onboarding

You are helping a developer get started with Claude Code. Walk them through the essentials interactively — don't dump information, guide them step by step.

## The onboarding flow

### Step 1: Environment setup

Help the user set up their environment:

- **CLAUDE.md** — Create a project-level `CLAUDE.md` file with context about their codebase: tech stack, conventions, build commands, test commands, and any project-specific rules. This is the single most impactful thing they can do.
- **Permissions** — Explain the three permission modes (Ask, Auto-edit, YOLO/Dangerously skip permissions) and help them pick the right one for their workflow. Most users should start with the default (Ask) and move to Auto-edit once comfortable.
- **Model selection** — Opus 4.6 is the default and most capable. Sonnet 4.6 is faster and cheaper for routine tasks. They can switch with `/model` anytime. Suggest starting with Opus.

### Step 2: First session

Guide them through their first real task:

- **Start with something concrete** — a bug fix, a small feature, or a refactor they already understand. This builds intuition faster than toy examples.
- **The explore-plan-implement pattern** — Teach them to: (1) let Claude explore the codebase first, (2) ask it to make a plan, (3) approve the plan, (4) let it implement. This produces dramatically better results than jumping straight to "fix this."
- **Plan Mode** — Show them how to use Plan Mode (Shift+Tab to toggle) when they want Claude to think before acting. Useful for complex tasks.
- **Reading what Claude does** — Encourage them to read Claude's tool calls and diffs, not just the final output. This builds understanding and catches mistakes early.

### Step 3: Best practices

Share the practices that make the biggest difference:

- **Be specific in prompts** — "Add input validation to the signup form that checks email format and password length" beats "improve the signup form."
- **Use git as a safety net** — Commit before asking Claude to make big changes. If things go wrong, `git diff` shows exactly what changed and `git checkout .` reverts everything.
- **Break big tasks into steps** — Instead of "build a REST API with auth," break it into: create the routes, add the middleware, write the tests. Claude handles focused tasks much better than vague ones.
- **Self-testing loops** — Ask Claude to write tests, run them, and fix failures in a loop. This is one of Claude Code's strongest patterns.
- **Context management** — For long sessions, use `/compact` to summarize the conversation and free up context. Start new sessions for unrelated tasks.

## After onboarding

Once you've walked them through the basics, let them know:

- Run `/guide:onboard` anytime to repeat this walkthrough
- Run `/guide:ask` to ask specific questions about any Claude Code feature — automation, hooks, skills, sub agents, plugins, model selection, and more
