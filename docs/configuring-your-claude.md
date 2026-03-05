# Configuring Your Claude

[← Back to Automating Your Workflows](automating-your-workflows.md)

Your environment is set up (see [Setting Your Environment](setting-your-environment.md) if you haven't done that yet). Now comes the part that never really ends: teaching Claude how to work the way *you* work.

This guide covers the ongoing configuration — building skills, sub-agents, hooks, and plugins that evolve alongside your project. Think of it as the difference between furnishing a house (initial setup) and living in it (adapting it over time).

---

## The Building Blocks

Claude Code gives you four mechanisms for ongoing customization. Each serves a different purpose:

| Mechanism | What it does | When it fires | Think of it as... |
|---|---|---|---|
| **Skills** | Reusable instructions and workflows | When you invoke them or Claude matches the task | Teaching Claude *how* to do something |
| **Sub Agents** | Specialist assistants with isolated context | When tasks match their description or you invoke them | Delegating to a specialist |
| **Hooks** | Shell commands or prompts at lifecycle points | Automatically, on specific events | Guardrails and automated reactions |
| **Plugins** | Bundled packages of skills, agents, hooks, and MCP | When installed and enabled | Installing an app |

Each mechanism has its own dedicated page with full details. This guide focuses on *when* and *why* to build them, and how they work together.

---

## Building Skills Over Time

Skills are Markdown files that teach Claude reusable patterns. You don't need to write them all up front — build them as you notice repetition.

### When to create a skill

Pay attention to moments when you:

- Explain the same process to Claude more than twice
- Copy-paste the same prompt across sessions
- Wish Claude would "just know" how to do something specific to your project

Those are signals to create a skill.

### The progression

**Week 1**: You keep telling Claude "When you write tests, use our `createTestFixture` helper and always include edge cases for null inputs."

**Week 2**: You create a skill:

```markdown
# .claude/skills/write-tests/SKILL.md
---
name: write-tests
description: Write tests following our project conventions
---

When writing tests:
1. Use `createTestFixture` for setup
2. Always include edge cases for null inputs
3. Group tests with `describe` blocks by function
4. Name tests: "should [expected behavior] when [condition]"
```

**Week 4**: You add a deployment skill, a code review skill, and a PR summary skill. Your team starts contributing skills too.

### Slash commands vs auto-invoked skills

Every skill can work two ways:

- **Slash command**: You trigger it explicitly with `/skill-name`. Use `disable-model-invocation: true` for skills that should only run when you ask (like deployment).
- **Auto-invoked**: Claude reads the description and decides when the skill is relevant. Good for coding conventions and review checklists.

See [Skills](skills.md) for full syntax, patterns, and examples.

---

## Building Sub Agents Over Time

Sub agents are specialist AI assistants that run in their own context window. They keep verbose work (test output, large file analysis) out of your main conversation.

### When to create a sub agent

Create a sub agent when:

- A task produces lots of output you don't need to see (test results, log analysis)
- You want a different model for a specific task (Haiku for quick checks, Opus for deep analysis)
- A task needs a restricted set of tools (read-only code explorer, no-write database query agent)
- You find yourself frequently delegating the same type of work

### The progression

**Month 1**: You create a code reviewer agent that runs on Sonnet to check PRs:

```markdown
# .claude/agents/code-reviewer.md
---
name: code-reviewer
description: Reviews code for quality, security, and best practices
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer. When invoked:
1. Run `git diff` to see recent changes
2. Check for: readability, error handling, security, test coverage
3. Provide feedback organized by priority (Critical / Warnings / Suggestions)
```

**Month 2**: You add a database explorer (read-only, runs on Haiku) and a test runner (catches failures, summarizes results).

**Month 3**: You add a documentation agent with persistent memory that learns your project's doc style over time. You add hook validation to your database agent to prevent write operations.

### Agent configuration options

| Option | What it controls | Example values |
|---|---|---|
| `tools` | Which tools the agent can use | `Read, Grep, Glob`, `Read, Edit, Bash` |
| `model` | Which model the agent runs on | `haiku`, `sonnet`, `opus`, `inherit` |
| `permissionMode` | Agent's permission level | `default`, `acceptEdits`, `plan` |
| `memory` | Persistent memory across sessions | `user`, `project` |
| `hooks` | Agent-specific lifecycle hooks | PreToolUse/PostToolUse matchers |

See [Sub Agents](sub-agents.md) for patterns including read-only explorers, debuggers, and agents with persistent memory.

---

## Building Hooks Over Time

Hooks are automated reactions — shell commands, HTTP calls, or LLM prompts that fire at specific lifecycle points. They're your guardrails and quality gates.

### When to create a hook

Create a hook when:

- You want something to happen *every time* Claude does a specific action (auto-lint after edits)
- You need to block dangerous operations (prevent `rm -rf`, block `DROP TABLE`)
- You want validation before Claude finishes (run tests, check formatting)
- You need to inject context automatically (load issue details on session start)

### The progression

**Week 1**: Auto-lint after every file edit:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint --fix \"$(echo $CLAUDE_PROJECT_DIR)/**/*.ts\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

**Week 3**: Add a Stop hook that runs the test suite and forces Claude to keep working if tests fail.

**Month 2**: Add a SessionStart hook that loads the current sprint's issues from your tracker. Add a PreToolUse hook that blocks any Bash command containing production database credentials.

### Hook types

| Type | What it does | Best for |
|---|---|---|
| `command` | Runs a shell command | Linting, testing, file checks |
| `http` | Sends an HTTP POST | Webhooks, external APIs, logging |
| `prompt` | Asks an LLM to evaluate | Nuanced judgment (is this code safe?) |
| `agent` | Spawns an agentic verifier | Complex multi-step validation |

See [Hooks](hooks.md) for all lifecycle events, matchers, and decision control patterns.

---

## Installing and Building Plugins

Plugins bundle skills, agents, hooks, and MCP servers into installable packages. They're the fastest way to add capability and the best way to share your configurations with others.

### When to use plugins

- **Install existing plugins** when your stack has community support (LSP for TypeScript/Python/Rust, testing frameworks, deployment tools)
- **Create your own plugin** when your team's skills and agents have matured and you want to package them for reuse across projects
- **Share plugins** when other teams could benefit from your automation patterns

### The progression

**Week 1**: Install the LSP plugin for your language to give Claude precise type checking and navigation:

```
/plugin
```

**Month 2**: You've built several skills and agents that work well together. Package them as an internal plugin for your team.

**Month 3**: You share the plugin across your organization. New team members get your entire automation setup by installing one plugin.

See [Plugins](plugins.md) for installing, creating, and distributing plugins.

---

## How the Pieces Work Together

The real power comes from combining these mechanisms. Here's how they interact in a mature setup:

### Example: Automated code review pipeline

1. **Skill** (`/review`): Defines what a code review should cover — your team's checklist and standards
2. **Sub Agent** (`code-reviewer`): Runs the review in an isolated context on Sonnet, keeping verbose diff output out of your main conversation
3. **Hook** (PostToolUse on Write|Edit): Auto-lints every file Claude modifies
4. **Hook** (Stop): Runs the test suite before Claude finishes, forcing it to continue if anything fails
5. **Plugin**: Packages all of the above for your team to install with one command

### Example: Safe database operations

1. **Sub Agent** (`db-explorer`): Read-only database agent running on Haiku
2. **Hook** (PreToolUse on Bash): Validates every shell command, blocking anything that could modify production data
3. **Skill** (`/db-report`): Templated queries for common reports
4. **Hook** (PostToolUse on Bash): Logs all database queries to an audit trail via HTTP webhook

### Example: Onboarding a new developer

1. **CLAUDE.md**: Project context that every session loads (from [Setting Your Environment](setting-your-environment.md))
2. **Skills**: Team's coding conventions, deployment process, PR workflow — all discoverable via `/`
3. **Sub Agents**: Pre-built specialists for code review, testing, and debugging
4. **Plugins**: One-command install of the entire team's automation setup
5. **Hooks**: Guardrails that prevent common mistakes before they happen

---

## Evolving Your Configuration

Configuration isn't a one-time task. Here's a healthy rhythm:

**Weekly**: Notice patterns in your sessions. Are you repeating yourself? Create a skill. Is something slipping through? Add a hook.

**Monthly**: Review your skills and agents. Are they still accurate? Do any need updating? Are there new ones your team would benefit from?

**Quarterly**: Consider packaging your best configurations as a plugin. Share what works across projects or teams.

### Keep it maintainable

- **Don't over-automate early.** Let patterns emerge naturally before codifying them.
- **Document your skills.** A skill's `description` field should be clear enough that both you and Claude understand when to use it.
- **Test your hooks.** Run `claude --debug` to see hook execution and catch issues.
- **Version your agents.** Since agents live in `.claude/agents/`, they're tracked by git. Use commit messages to explain changes.

---

## Next Steps

- See [Skills](skills.md) for creating reusable prompts and workflows
- See [Sub Agents](sub-agents.md) for building specialist assistants
- See [Hooks](hooks.md) for lifecycle automation and guardrails
- See [Plugins](plugins.md) for packaging and sharing your configuration
- See [Automating Your Workflows](automating-your-workflows.md) for the automation comparison overview
- See [Setting Your Environment](setting-your-environment.md) for initial setup if you haven't done it yet
