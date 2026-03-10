---
title: "Auto-Maintain CLAUDE.md"
parent: "User Stories"
nav_order: 4
permalink: /stories/auto-maintain-claude-md/
---

# Automated CLAUDE.md Maintenance with GitHub Actions

> **Level: 🌿 Intermediate** | **Related:** [GitHub Actions](https://docs.anthropic.com/en/docs/claude-code/github-actions)

[← Back to References](expert/ongoing-work.md)

## The Scenario

Your team has been using Claude Code for a few months. The `CLAUDE.md` is solid — it documents the tech stack, project structure, test commands, and key conventions. But the codebase evolves daily: new modules appear, dependencies get updated, conventions shift. `CLAUDE.md` is starting to drift from reality. You want an automated process that checks freshness weekly and proposes updates.

---

## The Walkthrough

### Step 1: Understand What Drifts

Before automating, you think about what actually goes stale in a `CLAUDE.md`:

- **Project structure** — new directories and files appear that aren't in the structure tree
- **Dependencies** — packages get added or upgraded that change the tech stack description
- **Test commands** — test scripts change in `package.json` or `Makefile`
- **Conventions** — the team adopts new patterns that aren't documented

Not everything drifts at the same rate. Structure and dependencies change frequently; high-level conventions are more stable.

### Step 2: Set Up the GitHub Action

You create a workflow that runs Claude Code in CI to audit `CLAUDE.md`:

```yaml
# .github/workflows/claude-md-freshness.yml
name: CLAUDE.md Freshness Check

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM
  workflow_dispatch:       # Manual trigger for testing

jobs:
  check-freshness:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          model: sonnet
          prompt: |
            Review CLAUDE.md for freshness. Compare it against the actual codebase:

            1. Check the project structure tree — are there new directories or files not listed?
            2. Check package.json/requirements.txt — has the tech stack description drifted?
            3. Check test scripts — are the documented test commands still correct?
            4. Check recent commits (last 50) — are there new conventions or patterns not documented?

            If you find drift, create a PR with the updates. If CLAUDE.md is current, comment on the workflow run that no changes are needed.
          allowed_tools: "Read,Glob,Grep,Write,Edit,Bash(git log:*),Bash(cat:*)"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

> **What's Happening:** [GitHub Actions with Claude Code](intermediate/github-actions.md) lets you run Claude as an automated process. The `allowed_tools` parameter scopes what Claude can do — read files, search, and write updates, but nothing destructive. Using Sonnet keeps costs low for a weekly maintenance job.

### Step 3: Scope the Audit Carefully

The prompt above is deliberate in what it checks. You're not asking Claude to "update CLAUDE.md" — you're asking it to check specific categories of drift. This matters because:

- Vague prompts lead to unnecessary rewrites
- Specific checks produce targeted, reviewable diffs
- You can add or remove check categories over time

If your team has specific sections that drift more, you add them explicitly:

```
5. Check the "API Routes" section — are all route files in src/routes/ documented?
6. Check the "Environment Variables" section — are all vars in .env.example listed?
```

> **What's Happening:** This follows the [best practice](intermediate/best-practices.md) of giving Claude clear success criteria. "Check X against Y" is much more reliable than "make sure everything is up to date."

### Step 4: Review the PRs

Every Monday, you get one of two outcomes:

1. **No drift detected** — the action logs that CLAUDE.md is current. No PR.
2. **Drift found** — you get a PR with targeted updates. The diff shows exactly what changed and why.

You review the PR like any other code change. Sometimes Claude's updates are perfect — a new directory was added and it updates the structure tree. Sometimes it over-corrects — it might try to add a dependency that's only used in dev. You adjust and merge.

Over time, the PRs get more accurate as Claude learns from what you accept and reject (through the conventions you add to `CLAUDE.md` about what level of detail to include).

### Step 5: Extend to Other Documentation

Once the pattern works for `CLAUDE.md`, you apply it to other documentation:

```yaml
      - uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Check these documentation files for freshness:
            1. CLAUDE.md — project context for AI agents
            2. docs/API.md — API reference
            3. CONTRIBUTING.md — contributor guide

            For each file, compare against the actual codebase and flag any drift.
```

> **What's Happening:** [Ongoing work automation](expert/ongoing-work.md) extends naturally once you have the pattern. The same freshness-check approach works for any documentation that should stay in sync with code.

### Step 6: Add a Staleness Badge (Optional)

For visibility, you add a badge to your README that shows when `CLAUDE.md` was last verified:

```markdown
![CLAUDE.md freshness](https://github.com/your-org/your-repo/actions/workflows/claude-md-freshness.yml/badge.svg)
```

The team can see at a glance whether the documentation is current.

---

## Key Takeaways

- **CLAUDE.md drifts naturally** — automated maintenance prevents gradual decay without requiring human attention.
- **Check specific categories, not everything.** Scoped audits produce better, more reviewable results than open-ended "update this file" prompts.
- **Use Sonnet for maintenance tasks.** Weekly audits don't need Opus-level reasoning — Sonnet is faster and cheaper for structured comparisons.
- **Review the PRs.** Automation proposes, humans approve. The human-in-the-loop ensures quality and catches over-corrections.
- **Extend the pattern.** Once freshness checking works for `CLAUDE.md`, apply it to API docs, contributor guides, and any documentation that should track code changes.
