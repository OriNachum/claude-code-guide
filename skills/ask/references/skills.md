# Skills

[← Back to Automating Your Workflows](automating-your-workflows.md)

Skills are Markdown instruction files that extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Skills are your primary tool for creating **reusable prompts, coding standards, deployment playbooks, and custom workflows**.

> **Note:** Slash commands (like custom `/deploy` or `/review`) are simply Skills with a name.
> Built-in slash commands like `/compact` and `/help` are covered in the [Built-ins](built-ins.md) page.
> The `.claude/commands/` directory still works, but Skills (in `.claude/skills/`) are the recommended approach going forward.

## When to Use Skills

Think "skills" when you catch yourself saying:

- "I want Claude to always follow our team's coding conventions"
- "I need a repeatable deployment process I can trigger with a command"
- "Claude should explain code with diagrams and analogies when I ask"
- "I want a code review checklist that Claude follows every time"
- "I need a slash command that generates boilerplate for our API endpoints"

Skills are proactive — they teach Claude *how* to do something, rather than reacting to what Claude does.

## Key Concepts

**SKILL.md** — Every skill needs a `SKILL.md` file inside a named directory. The file has two parts: YAML frontmatter (between `---` markers) for configuration, and Markdown content with instructions.

**Frontmatter** — Optional YAML that controls skill behavior: `name`, `description`, `disable-model-invocation`, `allowed-tools`, `context`, and more.

**Invocation** — Skills can be invoked manually via `/skill-name` or automatically when Claude decides the skill is relevant based on its description.

**Arguments** — Use `$ARGUMENTS` in your skill content to accept input. Running `/fix-issue 123` replaces `$ARGUMENTS` with `123`.

**Scope** — Skills can be personal (`~/.claude/skills/`), project-level (`.claude/skills/`), or enterprise-managed.

## Getting Started: Your First Skill

Create a skill that teaches Claude to explain code with diagrams:

### 1. Create the directory

```bash
mkdir -p .claude/skills/explain-code
```

### 2. Write SKILL.md

Create `.claude/skills/explain-code/SKILL.md`:

```markdown
---
name: explain-code
description: Explains code with visual diagrams and analogies. Use when explaining how code works.
---

When explaining code, always include:

1. **Start with an analogy**: Compare the code to something from everyday life
2. **Draw a diagram**: Use ASCII art to show the flow or structure
3. **Walk through the code**: Explain step-by-step what happens
4. **Highlight a gotcha**: What's a common mistake or misconception?
```

### 3. Test it

Invoke it directly:
```
/explain-code src/auth/login.ts
```

Or let Claude invoke it automatically by asking: "How does this code work?"

## Common Patterns

### Deployment playbook (manual invocation only)

```markdown
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
---

Deploy $ARGUMENTS to production:
1. Run the test suite
2. Build the application
3. Push to the deployment target
4. Verify the deployment succeeded
```

The `disable-model-invocation: true` means only you can trigger this with `/deploy`.

### Code review checklist

```markdown
---
name: review
description: Review code for quality, security, and best practices
---

Review the code and check:
- Readability and naming
- Error handling
- Security (no exposed secrets, input validation)
- Test coverage
- Performance considerations

Provide feedback organized by priority: Critical, Warnings, Suggestions.
```

### Skill that runs in a sub agent (forked context)

```markdown
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

The `context: fork` runs this in an isolated sub agent, keeping your main conversation context clean.

### Skill with dynamic context injection

```markdown
---
name: pr-summary
description: Summarize a pull request
context: fork
agent: Explore
---

## Pull request context
- PR diff: !\`gh pr diff\`
- PR comments: !\`gh pr view --comments\`

Summarize this pull request...
```

The `!\`command\`` syntax runs shell commands before the skill content is sent to Claude.

## Where Skills Live

| Location | Path | Applies to |
|---|---|---|
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Enterprise | Managed settings | All users in your org |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Higher-priority locations win when names conflict: enterprise > personal > project.

## Controlling Invocation

| Frontmatter | You can invoke | Claude can invoke |
|---|---|---|
| (default) | Yes | Yes |
| `disable-model-invocation: true` | Yes | No |
| `user-invocable: false` | No | Yes |

## Next Steps

- Type `/` in Claude Code to see all available skills and commands
- Check the [official skills documentation](https://code.claude.com/docs/en/skills) for advanced patterns like supporting files, visual output, and tool restrictions
- Return to [Automating Your Workflows](automating-your-workflows.md) to compare with Hooks and Sub Agents
