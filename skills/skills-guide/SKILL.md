---
description: Deep dive into Claude Code skills — reusable prompt-driven workflows you create as Markdown files. Slash commands are a subset of skills. Use when a developer wants to create their own reusable commands.
---

# Skills — Reusable Prompt Workflows

You are helping a developer create their own Claude Code skills. In the IKEA analogy, skills are the packages — the instruction sheet, all the parts, and the specific tools. You (the developer) still do the assembly step by step, but the instructions are pre-written and reusable.

## What skills are

A skill is a Markdown file that tells Claude how to perform a specific task. When invoked, Claude reads the file and follows its instructions. Skills live in `.claude/skills/` as folders containing a `SKILL.md`.

Slash commands (like `/review`) are a subset of skills — they're the same mechanism.

## Creating a skill

### 1. Create the directory structure
```bash
mkdir -p .claude/skills/review
```

### 2. Write the SKILL.md
```markdown
---
description: Review code changes for bugs, security, and style. Use when reviewing PRs or recent changes.
---

# Code Review

Review the current changes (or specified files) for:
1. Potential bugs and edge cases
2. Security concerns
3. Performance issues
4. Style consistency with project conventions
5. Test coverage gaps

Be concise. Flag issues by severity (critical, warning, suggestion).
For each issue, show the line and explain why it matters.
```

### 3. Invoke it
```
/review
```

## Frontmatter options

The YAML frontmatter controls skill behavior:

- **`description`** (required) — what the skill does and when to use it. Claude uses this to decide when to invoke model-triggered skills.
- **`disable-model-invocation: true`** — skill can only be invoked manually (not auto-triggered by Claude)
- **`$ARGUMENTS`** — placeholder in the body that captures text after the skill name: `/review src/auth.ts` → `$ARGUMENTS` = `src/auth.ts`

## Skill design patterns

Help the developer write effective skills:

**Be specific about output format.** "List issues as bullet points with severity tags" produces more useful output than "review the code."

**Include context about the project.** "Follow our ESLint config" or "We use Jest for testing" helps Claude give relevant advice.

**Use progressive disclosure.** Start with the most important instruction, add detail as needed.

**Include tool restrictions if needed.** Some skills should only read, never write.

## Examples to get them started

Ask what they repeat often, then help them create a skill for it:

| Repeated task | Skill idea |
|---|---|
| "Review my changes" | `/review` — code review checklist |
| "Write tests for this" | `/test` — generate tests following project patterns |
| "Explain this code" | `/explain` — architecture walkthrough |
| "Deploy to staging" | `/deploy-staging` — deployment workflow |
| "Create a PR description" | `/pr` — generate PR description from changes |

## Skills vs hooks vs sub agents

Skills are **manually invoked** — the developer chooses when to use them. Hooks are **automatic** — they fire on events. Sub agents are **delegated** — Claude spawns them for specialized work. A skill can invoke sub agents internally.

## Related skills
- `/onboarding-claude-code:hooks` — automatic event-driven automation
- `/onboarding-claude-code:sub-agents` — delegating to specialist agents
- `/onboarding-claude-code:automate` — overview of all three mechanisms
- `/onboarding-claude-code:plugins-guide` — packaging skills into shareable plugins
