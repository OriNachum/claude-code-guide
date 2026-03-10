---
title: "Best Practices"
parent: "Getting Started"
nav_order: 4
permalink: /best-practices/
---

# Best Practices

> **Level: 🌿 Intermediate** | **Source:** [Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)

[← Back to Automating Your Workflows](automating-your-workflows.md)

Claude Code is an autonomous agent, not a chatbot. It reads files, runs commands, modifies code, and works through problems while you watch, redirect, or step away. Getting the most out of it means understanding one fundamental constraint: **Claude's context window fills up fast, and performance degrades as it fills.** Every file Claude reads, every command output, every message — it all consumes context. The practices below help you work within that constraint and get dramatically better results.

---

## Give Claude a Way to Self-Test

This is the single highest-leverage thing you can do. Claude performs dramatically better when it can verify its own work — run tests, execute code, compare output, and iterate until it's correct. Without verification, you become the only feedback loop.

### Beyond unit tests: the self-testing loop

Unit tests are valuable, but they're only one type of verification. The most effective pattern is giving Claude a **full feedback loop**: write code, run it, check the result, improve, repeat. This means Claude should be able to:

- **Run the code it writes** — not just tests, but the actual program. "Build this CLI tool, then run it with these inputs and verify the output matches."
- **Compare results to expectations** — provide concrete examples of what success looks like: expected outputs, screenshots, specific behaviors.
- **Iterate on its own failures** — when something doesn't work, Claude should be able to read the error, understand it, fix the code, and try again without your intervention.
- **Check itself across iterations** — keep success criteria in a Markdown file that Claude re-reads after each attempt, so it doesn't drift from the goal as context fills up.

### Write success criteria in Markdown

For any non-trivial task, write the acceptance criteria in a Markdown file and tell Claude to reference it. This solves the problem of Claude "forgetting" what it was trying to achieve after several iterations of editing and debugging.

```
Write the acceptance criteria for this feature to docs/criteria.md, then implement it.
After each change, re-read docs/criteria.md and verify each criterion is met.
Don't stop until all criteria pass.
```

Why Markdown? Because it's a file Claude can read at any point — even after context compaction. Criteria in a prompt get lost as the conversation grows. Criteria in a file persist and can be re-read every iteration.

### Verification strategies

| Strategy | Example |
|---|---|
| **Run the code** | "Build the parser, then run it on test-input.json and verify the output matches expected-output.json" |
| **Visual comparison** | "Implement this design [screenshot]. Take a screenshot of the result and compare. List differences and fix them." |
| **Test suite** | "Write tests first, then implement until all tests pass" |
| **Lint and type-check** | "Run `npm run lint` and `npm run typecheck` after every change" |
| **End-to-end check** | "Start the server, curl the /health endpoint, verify it returns 200" |
| **Criteria file** | "Read CRITERIA.md after each iteration and check off completed items" |

The more ways Claude can self-check, the less you need to intervene.

---

## Explore First, Then Plan, Then Code

Letting Claude jump straight to coding often produces code that solves the wrong problem. Separate the phases:

**1. Explore** — Enter [Plan Mode](../beginner/starting-to-work.md). Claude reads files and answers questions without making changes. "Read `/src/auth` and understand how we handle sessions."

**2. Plan** — Ask Claude to create a detailed implementation plan. Press `Ctrl+G` to open the plan in your text editor for direct editing before Claude proceeds.

**3. Implement** — Switch to Normal Mode and let Claude code against its plan, verifying as it goes.

**4. Commit** — Ask Claude to commit with a descriptive message and create a PR.

Skip the plan when the task is small and the scope is clear. Planning adds overhead. If you could describe the diff in one sentence, just do it directly.

---

## Be Specific in Your Prompts

The more precise your instructions, the fewer corrections you'll need. Claude can infer intent, but it can't read your mind.

**Scope the task**: "Write a test for `foo.py` covering the edge case where the user is logged out. Avoid mocks." — not "add tests for foo.py."

**Point to sources**: "Look through `ExecutionFactory`'s git history and summarize how its API came to be." — not "why does ExecutionFactory have a weird API?"

**Reference existing patterns**: "Look at how existing widgets are implemented. `HotDogWidget.php` is a good example. Follow the pattern." — not "add a calendar widget."

**Describe symptoms clearly**: "Users report login fails after session timeout. Check the auth flow in `src/auth/`, especially token refresh. Write a failing test that reproduces the issue, then fix it." — not "fix the login bug."

