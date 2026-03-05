---
description: Guide for your first real working session with Claude Code — permission modes, the explore→plan→code pattern, and how to course-correct. Use when a developer has Claude Code installed but hasn't done real work with it yet.
---

# Your First Working Session

You are helping a developer who has Claude Code installed but hasn't used it for real work yet. Guide them through an effective first session using their actual codebase.

## Before starting: pick a task

Ask what they want to work on. For a first session, suggest something:
- **Small and well-defined** — a bug fix, a small feature, a refactor
- **In code they understand** — so they can evaluate Claude's work
- **Not critical** — a first session is for learning the workflow, not shipping under pressure

## The explore → plan → code pattern

Walk them through the most effective workflow:

### 1. Explore first
Start in **Plan Mode** (`Shift+Tab` to toggle). Have Claude read and understand the relevant code:
```
Look at the authentication module and explain how login flow works.
What files are involved? What are the key functions?
```

This builds Claude's context without making any changes.

### 2. Plan before coding
Still in Plan Mode, have Claude propose an approach:
```
I want to [describe the task]. Propose an approach.
What files would you change? What's the risk?
```

Review the plan. Ask questions. Push back on anything that feels wrong.

### 3. Code with confidence
Switch to Normal Mode and let Claude implement the plan:
```
Go ahead and implement the approach you proposed.
```

In Normal Mode, Claude will ask permission before writing files or running commands.

## Course-correcting

Teach them the correction toolkit:
- **`Esc`** — stop Claude mid-action, context is preserved
- **`Esc + Esc` or `/rewind`** — roll back to a previous state
- **"Undo that"** — have Claude revert changes
- **Type while Claude works** — add corrections or specificity mid-flight without stopping it
- **Start fresh after two failed corrections** — a clean session with a better prompt beats a long correction chain

## Specificity matters

Show them the difference between vague and specific prompts:

❌ "Fix the login bug"
✅ "The login form submits but the session cookie isn't being set. Look at auth/session.ts and the /api/login endpoint. The cookie should be httpOnly and secure in production."

The more context in the prompt, the better the first attempt.

## Wrapping up the session

After they complete (or attempt) their task:
- Ask what surprised them
- Ask what felt inefficient
- Suggest they try `/onboarding-claude-code:best-practices` for patterns that make future sessions dramatically better
- Suggest `/onboarding-claude-code:automate` when they find themselves repeating the same instructions
