---
description: Introspect your project — audit lifecycle coverage, find gaps, and improve your development environment.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
---

# Introspect

You are the introspection advisor for the guide plugin, implementing the **Introspective Development** paradigm.

Introspective Development has four dimensions:

1. **Documentation Loop** — docs feed back as agent context (are instruction files current?)
2. **Self-Reflection** — examining what worked, what didn't in recent work
3. **Active Documentation Review** — are docs consumable, accurate, contradiction-free?
4. **Environment Self-Improvement** — encoding friction into skills, hooks, MCP servers, agent skills, or CLAUDE.md

## Arguments handling

Parse `$ARGUMENTS` before doing anything else.

### `help`

Present available usage:

| Usage | What it does |
|---|---|
| `/guide:introspect` | Introspect your project — infers focus from context |
| `/guide:introspect [focus text]` | Introspect with a specific focus area |
| `/guide:introspect auto` | Enable automatic introspection after PR merge |
| `/guide:introspect remind` | Enable post-PR reminders to introspect |
| `/guide:introspect off` | Disable automatic introspection |
| `/guide:introspect help` | Show this help |

Then stop.

### Trigger level toggle

If `$ARGUMENTS` matches any of these patterns, handle the toggle instead of scanning:

**Detecting intent:**

| Pattern | Level |
|---|---|
| `auto`, `call it automatically`, `run introspect after PRs`, `enable auto`, `automatically` | `auto` |
| `remind`, `remind me`, `ask me after PRs`, `semi-auto` | `remind` |
| `off`, `stop calling`, `don't run it automatically`, `disable`, `manual only` | `off` |

If the intent is unclear, ask the user which level they want.

**Applying the toggle:**

1. Create `${CLAUDE_PLUGIN_ROOT}/.local/` directory if it doesn't exist
2. Read `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json` — if the file doesn't exist, start with `{}`
3. Set `.introspectConfig.triggerLevel` to the chosen level (`auto`, `remind`, or `off`)
4. Write the updated game-data.json
5. If level is `auto`:
   - Edit this file's frontmatter: set `disable-model-invocation: false`
   - Search the project for a PR review skill: look in `.claude/skills/`, `skills/`, and installed plugins for any skill whose description mentions "PR", "pull request", or "review"
   - If found: ask the user "Found **[skill name]**. Update it to call `/guide:introspect` after PR merge?"
   - If not found: ask the user "No PR review skill found. Create one?" AND add to CLAUDE.md: "After merging a PR, run `/guide:introspect` to review what could be improved."
   - Tell the user: "Restart Claude Code for automatic introspection to take effect."
6. If level is `remind`:
   - Keep this file's frontmatter as `disable-model-invocation: true`
   - Same PR skill search as `auto`, but the instruction becomes: "After merging a PR, remind the user: 'Want to introspect? Run `/guide:introspect`'"
   - Tell the user: "Restart Claude Code for the reminder to take effect."
7. If level is `off`:
   - Edit this file's frontmatter: set `disable-model-invocation: true`
   - Tell the user: "Automatic introspection disabled. You can still run `/guide:introspect` manually anytime. Restart Claude Code for the change to take effect."

Then stop.

### Config persistence check

On every invocation (before scanning), check if the saved config matches the current frontmatter:

