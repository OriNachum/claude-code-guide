# Sub Agents

> **Level: 🌳 Expert**

[← Back to Automating Your Workflows](automating-your-workflows.md)

Sub Agents are specialized AI assistants that handle specific types of tasks. Each runs in its own context window with a custom system prompt, specific tool access, and independent permissions. They are your primary tool for **delegating self-contained tasks to focused specialists**.

## Three Types of Sub Agents

| Type | Level | How you get them | Examples |
|---|---|---|---|
| **Built-in** | 🌱 Beginner | Ship with Claude Code — used automatically | Explore, Plan, General-purpose |
| **Plugin** | 🌿 Intermediate | Installed via plugins — available after `/plugin add` | `superpowers:code-reviewer`, `plugin-dev:agent-creator` |
| **User-defined** | 🌳 Expert | You create them in `.claude/agents/` | Custom reviewers, debuggers, deployers |

### 🌱 Built-in agents

Claude Code ships with built-in sub agents that Claude uses automatically — no configuration needed. These handle common tasks like codebase exploration (Explore agent, runs on Haiku), planning research (Plan agent), and general-purpose delegation.

You benefit from built-in agents just by using Claude Code. They fire in the background when Claude needs to search, explore, or plan. See [Built-ins](built-ins.md#built-in-sub-agents) for the full list.

### 🌿 Plugin agents

Plugins can bundle sub agents alongside their skills and hooks. When you install a plugin via `/plugin add`, its agents become available for Claude to delegate to automatically — just like built-in agents, but provided by the plugin.

Plugin agents have a namespaced type (e.g., `superpowers:code-reviewer`). You don't create or configure them — the plugin author did that. Your role is choosing which plugins to install. See [Plugins](plugins.md) for how to discover and install plugins.

### User-defined agents

These are the agents you create yourself — the rest of this document covers them in detail. You write a Markdown file with YAML frontmatter specifying tools, model, permissions, and a system prompt. This gives you full control over what the agent can do and how it behaves.

## When to Create Your Own Agent

Think "custom agent" when you catch yourself saying:

- "I want a code reviewer that can only read files, not edit them"
- "I need to run tests in isolation without cluttering my conversation"
- "I want to research three modules in parallel"
- "I need a data analysis agent that uses a faster, cheaper model"
- "I want an agent that remembers patterns it learns across sessions"

Sub agents are about delegation — handing off a complete task to a specialist that works independently and returns results.

## Key Concepts

**Isolation** — Each sub agent gets its own context window. Verbose output (test results, large file contents) stays in the sub agent's context, and only a summary returns to your main conversation.

**Tool restrictions** — You control which tools a sub agent can use. A code reviewer might only get `Read`, `Grep`, and `Glob`. A debugger might get `Read`, `Edit`, and `Bash`.

**Model selection** — Sub agents can use different models. Use `haiku` for fast, cheap exploration. Use `sonnet` for balanced work. Use `opus` for complex reasoning. Use `inherit` (default) to match the main conversation.

**Permission modes** — Sub agents can have their own permission mode: `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`.

**Persistent memory** — Sub agents can maintain a memory directory that survives across sessions, building up knowledge over time.

## Getting Started: Your First Sub Agent

### Using the /agents command (recommended)

1. Run `/agents` in Claude Code
2. Select **Create new agent**
3. Choose **User-level** (available in all projects) or **Project-level** (this project only)
4. Select **Generate with Claude** and describe what you want
5. Configure tools, model, and color
6. Save — it's available immediately

### Writing a file manually

Create `.claude/agents/code-reviewer.md`:

```markdown
---
name: code-reviewer
description: Reviews code for quality, security, and best practices. Use after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer. When invoked:

1. Run `git diff` to see recent changes
2. Focus on modified files
3. Check for: readability, error handling, security, test coverage, performance

Provide feedback organized by priority:
- **Critical** (must fix)
- **Warnings** (should fix)
- **Suggestions** (nice to have)
```

### Using it

Claude will automatically delegate when appropriate, or you can be explicit:

```
Use the code-reviewer agent to review my recent changes
```

## Common Patterns

### Read-only explorer

```markdown
---
name: explorer
description: Explores and analyzes codebases without making changes
tools: Read, Grep, Glob
model: haiku
permissionMode: plan
---

You are a codebase explorer. Search, read, and analyze code.
Summarize your findings with specific file references.
Never suggest changes — only report what you find.
```

### Debugger with edit access

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger. When invoked:
1. Capture the error message and stack trace
2. Identify reproduction steps
3. Isolate the failure location
4. Implement a minimal fix
5. Verify the solution works
```

### Database query agent with hook validation

```markdown
---
name: db-reader
description: Execute read-only database queries for analysis
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---

You are a database analyst with read-only access.
Execute SELECT queries to answer questions about data.
You cannot INSERT, UPDATE, DELETE, or modify schema.
```

### Agent with persistent memory

```markdown
---
name: pattern-learner
description: Reviews code and remembers patterns across sessions
tools: Read, Grep, Glob
memory: user
---

You are a code pattern analyst. As you review code:
- Check your memory for patterns you've seen before
- Update your memory with new patterns, conventions, and recurring issues
- Build institutional knowledge across sessions
```

## Where Sub Agents Live

| Location | Scope | Priority |
|---|---|---|
| `--agents` CLI flag | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

Higher-priority locations win when names conflict.

## Foreground vs Background

Sub agents can run in the foreground (blocking) or background (concurrent):

- **Foreground**: Blocks your conversation until complete. Permission prompts pass through to you.
- **Background**: Runs concurrently. Permissions are pre-approved before launch. Press `Ctrl+B` to background a running task.

Claude decides automatically, or you can ask: "run this in the background."

## Worktree Isolation for Parallel Work

When multiple sub agents need to modify files at the same time, their changes can collide. Git worktrees solve this by giving each sub agent its own copy of the codebase — separate files and branch, shared repository history.

### Enable worktree isolation per agent

Add `isolation: worktree` to a sub agent's frontmatter:

```markdown
# .claude/agents/refactorer.md
---
name: refactorer
description: Refactors code modules independently
tools: Read, Edit, Bash, Grep, Glob
model: sonnet
isolation: worktree
---

Refactor the specified module...
```

Or ask Claude during a session: "use worktrees for your agents."

Each sub agent gets its own worktree that's automatically cleaned up when it finishes without changes. If it made commits, Claude prompts you to keep or remove the worktree.

### When to use worktree isolation

Use worktrees for sub agents that **edit files** — refactorers, fixers, implementers working in parallel. Read-only sub agents (reviewers, researchers, explorers) don't need worktrees since they don't modify anything.

### Manual worktree sessions

You can also run multiple Claude sessions yourself, each in its own worktree:

```bash
# Start Claude in a named worktree (creates branch worktree-feature-auth)
claude --worktree feature-auth

# In another terminal, start a second session
claude --worktree bugfix-123
```

Worktrees are created at `<repo>/.claude/worktrees/<name>`. Add `.claude/worktrees/` to your `.gitignore`.

For more control, create worktrees with Git directly:

```bash
git worktree add ../project-feature-a -b feature-a
cd ../project-feature-a && claude
```

Remember to install dependencies (e.g., `npm install`) in each new worktree.

---

## Sub Agents vs Skills

| Need | Use |
|---|---|
| Reusable prompt that runs in your conversation | Skill |
| Isolated task with its own context and tools | Sub Agent |
| Read-only exploration that doesn't clutter your context | Sub Agent |
| Coding conventions Claude should always follow | Skill |
| Parallel research across multiple areas | Sub Agent |
| Step-by-step deployment playbook | Skill (or Skill with `context: fork`) |

## Next Steps

- Run `/agents` in Claude Code to manage your sub agents
- See the [official sub agents documentation](https://code.claude.com/docs/en/sub-agents) for advanced patterns like chaining agents, resuming agents, and agent teams
- See [Agent Teams](team-mode.md) for coordinated multi-agent work with shared task lists and direct messaging
- Return to [Automating Your Workflows](automating-your-workflows.md) to compare with Hooks and Skills
