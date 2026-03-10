---
title: "Agent Teams"
parent: "Automation"
nav_order: 7
permalink: /team-mode/
---

# Agent Teams

> **Level: 🌳 Expert** | **Source:** [Agent Teams](https://docs.anthropic.com/en/docs/claude-code/agent-teams)

[← Back to Automating Your Workflows](../intermediate/automating-your-workflows.md)

Agent teams let you coordinate multiple Claude Code instances working together on a complex task. One session acts as the lead, and teammates work independently in their own context windows — but unlike [sub agents](sub-agents.md), teammates can communicate directly with each other, share a task list, and self-coordinate.

> **Note:** Agent teams are experimental and disabled by default. Enable them in your settings before use.

---

## When to Use Agent Teams

Agent teams shine when parallel workers need to *interact* — not just deliver results independently, but discuss, challenge, and coordinate:

- **Research and review**: Multiple teammates investigate different aspects of a problem, then share and challenge each other's findings
- **Competing hypotheses**: Teammates test different theories in parallel and debate to converge on the answer
- **New modules or features**: Each teammate owns a separate piece, coordinating at the boundaries
- **Cross-layer coordination**: Changes that span frontend, backend, and tests, each owned by a different teammate

### Agent Teams vs Sub Agents

Both spawn parallel workers, but they differ in how those workers communicate:

| | [Sub Agents](sub-agents.md) | Agent Teams |
|---|---|---|
| **Communication** | One-way: report results back to the main agent | Multi-way: shared task list + direct messaging between teammates |
| **Context** | Own context window, results summarized back | Own context window, fully independent sessions |
| **Coordination** | Main agent manages all work | Teammates self-coordinate, claim tasks, message each other |
| **Can talk to each other?** | No — helpers never see each other | Yes — teammates message each other directly |
| **Token cost** | Lower: results summarized back | Higher: each teammate is a separate Claude instance |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |

Use sub agents when you need quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

Agent teams add significant coordination overhead and token cost. For sequential tasks, same-file edits, or work with heavy dependencies, a single session or sub agents is more effective.

---

## Getting Started

### Enable agent teams

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

Claude creates the team, spawns teammates, and coordinates work. You can specify count and model:

```
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

---

## Display Modes

**In-process** (default): All teammates run inside your main terminal. Use `Shift+Down` to cycle through teammates and type to message them directly. Works in any terminal.

**Split panes**: Each teammate gets its own pane via `tmux` or iTerm2. You can see everyone's output at once and click into a pane to interact directly.

Configure in settings:

```json
{
  "teammateMode": "in-process"
}
```

Or per session: `claude --teammate-mode in-process`

The default is "auto" — uses split panes if you're already in a tmux session, in-process otherwise.

---

## Interacting with the Team

**Message teammates directly**: In in-process mode, use `Shift+Down` to cycle through teammates, then type. Press `Enter` to view a teammate's session, `Escape` to interrupt their current turn. In split-pane mode, click into a teammate's pane.

**View the task list**: Press `Ctrl+T` to toggle the shared task list.

**Require plan approval**: For risky tasks, require teammates to plan before implementing:

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

The teammate works in read-only plan mode until the lead approves. The lead makes approval decisions autonomously — influence its judgment through your prompt: "only approve plans that include test coverage."

---

## Task Coordination

The shared task list is how work is organized. Tasks have three states: pending, in progress, and completed. Tasks can depend on other tasks — a pending task with unresolved dependencies can't be claimed until those dependencies are completed.

The lead creates tasks and teammates work through them. After finishing a task, a teammate picks up the next unassigned, unblocked task automatically. The lead can also assign tasks explicitly.

Task claiming uses file locking to prevent race conditions when multiple teammates try to claim the same task.

---

## Quality Gates with Hooks

Use [hooks](../intermediate/hooks.md) to enforce rules when teammates finish work:

- **TeammateIdle**: Fires when a teammate is about to go idle. Exit with code 2 to send feedback and keep the teammate working.
- **TaskCompleted**: Fires when a task is being marked complete. Exit with code 2 to prevent completion and send feedback.

---

## Shutting Down

Shut down individual teammates:

```
Ask the researcher teammate to shut down
```

Clean up the entire team when done:

```
Clean up the team
```

Always use the lead to clean up. The lead checks for active teammates and fails if any are still running, so shut them down first. Teammates should not run cleanup themselves.

---

## Best Practices

**Give teammates enough context.** Teammates load project context automatically (CLAUDE.md, MCP servers, skills) but don't inherit the lead's conversation history. Include task-specific details in the spawn prompt.

**Start with 3–5 teammates.** This balances parallel work with manageable coordination. Aim for 5–6 tasks per teammate. Scale up only when work genuinely benefits from more parallelism.

**Size tasks appropriately.** Too small and coordination overhead exceeds the benefit. Too large and teammates work too long without check-ins. Aim for self-contained units that produce a clear deliverable.

**Avoid file conflicts.** Two teammates editing the same file leads to overwrites. Use [worktree isolation](sub-agents.md#worktree-isolation-for-parallel-work) or break work so each teammate owns different files.

**Monitor and steer.** Check in on progress, redirect approaches that aren't working. Unattended teams risk wasted effort.

**Start with research and review.** If you're new to agent teams, begin with read-only tasks — reviewing a PR, researching a library, investigating a bug. These show the value of parallel exploration with less coordination risk.

---

## Troubleshooting

**Teammates not appearing**: In in-process mode, press `Shift+Down` — they may be running but not visible. Check that your task warranted a team.

**Too many permission prompts**: Pre-approve common operations in your permission settings before spawning teammates.

**Lead finishes before teammates**: Tell it: "Wait for your teammates to complete their tasks before proceeding."

**Lead does work instead of delegating**: Tell it: "Wait for your teammates to complete their tasks before proceeding."

**Orphaned tmux sessions**: `tmux ls` then `tmux kill-session -t <name>`.

**Current limitations**: No session resumption with in-process teammates, one team per session, no nested teams (teammates can't spawn their own teams), lead is fixed for the session's lifetime, split panes require tmux or iTerm2.

---

## Next Steps

- See [Sub Agents](sub-agents.md) for focused delegation and worktree isolation
- See [Hooks](../intermediate/hooks.md) for TeammateIdle and TaskCompleted quality gates
- See [Automating Your Workflows](../intermediate/automating-your-workflows.md) for the full automation overview
- See the [official agent teams docs](https://code.claude.com/docs/en/agent-teams) for the complete reference
