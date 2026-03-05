# Running Multiple Agents in Parallel

[← Back to Automating Your Workflows](automating-your-workflows.md)

Sometimes one Claude isn't enough. You have multiple tasks that can run at the same time — separate features, independent investigations, or a review that shouldn't block implementation. Claude Code gives you three ways to parallelize work, each at a different level of coordination.

---

## The Three Approaches

| Approach | What it is | Coordination | Best for |
|---|---|---|---|
| **Git Worktrees** | Multiple independent Claude sessions, each in its own worktree | None — you coordinate manually | Independent tasks that don't need to talk to each other |
| **Sub Agents** | Specialist agents spawned within your session | Report results back to the main agent only | Focused tasks where only the result matters |
| **Agent Teams** | Multiple Claude instances with shared task list and messaging | Teammates communicate directly with each other | Complex work requiring discussion and collaboration |

Think of it as a spectrum of coordination:

- **Worktrees**: You're the project manager. You open multiple terminals, give each Claude a task, and combine the results yourself.
- **Sub Agents**: Claude is the project manager. It delegates focused tasks to helpers who report back, but the helpers never talk to each other.
- **Agent Teams**: Claude leads a team. Teammates have a shared task list, can message each other, challenge each other's findings, and self-coordinate.

---

## Git Worktrees — Manual Parallelism

Git worktrees create separate working directories that each have their own files and branch, while sharing the same repository history. Each worktree gets its own Claude session, so changes in one don't collide with another.

### When to use worktrees

Use worktrees when your tasks are genuinely independent — a feature branch and a bug fix that touch different files, or two explorations where you don't need the results to feed into each other. You're the coordinator: you decide when each task is done and how to merge the results.

### Quick start

```bash
# Start Claude in a named worktree (creates branch worktree-feature-auth)
claude --worktree feature-auth

# In another terminal, start a second session
claude --worktree bugfix-123

# Or let Claude pick a random name
claude --worktree
```

Worktrees are created at `<repo>/.claude/worktrees/<name>` and branch from your default remote branch.

You can also ask Claude during a session to "work in a worktree" or "start a worktree" and it will create one automatically.

### Sub agent worktrees

Sub agents can also use worktree isolation. Ask Claude to "use worktrees for your agents" or add `isolation: worktree` to a custom agent's frontmatter. Each sub agent gets its own worktree that's automatically cleaned up when it finishes without changes.

### Cleanup

When you exit a worktree session, Claude handles cleanup based on whether you made changes. If there are no changes, the worktree and branch are removed automatically. If there are commits or uncommitted changes, Claude prompts you to keep or remove the worktree.

Add `.claude/worktrees/` to your `.gitignore` to prevent worktree contents from showing as untracked files.

### Manual worktree management

For more control over location and branch, create worktrees with Git directly:

```bash
# Create a worktree with a new branch
git worktree add ../project-feature-a -b feature-a

# Create a worktree checking out an existing branch
git worktree add ../project-bugfix bugfix-123

# Start Claude in the worktree
cd ../project-feature-a && claude

# Clean up when done
git worktree remove ../project-feature-a
```

Remember to install dependencies (e.g., `npm install`) in each new worktree according to your project's setup.

---

## Sub Agents — Delegated Parallelism

Sub agents run within your current session. Claude spawns them, they do their work in an isolated context window, and they report results back. The key distinction from worktrees: Claude manages the delegation, and from agent teams: the helpers never talk to each other.

See [Sub Agents](sub-agents.md) for full details on creating and configuring sub agents.

### When to use sub agents for parallel work

Sub agents are ideal when you want Claude to parallelize automatically without you managing separate terminals. The results feed back into your main conversation as summaries, keeping your context clean.

Good fits include running tests and fixing failures in isolation, researching multiple parts of a codebase simultaneously, code review across different modules, and any task where you care about the *result* but not the *process*.

### Sub agents vs worktrees

Sub agents are lighter weight — no separate terminal, no manual coordination, automatic context cleanup. But they only report back to the main agent. If you need to intervene mid-task or combine findings yourself, worktrees give you more control.

---

## Agent Teams — Coordinated Parallelism

Agent teams are the most powerful option: multiple Claude Code instances that share a task list, communicate with each other, and self-coordinate. One session acts as the team lead, and teammates work independently but can message each other directly.

> **Note:** Agent teams are experimental and disabled by default. Enable them in your settings before use.

### When to use agent teams

Agent teams shine when the parallel workers need to *interact*:

- **Research and review**: Multiple teammates investigate different aspects of a problem, then share and challenge each other's findings
- **Competing hypotheses**: Teammates test different theories in parallel and debate to converge on the answer
- **New modules or features**: Each teammate owns a separate piece, but they coordinate at the boundaries
- **Cross-layer coordination**: Changes that span frontend, backend, and tests, each owned by a different teammate

Agent teams add coordination overhead and use significantly more tokens than a single session. For sequential tasks, same-file edits, or work with heavy dependencies between tasks, a single session or sub agents is more effective.

### Enable agent teams

Agent teams are disabled by default. Enable them in your settings:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Start a team

Tell Claude to create an agent team and describe the task and team structure in natural language:

