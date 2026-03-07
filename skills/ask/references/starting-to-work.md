# Starting to Work

[← Back to Automating Your Workflows](automating-your-workflows.md)

Before you start typing a prompt, you need to make one key decision: **what permission mode should Claude run in?** This determines how much autonomy Claude has — from read-only exploration to fully autonomous execution.

## The Three Permission Modes

You cycle through modes using **Shift+Tab** during a session, or set them at startup.

| Mode | Indicator | Claude can read files | Claude can edit files | Claude can run commands | You approve each action |
|---|---|---|---|---|---|
| **Normal** (default) | (none) | ✅ | ✅ (with approval) | ✅ (with approval) | Yes — for edits and commands |
| **Accept Edits** | `⏵⏵ accept edits on` | ✅ | ✅ (auto-approved) | ✅ (with approval) | Only for shell commands |
| **Plan Mode** | `⏸ plan mode on` | ✅ | ❌ | ❌ | N/A — Claude only reads and plans |

## Choosing Your Mode

### Start in Plan Mode when...

You're about to work on something **complex, risky, or unfamiliar** and you want Claude to research and think before doing anything.

**Typical scenarios:**

- You're onboarding to a new codebase and want to understand it first
- You're planning a multi-file refactor and want to see the plan before execution
- You're evaluating different approaches to a problem
- You want Claude to investigate a bug without accidentally changing anything
- You're working in a production-adjacent environment and want to be cautious

**How it works:**
In Plan Mode, Claude can read files, search code, and analyze your codebase, but cannot write files or execute commands. It uses `AskUserQuestion` to gather requirements and propose plans.

**The workflow:**
1. Start in Plan Mode: `claude --permission-mode plan` or press `Shift+Tab` twice
2. Ask Claude to explore and plan: "I need to add OAuth. What files need to change? Create a plan."
3. Review the plan (press `Ctrl+G` to edit it in your text editor)
4. Switch to Normal Mode (`Shift+Tab`) and let Claude implement

**Pro tip:** Use the `opusplan` model alias to get Opus-quality reasoning during planning, then automatic Sonnet for implementation. See [Choosing Your Model](choosing-your-model.md).

### Start in Normal Mode when...

You want Claude to work **with your active supervision**. This is the default and the safest productive mode.

**Typical scenarios:**

- You're implementing a feature with clear requirements
- You're fixing a bug and want to verify each change
- You're working with code you don't fully trust Claude with yet
- You're learning Claude Code and want to understand what it does

**How it works:**
Claude can read files freely, but every file edit and shell command requires your approval. You see exactly what Claude wants to do before it happens.

**The workflow:**
1. Start normally: `claude`
2. Describe your task: "Fix the authentication bug in src/auth/login.ts"
3. Claude proposes changes — you approve or reject each one
4. When you trust a pattern, use "Yes, don't ask again" for that tool

**Speeding up Normal Mode:**
You don't have to stay fully manual. Use `/permissions` to pre-approve safe tools:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run test *)",
      "Bash(npm run lint *)",
      "Bash(git status)",
      "Bash(git diff *)"
    ]
  }
}
```

This lets Claude run tests and check diffs without asking, while still prompting for file edits and other commands.

### Start in Accept Edits mode when...

You **trust Claude to edit files** but still want control over shell commands. This is the sweet spot for productive coding once you're comfortable with Claude.

**Typical scenarios:**

- You're writing a feature and don't want to approve every file edit
- You're doing a refactor where Claude will touch many files
- You're generating tests or boilerplate
- You've already planned and just want Claude to execute

**How it works:**
File edits (Write, Edit) are auto-approved for the session. Shell commands still require your approval. This means Claude can freely create and modify files, but you decide when it runs builds, tests, or any other command.

**The workflow:**
1. Press `Shift+Tab` once from Normal Mode (or start with `claude --permission-mode acceptEdits`)
2. Describe your task: "Implement the user profile page based on the spec in SPEC.md"
3. Claude writes files without asking — you only approve shell commands
4. Review the diff afterward: `/diff` or `git diff`

## Decision Flowchart

```
Am I exploring or planning?
├── Yes → Plan Mode
│   └── Ready to implement? → Switch to Normal or Accept Edits
└── No, I'm implementing
    ├── Do I trust Claude with file edits?
    │   ├── Yes → Accept Edits mode
    │   └── Not yet → Normal mode
    └── Is this a quick, low-risk task?
        ├── Yes → Normal mode (just approve as you go)
        └── No, it's complex → Start in Plan Mode first
```

## The Explore → Plan → Implement Workflow

The most effective workflow for non-trivial tasks combines modes:

### Phase 1: Explore (Plan Mode)

```
claude --permission-mode plan
> Read the auth module and explain how sessions work.
> What would need to change to add OAuth?
```

Claude explores freely. Your context stays clean because Claude can't modify anything.

### Phase 2: Plan (Plan Mode)

```
> Create a detailed implementation plan for adding Google OAuth.
> What are the risks? What should we test?
```

Claude produces a plan. Press `Ctrl+G` to edit it in your text editor. Refine until you're satisfied.

### Phase 3: Implement (Normal or Accept Edits)

Press `Shift+Tab` to switch modes, then:

```
> Implement the OAuth flow from your plan. Write tests and run them.
```

Claude implements, and you supervise (Normal) or let it write freely (Accept Edits).

### Phase 4: Verify and Commit

```
> Run all tests. Fix any failures.
> Commit with a descriptive message and create a PR.
```

## Beyond the Three Modes: Advanced Options

### `dontAsk` mode

Auto-denies all tools unless pre-approved via `/permissions`. Useful when you want Claude to work within a very specific set of allowed operations. Set in your settings file:

```json
{ "permissions": { "defaultMode": "dontAsk" } }
```

### `bypassPermissions` mode

Skips all permission checks. **Only use in isolated environments** like containers or VMs. This is the mode used with `--dangerously-skip-permissions` for CI pipelines and automated workflows.

### Sandboxing

An alternative to permission modes — OS-level isolation that restricts filesystem and network access. Enable with `/sandbox`. Claude can work more freely within defined boundaries. This is the safest way to run with fewer interruptions.

## Quick Reference

| I want to... | Use this mode |
|---|---|
| Understand a codebase | Plan Mode |
| Investigate a bug without risk | Plan Mode |
| Plan a complex change | Plan Mode |
| Implement with active supervision | Normal |
| Implement with file-edit freedom | Accept Edits |
| Run in CI/automation | `bypassPermissions` (in a sandbox) |
| Lock down to specific operations | `dontAsk` + allow rules |

## Switching Modes During a Session

You don't have to pick one mode and stick with it. Switch freely:

- **Shift+Tab**: cycles Normal → Accept Edits → Plan Mode → Normal
- **`/plan`**: enters Plan Mode from the prompt
- The mode indicator at the bottom of the terminal tells you which mode you're in

## Next Steps

- Start your next session in Plan Mode for a complex task
- Set up `/permissions` to pre-approve your safe commands
- Try the `opusplan` model for the best planning experience — see [Choosing Your Model](choosing-your-model.md)
- See the [official permissions docs](https://code.claude.com/docs/en/permissions) for full permission rule syntax