Vague prompts are fine when you're exploring and can afford to course-correct.

---

## Manage Context Aggressively

Context is your most important resource. Track it with a custom status line and protect it actively.

**`/clear` between unrelated tasks.** A session about debugging auth followed by questions about the build system pollutes context with irrelevant information.

**Use sub agents for investigation.** When Claude needs to explore the codebase, delegate to a [sub agent](../expert/sub-agents.md). It explores in its own context window and reports back a summary, keeping your main conversation clean.

**Rewind instead of correcting repeatedly.** If you've corrected Claude more than twice on the same issue, context is cluttered with failed approaches. Press `Esc` twice or run `/rewind`, then start fresh with a better prompt that incorporates what you learned.

**Scope investigations narrowly.** "Read the auth module and explain how token refresh works" — not "investigate the authentication system." Open-ended exploration fills context fast.

**Use `/compact` with instructions.** Run `/compact Focus on the API changes` to compress the conversation while preserving specific context you care about.

---

## Course-Correct Early and Often

Don't wait for Claude to finish before redirecting. Tight feedback loops produce better results than letting Claude run unchecked.

**`Esc`** — Stop Claude mid-action. Context is preserved, so you can redirect immediately.

**`Esc + Esc` or `/rewind`** — Open the rewind menu to restore previous conversation and code state.

**"Undo that"** — Have Claude revert its changes.

**Start fresh after two failed corrections.** A clean session with a better prompt almost always outperforms a long session with accumulated corrections.

### Guide While It Works

You don't have to stop Claude to steer it. While Claude is actively working, you can type additional messages — corrections, added specificity, or new requirements — and Claude will read them and incorporate them into its ongoing work. This lets you refine direction in real-time without breaking its flow.

Think of it like giving guidance to someone while they're building, rather than waiting for the final result to critique it. Spotted a wrong approach three files in? Add a note. Want it to also handle an edge case it hasn't considered? Mention it. Claude adjusts mid-flight.

---

## Let Claude Interview You

For larger features, have Claude interview you before it starts. It will ask about things you might not have considered — edge cases, tradeoffs, UI/UX decisions:

```
I want to build [brief description]. Interview me in detail using AskUserQuestion.
Ask about technical implementation, UI/UX, edge cases, and tradeoffs.
Don't ask obvious questions — dig into the hard parts.
Keep interviewing until we've covered everything, then write a complete spec to SPEC.md.
```

Once the spec is complete, start a fresh session to execute it. The new session has clean context focused entirely on implementation, and you have a written spec to reference.

---

## Write an Effective CLAUDE.md

Run `/init` to generate a starter file, then refine. CLAUDE.md is loaded every session, so keep it concise — only include things that apply broadly and that Claude can't figure out by reading code.

**Include**: Build and test commands, coding style rules that differ from defaults, testing preferences, repo conventions, common gotchas.

**Exclude**: Anything Claude can figure out by reading code, standard language conventions, long explanations (link to docs instead), information that changes frequently.

If Claude keeps ignoring a rule, the file is probably too long. Treat it like code: prune regularly, and test changes by observing whether Claude's behavior shifts.

---

## Common Failure Patterns

**The kitchen sink session.** You start with one task, ask something unrelated, then go back. Context is polluted. Fix: `/clear` between unrelated tasks.

**Correcting over and over.** Claude does something wrong, you correct, still wrong, correct again. Fix: After two corrections, `/clear` and write a better initial prompt.

**The over-specified CLAUDE.md.** Too long, Claude ignores half of it. Fix: Ruthlessly prune. If Claude already does something correctly without the instruction, delete it.

**The trust-then-verify gap.** Claude produces plausible code that doesn't handle edge cases. Fix: Always provide verification — tests, scripts, screenshots. If you can't verify it, don't ship it.

**The infinite exploration.** You ask Claude to "investigate" without scoping. Claude reads hundreds of files, filling context. Fix: Scope narrowly or use sub agents.

---

## Next Steps

- See [Setting Your Environment](../beginner/setting-your-environment.md) for initial setup (CLAUDE.md, permissions, model selection)
- See [Starting to Work](../beginner/starting-to-work.md) for when to use Plan Mode, Accept Edits, and Normal mode
- See [Automating Your Workflows](automating-your-workflows.md) for hooks, skills, and sub agents
- See [Configuring Your Claude](configuring-your-claude.md) for building your automation over time
- See the [official best practices](https://code.claude.com/docs/en/best-practices) for the complete reference
