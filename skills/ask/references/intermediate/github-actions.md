---
title: "GitHub Actions"
parent: "CI/CD"
nav_order: 1
permalink: /github-actions/
---

# GitHub Actions

> **Level: 🌿 Intermediate** | **Source:** [GitHub Actions](https://docs.anthropic.com/en/docs/claude-code/github-actions)

[← Back to Automating Your Workflows](automating-your-workflows.md)

GitHub Actions is the primary way to run Claude Code in CI/CD pipelines. Using the [`anthropics/claude-code-action`](https://github.com/anthropics/claude-code-action) action, you can have Claude review PRs, triage issues, run scheduled maintenance, and more — all without a human in the loop.

**Important:** GitHub Actions is NOT a fourth automation mechanism. It's a **deployment environment** — the three automation mechanisms (Hooks, Skills, Sub Agents) work the same way whether Claude runs on your laptop or in a CI pipeline.

---

## When to Use

- **PR review** — Claude reviews every pull request automatically
- **Scheduled maintenance** — periodic doc freshness checks, configuration audits, dependency updates
- **Issue triage** — Claude classifies, labels, and responds to new issues
- **CI validation** — Claude verifies code quality, documentation accuracy, or convention compliance
- **Manual triggers** — on-demand tasks via `workflow_dispatch`

---

## Key Concepts

### claude-code-action

The [`anthropics/claude-code-action`](https://github.com/anthropics/claude-code-action) GitHub Action wraps the Claude Code CLI for use in workflows. It handles authentication, permissions, and output formatting.

### Triggers

GitHub Actions workflows can fire on many events. The most common for Claude Code:

| Trigger | Use case |
|---|---|
| `pull_request` | Review PRs, validate changes, suggest fixes |
| `issues` (opened) | Triage, classify, or respond to new issues |
| `issue_comment` | Respond to comments mentioning Claude |
| `schedule` (cron) | Recurring maintenance tasks |
| `workflow_dispatch` | Manual one-off runs |

### Two Permission Layers

Claude Code in GitHub Actions has two independent permission layers:

1. **GitHub token permissions** — what the workflow can do in GitHub (read/write code, PRs, issues). Set via the `permissions:` block in your workflow YAML.
2. **Claude tool permissions** — what Claude is allowed to do (which tools it can call). Set via the `settings` input or by using `--dangerously-skip-permissions` in `claude_args` (see [Starting to Work](../beginner/starting-to-work.md) for context on this flag).

### Model Selection for Cost

Use the `claude_args` input to select a model. For high-volume tasks like PR review, consider using Sonnet to manage costs:

```yaml
claude_args: "--model sonnet"
```

See [Choosing Your Model](../beginner/choosing-your-model.md) for model trade-offs.

### v1 Breaking Changes

If migrating from a pre-v1 workflow, note these changes in `claude-code-action@v1`:

- `direct_prompt` renamed to `prompt`
- `mode` removed (auto-detected)
- `max_turns`, `model`, `custom_instructions` moved to `claude_args`

---

## Getting Started

A minimal workflow that reviews every pull request:

```yaml
name: Claude PR Review

on:
  pull_request:

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude_args: "--model sonnet"
          prompt: |
            Review this pull request. Focus on:
            - Correctness and potential bugs
            - Security concerns
            - Code clarity
            Post your review as a PR comment.
```

---

## Common Patterns

### Scheduled Doc Freshness Check

This repo uses a real example of this pattern in `.github/workflows/docs-freshness.yml`. The workflow runs on a cron schedule, compares reference docs against official sources, and opens a PR if anything is outdated:

```yaml
name: Docs Freshness Check

on:
  schedule:
    - cron: "0 6 * * 1-5"   # Weekdays at 06:00 UTC
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write
  issues: write

jobs:
  check-freshness:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude_args: "--model sonnet"
          prompt: |
            Compare our docs against official sources.
            If anything is outdated, fix it and open a PR.
```

See [Ongoing Work](../expert/ongoing-work.md) for more automated maintenance strategies.

### PR Review on Every Pull Request

```yaml
on:
  pull_request:
    types: [opened, synchronize]

# ... same action setup as Getting Started above
```

### Issue Triage

```yaml
on:
  issues:
    types: [opened]

permissions:
  issues: write

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude_args: "--model sonnet"
          prompt: |
            Read the new issue and:
            1. Add appropriate labels
            2. If it's a bug report, check if you can reproduce the description
            3. Post a helpful initial response
```

---

## Configuration Reference

Key inputs for `anthropics/claude-code-action`:

| Input | Description |
|---|---|
| `anthropic_api_key` | Anthropic Console API key |
| `claude_code_oauth_token` | Claude Code subscription OAuth token (requires `@v1.0.25`+) |
| `claude_args` | CLI arguments passed to Claude Code (e.g., `--model sonnet`) |
| `prompt` | The prompt Claude receives for this workflow run |
| `settings` | JSON string with Claude Code settings (e.g., tool permissions) |
| `show_full_output` | Show Claude's full reasoning in the workflow log (`true`/`false`) |

---

## 🌳 Security Considerations

- **Store secrets securely.** Use GitHub repository secrets for API keys — never hardcode them in workflow files.
- **Scope GitHub permissions tightly.** Only grant the permissions the workflow actually needs (e.g., `contents: read` if Claude doesn't need to push).
- **Use `--dangerously-skip-permissions` carefully.** In CI, this flag is common because there's no human to approve tool calls. But understand that it gives Claude unrestricted tool access within the workflow's GitHub permissions.
- **Use the `settings` input for tool restrictions.** You can allow or deny specific tools via the settings JSON instead of skipping all permissions.

---

## A Note on Other Integrations

- **`/install-github-app`** is a different integration — it installs an interactive GitHub App that responds to @mentions in PRs and issues. GitHub Actions workflows are separate and give you more control over triggers and prompts.
- **Other CI systems** (GitLab CI, Jenkins, CircleCI, etc.) can run Claude Code directly via the CLI rather than the GitHub Action wrapper. The concepts (authentication, permissions, prompts) are the same.

---

## Next Steps

- See [Ongoing Work](../expert/ongoing-work.md) for automated maintenance strategies that use GitHub Actions
- See [Automating Your Workflows](automating-your-workflows.md) for the three automation mechanisms that work the same in CI
- See [Hooks](hooks.md) for lifecycle automation that fires in CI just like locally
