---
title: "Starting a New Repo"
parent: "User Stories"
nav_order: 2
permalink: /stories/starting-new-repo/
---

# Getting Started: Your First Days with Claude Code

> **Level: 🌱 Beginner** | **Related:** [Setup](https://docs.anthropic.com/en/docs/claude-code/setup)

[← Back to References](beginner/setting-your-environment.md)

## The Scenario

Your team has been working on a Django-based API with a React frontend, Celery workers, and a Docker Compose setup. Nobody on the team has used Claude Code before — you're the first. There's no `CLAUDE.md`, no skills, no setup. Just the codebase and a fresh install of Claude Code.

---

## The Walkthrough

### Step 1: Your First Claude Experience

You open your terminal, navigate to the project, and run Claude for the first time:

```
cd ~/projects/notification-service
claude
```

No `CLAUDE.md`, no context — Claude is seeing this codebase for the first time, just like a new teammate on day one. Your first move is to let Claude get oriented:

```
> /init
```

Claude scans the repo — reads `README.md`, `pyproject.toml`, `package.json`, `docker-compose.yml`, looks at the directory structure. Then it generates a `CLAUDE.md`: the tech stack (Django REST Framework, React, Celery, PostgreSQL, Redis), the project layout, test commands (`pytest` for backend, `npm test` for frontend), and how to start the dev environment with Docker.

You read through it. It's not perfect — it missed the team's naming convention for API endpoints and didn't know about the staging environment — but it's a solid starting point. You'll refine it as you go.

> **What's Happening:** [/init](beginner/built-ins.md) bootstraps the `CLAUDE.md` by scanning the codebase. It won't capture everything — team conventions, architectural decisions, unwritten rules — but it gives Claude enough context to be useful immediately. Think of it as a first draft that you'll improve over time.

### Step 2: Your First Task with Claude

Now you try real work. There's a bug — users see a 500 error when updating their profile with a long bio:

```
> There's a bug where users see a 500 error when updating their profile with a long bio. The error is in the profile update endpoint. Fix it.
```

You watch Claude work. It finds the route handler, reads the validation logic, spots that the database column is `VARCHAR(255)` but there's no length check in the API layer. It adds validation, writes a test, runs `pytest` — all green.

That was... fast. And it worked. You didn't have to explain the project structure, the test framework, or where to find the code. The `CLAUDE.md` from `/init` gave Claude enough to navigate on its own.

You notice something interesting though: Claude read six files to find the right one. If the `CLAUDE.md` mentioned that API routes live in `backend/api/routes/`, Claude would have gone straight there. You add that detail:

```
> Update CLAUDE.md: API route handlers are in backend/api/routes/, one file per resource.
```

That small addition will save Claude (and you) time on every future task.

> **What's Happening:** The first task always reveals gaps in the `CLAUDE.md`. That's expected — [CLAUDE.md](beginner/setting-your-environment.md) is a living document. Each time Claude takes a detour or asks an unnecessary question, that's a signal to add context. The file gets better with every task you do.

### Step 3: Learning How You Work Together

Over the next few days, you start noticing your own patterns:

- You `/clear` between tasks — good, keeps context fresh
- You ask Claude to explain code before modifying it — good, prevents blind changes
- You keep having to remind Claude about the team's API naming convention (`snake_case` for endpoints, `camelCase` for response fields)

That last one goes straight into `CLAUDE.md`. Now it sticks.

You don't rush to create skills or automation. You're still learning what's worth automating. The skills will come naturally when you find yourself repeating the same workflow for the third time.

> **What's Happening:** Your first week is about building intuition, not building tools. Every friction point is a learning opportunity — some get fixed by improving `CLAUDE.md`, others by adjusting how you prompt. The [best practices guide](intermediate/best-practices.md) covers these patterns in depth.

---

## Building Skills Organically

### Scenario: Updating Jira with Development Assumptions

A few weeks in, you notice a recurring pattern. During development, you frequently make assumptions — "I'm assuming this field is never null," "I'm interpreting the ticket to mean only active users," "The acceptance criteria don't cover edge case X, so I'm skipping it." You've been manually opening Jira and adding comments. It's tedious and you sometimes forget.

This is the moment a skill makes sense — you've done it enough times to know the shape of the workflow:

```
> Create a skill called "log-assumption" that takes an assumption I made during development, formats it as a Jira comment with the current ticket number, and posts it to Jira. Save it in ~/.claude/skills/log-assumption/
```

Claude creates the skill with a `SKILL.md` and a script that calls the Jira API. Now when you make an assumption:

```
> /log-assumption Assuming the "bio" field max length matches the DB column (255 chars). Ticket doesn't specify, proceeding with DB constraint as source of truth.
```

Claude formats the comment and posts it to your current Jira ticket. No context switching, no forgetting.

**Why `~/.claude/skills/`?** This is a personal skill — it's about how *you* work, not how the project works. It lives in your home directory so it's available across all your projects. Your teammates might have their own version, or no version at all.

> **What's Happening:** [Skills](intermediate/skills.md) emerge organically from repeated workflows. You didn't sit down on day one and design a skill system. You noticed friction, hit the tipping point of "I've done this three times," and automated it. That's the right time to build a skill — not before.

### Scenario: A Skill to Call Your Service

A month in, you're working on the notification service and you keep needing to test it locally — sending test notifications, checking delivery status, resetting state. You find yourself typing the same `curl` commands over and over:

```
> Create a skill called "test-notification" that sends a test notification through our local service, waits for delivery, and reports the result. Include options for email, SMS, and push. Save it in .claude/skills/test-notification/
```

Claude creates the skill in the project's `.claude/skills/` directory — not your home directory.

**Why `.claude/skills/` (project level)?** This skill is specific to this codebase. It calls this project's local service, uses this project's test data, and only makes sense in this repo. When a teammate pulls the branch, they'll have the skill too. It's part of the project, not part of your personal setup.

```
> /test-notification type=email recipient=test@example.com
```

Claude runs the script, sends the test notification, polls for delivery, and reports back — all without you leaving the terminal.

> **What's Happening:** The difference between `~/.claude/skills/` (personal) and `.claude/skills/` (project) is about scope. Personal skills like Jira logging travel with you. Project skills like service testing travel with the codebase. The [skills guide](intermediate/skills.md) covers this distinction — it's one of the first decisions you make when creating a skill.

---

## Key Takeaways

- **Start with /init.** It generates a first-draft `CLAUDE.md` by scanning the codebase. Refine it as you discover what Claude needs to know.
- **Notice patterns before automating them.** Your first days are for learning how you work with Claude, not for building elaborate automation.
- **Build skills organically.** When you catch yourself doing the same thing for the third time, that's when a skill earns its place.
- **Personal skills go in `~/.claude/skills/`.** Workflows that are about how you work (Jira updates, personal notifications) live in your home directory.
- **Project skills go in `.claude/skills/`.** Workflows tied to a specific codebase (service testing, local tooling) live in the project so the whole team can use them.