```
I'm designing a CLI tool that helps developers track TODO comments.
Create an agent team to explore this from different angles:
one teammate on UX, one on technical architecture, one playing devil's advocate.
```

Claude creates the team, spawns teammates, and coordinates work. You can also specify the number of teammates and which model they should use:

```
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### Display modes

Agent teams support two display modes:

**In-process** (default): All teammates run inside your main terminal. Use `Shift+Down` to cycle through teammates and type to message them directly. Works in any terminal.

**Split panes**: Each teammate gets its own pane. You can see everyone's output at once and click into a pane to interact directly. Requires `tmux` or iTerm2.

Configure in settings:

```json
{
  "teammateMode": "in-process"
}
```

Or per session:

```bash
claude --teammate-mode in-process
```

### Interacting with the team

**Message teammates directly**: In in-process mode, use `Shift+Down` to cycle through teammates. In split-pane mode, click into a teammate's pane. Each teammate is a full Claude Code session.

**View the task list**: Press `Ctrl+T` to toggle the shared task list.

**Require plan approval**: For risky tasks, you can require teammates to plan before implementing. The lead reviews and approves or rejects with feedback:

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

### Task coordination

The shared task list is how work is organized. Tasks have three states: pending, in progress, and completed. Tasks can depend on other tasks — a pending task with unresolved dependencies can't be claimed until those dependencies are completed.

The lead creates tasks and teammates work through them. Teammates can self-claim the next available task after finishing one, or the lead can assign explicitly.

### Quality gates with hooks

Use hooks to enforce rules when teammates finish work:

- **TeammateIdle**: Fires when a teammate is about to go idle. Exit with code 2 to send feedback and keep the teammate working.
- **TaskCompleted**: Fires when a task is being marked complete. Exit with code 2 to prevent completion and send feedback.

### Shutting down

Shut down individual teammates by telling the lead:

```
Ask the researcher teammate to shut down
```

When done, clean up the entire team:

```
Clean up the team
```

Always use the lead to clean up — teammates should not run cleanup themselves.

### Best practices for agent teams

**Give teammates enough context.** Teammates load project context automatically (CLAUDE.md, MCP servers, skills) but don't inherit the lead's conversation history. Include task-specific details in the spawn prompt.

**Start with 3–5 teammates.** This balances parallel work with manageable coordination. Aim for 5–6 tasks per teammate.

**Size tasks appropriately.** Too small and coordination overhead exceeds the benefit. Too large and teammates work too long without check-ins. Aim for self-contained units that produce a clear deliverable — a function, a test file, a review.

**Avoid file conflicts.** Two teammates editing the same file leads to overwrites. Break work so each teammate owns a different set of files.

**Monitor and steer.** Check in on progress, redirect approaches that aren't working, and synthesize findings as they come in. Unattended teams risk wasted effort.

**Start with research and review.** If you're new to agent teams, begin with tasks that don't require code changes — reviewing a PR, researching a library, investigating a bug. These show the value of parallel exploration with less coordination risk.

---

## Choosing the Right Approach

| Question | Worktrees | Sub Agents | Agent Teams |
|---|---|---|---|
| Do the tasks need to talk to each other? | No | No | Yes |
| Who coordinates? | You | Claude (main session) | Claude (lead) + teammates self-coordinate |
| Token cost | Lowest (separate sessions) | Low (results summarized back) | Highest (each teammate is a full instance) |
| Setup required | `--worktree` flag | Agent files or natural language | Enable experimental flag + describe team |
| Can you intervene mid-task? | Yes (switch terminals) | No (wait for results) | Yes (`Shift+Down` or click pane) |
| Cleanup | Automatic or manual | Automatic | Tell the lead to clean up |

**Start simple.** If your tasks are independent, use worktrees. If you want Claude to manage the delegation, use sub agents. Only reach for agent teams when teammates genuinely need to communicate — the coordination overhead and token cost are significant.

---

## Troubleshooting

### Worktree issues

If `--worktree` fails, check that you're inside a git repository and that the `.claude/worktrees/` directory is writable. For non-git version control, configure `WorktreeCreate` and `WorktreeRemove` hooks to provide custom worktree logic.

### Agent team issues

**Teammates not appearing**: In in-process mode, press `Shift+Down` — they may be running but not visible. Check that your task was complex enough to warrant a team.

**Too many permission prompts**: Pre-approve common operations in your permission settings before spawning teammates.

**Lead finishes before teammates**: Tell it to wait: "Wait for your teammates to complete their tasks before proceeding."

**Orphaned tmux sessions**: List and kill manually: `tmux ls` then `tmux kill-session -t <name>`.

**Current limitations**: No session resumption with in-process teammates, one team per session, no nested teams (teammates can't spawn their own teams), lead is fixed for the session's lifetime, split panes require tmux or iTerm2.

---

## Next Steps

- See [Sub Agents](sub-agents.md) for creating specialist agents
- See [Hooks](hooks.md) for TeammateIdle and TaskCompleted quality gates
- See [Automating Your Workflows](automating-your-workflows.md) for the full automation overview
- See the [official agent teams docs](https://code.claude.com/docs/en/agent-teams) for the complete reference
- See the [official worktrees section](https://code.claude.com/docs/en/common-workflows) in Common Workflows for additional details
