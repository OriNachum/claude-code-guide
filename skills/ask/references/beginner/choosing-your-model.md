---
title: "Choosing Your Model"
parent: "Getting Started"
nav_order: 3
permalink: /choosing-your-model/
---

# Choosing Your Model

> **Level: 🌱 Beginner** | **Source:** [Model Config](https://docs.anthropic.com/en/docs/claude-code/model-config), [Fast Mode](https://docs.anthropic.com/en/docs/claude-code/fast-mode)

[← Back to Automating Your Workflows](../intermediate/automating-your-workflows.md)

Claude Code lets you switch between models at any time. Each model has different strengths in speed, cost, and reasoning depth. Additionally, Opus 4.6 and Sonnet 4.6 support **effort levels** that control how much thinking the model does before responding.

## The Models at a Glance

| Model | Speed | Reasoning | Cost | Best for |
|---|---|---|---|---|
| **Haiku** | Fastest | Good | Lowest | Quick lookups, simple edits, exploratory searches, sub agents doing basic research |
| **Sonnet 4.6** | Fast | Strong | Medium | Daily coding — writing features, fixing bugs, refactoring, test generation |
| **Opus 4.6** | Slower | Deepest | Highest | Complex architecture, subtle bugs, multi-file reasoning, nuanced code review |

## How to Switch Models

- **During a session**: `/model sonnet`, `/model opus`, `/model haiku`
- **At startup**: `claude --model opus`
- **Keyboard shortcut**: `Option+P` (macOS) or `Alt+P` (Windows/Linux)
- **Permanently**: Set `"model": "opus"` in your settings file

## Effort Levels (Adaptive Reasoning)

Opus 4.6 and Sonnet 4.6 support **effort levels** that control how deeply the model thinks before responding. This is the primary knob for tuning the speed-vs-quality tradeoff.

| Effort | Thinking depth | Speed | When to use |
|---|---|---|---|
| **Low** | Minimal reasoning | Fastest | Straightforward tasks: rename a variable, add a log line, simple questions |
| **Medium** (Opus default) | Balanced reasoning | Moderate | Most daily work: implement features, fix known bugs, write tests |
| **High** | Deep reasoning | Slowest | Hard problems: architectural design, subtle bugs, complex multi-file changes |

### How to set effort level

- **In /model**: use left/right arrow keys to adjust the effort slider
- **Environment variable**: `export CLAUDE_CODE_EFFORT_LEVEL=low|medium|high`
- **Settings file**: set `"effortLevel": "medium"` in your settings
- **One-off deep thinking**: type "ultrathink" anywhere in your prompt to set effort to high for that single turn

## When to Use Each Model

### Use Haiku when...

- You need a quick answer and don't need deep reasoning
- You're doing exploratory searches across a large codebase
- You want a fast, cheap sub agent for file discovery and code search
- You're running many parallel non-interactive queries in scripts
- The task is simple: "what does this function return?", "find files matching X"

**Example**: Claude's built-in **Explore** sub agent uses Haiku because it only needs to search and read files — it doesn't need to reason deeply.

### Use Sonnet 4.6 when...

- You're doing daily coding work: writing features, fixing bugs, refactoring
- You want a good balance of speed and quality
- You're running tests and iterating on fixes
- You need to generate boilerplate or write documentation
- You're working on a focused task with a clear scope

**Example**: Most developers use Sonnet as their default model. It handles the majority of coding tasks well and responds fast enough to keep you in flow.

### Use Opus 4.6 when...

- You're working on a hard problem that requires deep reasoning
- You need to understand complex relationships across many files
- You're designing architecture or making decisions with many tradeoffs
- You're debugging a subtle issue where the root cause isn't obvious
- You're reviewing code for security vulnerabilities or correctness
- You need Claude to self-correct and catch its own mistakes

**Example**: When planning a multi-service migration, Opus can reason through dependencies, ordering constraints, and rollback strategies that Sonnet might miss.

### Use the `opusplan` alias when...

- You want the best of both worlds: deep reasoning for planning, fast execution for coding
- You're following the "explore → plan → implement" workflow
- You want Opus quality during Plan Mode, then automatic switch to Sonnet for implementation

**How it works**: In Plan Mode, `opusplan` uses Opus. When you switch to Normal Mode and start implementing, it automatically switches to Sonnet.

```bash
claude --model opusplan
```

## Thinking About Effort + Model Together

Here's how to think about combining model choice and effort level:

| Scenario | Recommended setup | Why |
|---|---|---|
| Quick file lookup | Haiku | Fast and cheap; no deep reasoning needed |
| Rename a variable across files | Sonnet + low effort | Simple task, Sonnet is plenty capable |
| Implement a new API endpoint | Sonnet + medium effort | Standard feature work |
| Debug a race condition | Opus + medium effort | Needs deeper reasoning to trace concurrent paths |
| Design a caching strategy | Opus + high effort | Complex tradeoffs, needs thorough analysis |
| Review code for security issues | Opus + high effort | Subtle issues require careful examination |
| Generate test boilerplate | Sonnet + low effort | Repetitive, well-defined task |
| Understand unfamiliar codebase | Sonnet + medium effort (or Haiku sub agent) | Balances thoroughness with speed |

## Practical Tips

**Start with Sonnet, escalate to Opus.** Most tasks don't need Opus. If Sonnet struggles — produces incorrect code, misses edge cases, or can't reason through the problem — switch to Opus for that task, then switch back.

**Use effort levels before switching models.** Before jumping from Sonnet to Opus, try increasing Sonnet's effort level to high first. It might be enough, and it's faster and cheaper than Opus.

**Use "ultrathink" for one-off hard prompts.** If you have a single complex question in an otherwise routine session, type "ultrathink" in your prompt instead of changing your model or effort settings permanently.

**Match model to sub agent purpose.** When creating custom sub agents, consider their purpose:
- Explorers and searchers → `model: haiku`
- Code writers and fixers → `model: sonnet` or `model: inherit`
- Reviewers and architects → `model: opus`

**Extended context (1M tokens).** For very long sessions with large codebases, Opus 4.6 and Sonnet 4.6 support a 1 million token context window. Use `sonnet[1m]` or `opus[1m]` aliases.

## Default Model Behavior by Plan

Your default model depends on your subscription:

| Plan | Default model |
|---|---|
| Max / Team Premium | Opus 4.6 |
| Pro / Team Standard | Sonnet 4.6 |
| Enterprise | Opus 4.6 available, not default |
| API / Pay-as-you-go | You choose |

Claude Code may automatically fall back to Sonnet if you hit an Opus usage threshold.

## Next Steps

- Run `/model` to see available models and adjust effort levels
- Try `opusplan` for your next planning session
- See the [official model configuration docs](https://code.claude.com/docs/en/model-config) for environment variables and enterprise settings
- Read [Starting to Work](starting-to-work.md) for how to choose your permission mode
