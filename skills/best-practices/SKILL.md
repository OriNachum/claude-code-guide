---
description: Key patterns that make Claude Code dramatically more effective — self-testing loops, context management, specificity, and course-correction. Use before starting a complex task or when results feel inconsistent.
disable-model-invocation: true
---

# Best Practices for Working with Claude Code

You are coaching a developer on the patterns that separate productive Claude Code sessions from frustrating ones. Apply these principles to whatever they're currently working on.

## Give Claude a way to self-test

This is the single highest-leverage practice. Claude performs dramatically better when it can verify its own work.

**The self-testing loop:** write code → run it → check the result → improve → repeat.

Help the developer set this up for their current task:
1. **Define success criteria** — ask: "What does 'working' look like for this task?" Write the criteria in a Markdown file (e.g., `CRITERIA.md`) so Claude can re-read it across iterations.
2. **Give Claude a run command** — not just unit tests. The actual program: "Build this CLI tool, then run it with these inputs and verify the output matches."
3. **Let Claude compare results to expectations** — provide concrete examples of expected output, screenshots, or specific behaviors.
4. **Let Claude iterate on failures** — Claude should read the error, understand it, fix the code, and try again without human intervention.

The Markdown criteria file is key: as context fills up, Claude can re-read the file to stay on track rather than drifting from the original goal.

## Be specific, not vague

Show the developer the specificity spectrum:

❌ Vague: "Fix the tests"
✅ Specific: "The user registration test in tests/auth.test.ts fails because the mock database doesn't return the expected user object. The test expects `{id, email, name}` but gets `{id, email}`. Fix the mock setup."

❌ Vague: "Make the UI better"
✅ Specific: "The settings page loads slowly because it fetches all user data on mount. Refactor to lazy-load the preferences tab content only when the tab is clicked."

Help them rewrite their current task description to be more specific.

## Manage context deliberately

Claude's context window fills up fast. Every file read, every command output, every message consumes context. When it fills, performance degrades.

Teach these techniques:
- **Start sessions with a clear, specific task** — not open-ended exploration
- **Use `/compact` when context gets heavy** — `/compact Focus on the API changes` preserves what matters
- **Break large tasks into focused sessions** — one session per logical unit of work
- **Front-load important context** — put key information in the first message, not buried in a long conversation
- **Let Claude interview you** — for complex features, start with: "Interview me in detail about [feature]. Ask about technical implementation, edge cases, and tradeoffs. Don't ask obvious questions."

## Course-correct early

Don't wait for Claude to finish to give feedback:
- **`Esc`** — stop immediately, context preserved
- **Type while Claude works** — add corrections, specificity, or new requirements mid-flight. Claude reads and incorporates them without breaking flow.
- **Start fresh after two failed corrections** — a clean session with a better prompt almost always outperforms accumulated corrections

## Improve your CLAUDE.md over time

After each session, notice:
- Did Claude make assumptions you had to correct? → Add that context to CLAUDE.md
- Did Claude use the wrong pattern? → Add your preferred pattern
- Did Claude miss a convention? → Document it

CLAUDE.md compounds — each improvement makes every future session better.

## Related skills

Suggest these next steps based on what the developer needs:
- `/onboarding:automate` — when they find themselves repeating the same instructions
- `/onboarding:configure` — for ongoing CLAUDE.md and settings refinement
- `/onboarding:setup` — if they haven't done initial setup yet