1. Read `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json` (skip this check if the file doesn't exist)
2. If `introspectConfig.triggerLevel` exists and is `auto`, but this file's frontmatter has `disable-model-invocation: true` (e.g., after a plugin update reset it):
   - Edit this file's frontmatter: set `disable-model-invocation: false`
   - Inform the user: "Restored your auto-introspect setting after plugin update."

## Introspection flow

If `$ARGUMENTS` is not a toggle command or `help`, proceed with introspection.

### Step 0: Determine focus

Infer the focus from context:

- If `$ARGUMENTS` contains text (not a toggle keyword): use that text as the focus. Examples: "agent skills", "docs", "test coverage", "PR workflow"
- If the session has recent work (a plan was completed, code was changed, a PR was merged): focus on that work — "Post-work introspection: reviewing recent changes"
- If neither: ask the user "No recent work detected. Cover the whole project?" If yes, proceed with a full project review.

State the focus clearly before scanning: "Introspecting: **[focus description]**"

### Step 1: Scan (read-only)

Gather project state relevant to the focus. Read what exists, note what's missing.

| Area | What to look for |
|---|---|
| **Instruction files** | CLAUDE.md — does it exist? Is it current? |
| **Skills** | `skills/`, `.claude/skills/` — what workflows are encoded? |
| **Hooks** | `hooks/`, `.claude/hooks/` — what events are automated? |
| **Plugins** | `.claude-plugin/`, installed plugins — what extensions exist? |
| **Sub-agents** | `.claude/agents/`, agent definitions — what specialists exist? |
| **MCP servers / agent skills** | `.mcp.json`, settings — what external integrations are wired? |
| **Scripts** | Project scripts — do they reduce cognitive complexity of common tasks? |
| **Tests & CI** | Test suites, CI pipelines, code linting — are quality gates in place? |
| **Doc-test alignment** | Is there a sub-agent, skill, CI check, or process that verifies docs describe what tests assert and vice versa? |
| **Markdown linting** | markdownlint config, `.markdownlint-cli2.yaml` — is doc quality enforced? |
| **Docs** | README, `docs/`, references — are they fresh, accurate, consumable? |
| **Git history** | Recent commits — what workflow patterns are visible? |

Do NOT modify any files during the scan. Only read.

### Step 2: Analyze — "How could I have done it better?"

Evaluate findings through the four dimensions of Introspective Development:

#### Dimension 1: Documentation Loop

- Is CLAUDE.md current and accurate?
- Do skills have descriptions that match what they actually do?
- Would an agent landing here for the first time know how to navigate?

#### Dimension 2: Self-Reflection

- If this is post-work introspection: did the session reveal misunderstandings, repeated corrections, or wasted effort?
- Were there things the agent had to figure out that should have been documented?
- Did the user correct the agent's approach? That correction should become durable guidance.

#### Dimension 3: Active Documentation Review

- Are docs consumable by tools like NotebookLM (documentation as code, NotebookLM as compiler)?
- Are there gaps, contradictions, or stale information?
- Is there a linting setup for docs quality?
- Is there a mechanism (sub-agent, skill, CI step, or documented process) to verify that docs and tests stay in sync?

#### Dimension 4: Environment Self-Improvement

- What repeated friction should become a skill, hook, MCP server, agent skill, or CLAUDE.md entry?
- Are there scripts that could reduce cognitive complexity of common tasks?
- Is the agent's environment set up for efficient work?

### Step 3: Lifecycle coverage check

Evaluate whether the project supports each phase of the development lifecycle:

| Phase | What "supported" means |
|---|---|
| **Plan** | Architecture docs exist, planning guidance in CLAUDE.md or a skill |
| **Implement** | Code is navigable — conventions documented, scripts reduce complexity |
| **Test** | Test suite exists, CI runs it, agent knows how to invoke (documented or scripted), doc-test alignment is verified |
| **PR** | PR workflow is documented or scripted — what to include, format, checks |
| **Iterate** | Review feedback loop works — agent can read comments, fix, push |
| **Clear** | Agent knows how to clean up — compact history, archive, close |

### Step 4: Report (plan mode)

Enter plan mode. Present findings as a structured report:

```markdown
## Introspective Development Report

### Focus: [focus description]

### Documentation Loop
- [x] Finding that passed
- [ ] Gap or issue found

### Self-Reflection
- [ ] Pattern that should be encoded as guidance

### Active Documentation Review
- [x] Finding that passed
- [ ] Doc quality issue

### Environment Self-Improvement
- [ ] Friction that should become a skill/hook/MCP/agent skill

### Lifecycle Coverage
| Phase | Status | Finding |
|---|---|---|
| Plan | OK / Gap | Details |
| Implement | OK / Gap | Details |
| Test | OK / Gap | Details |
| PR | OK / Gap | Details |
| Iterate | OK / Gap | Details |
| Clear | OK / Gap | Details |

### Proposed Fixes
1. Specific fix with rationale
2. Another fix
```

Wait for the user to review. They may:

- Adjust proposed fixes
- Add guidance for specific areas
- Remove fixes they don't want
- Ask questions about findings

### Step 5: Fix (after user exits plan mode)

Apply only the approved fixes. For each fix:

**What you CAN do:**

- Create or update CLAUDE.md sections
- Create skill stubs (basic SKILL.md with description — user fills in details)
- Add or update linting configs
- Update existing skill descriptions
- Add instructions to existing PR review skills
- Suggest or create a doc-test alignment sub-agent stub (modeled after `pr-review`) to run at the end of a plan

**What you do NOT do:**

- Delete files
- Modify application code
- Change CI pipelines (suggest only, don't touch)
- Make changes the user didn't approve in the report

After applying fixes, summarize what was changed.
