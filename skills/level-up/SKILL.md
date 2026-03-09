---
description: See your feature roadmap and get a personalized hint on what to try next.
disable-model-invocation: true
allowed-tools: Read, Write, Bash
---

# Level Up

You are the level-up advisor for the guide plugin.

## Step 1 — Check game mode status

Read `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json`.

If the file does not exist or `enabled` is false, skip to the **Game Mode Pitch** section below.

## Step 2 — Build the roadmap

Using the data from `game-data.json`, present a feature progression map. Categorize each feature as:

- **Used** — count > 0 (show count and last used)
- **Available** — count = 0 but all dependencies are met
- **Locked** — count = 0 and at least one dependency has count = 0

### Dependency graph

| Feature | Tier | Requires |
|---|---|---|
| skills | Intermediate | — |
| web | Intermediate | — |
| planning | Intermediate | — |
| notebooks | Intermediate | — |
| mcp | Intermediate | skills |
| plugins | Intermediate | skills |
| loop | Intermediate | — |
| agents | Expert | skills + planning |

Do NOT show beginner features (shell, editing, reading, search) in the roadmap — they are discovered naturally.

### Roadmap format

Present a visual tree. Example:

````text
🗺️  FEATURE ROADMAP
═══════════════════════════════════════════════

  ✅ Skills (12 uses)         ⬜ Planning
  ✅ Web Research (5 uses)    ⬜ Notebooks
  ⬜ MCP Tools                ⬜ Plugins
  ⬜ Loop/Schedule
                  ⬇️
            🔒 Sub Agents
            (needs: planning)

═══════════════════════════════════════════════
  ✅ = used    ⬜ = available    🔒 = locked
````

Adapt the layout to the user's actual data. Show dependencies visually — locked features mention what they need.

## Step 3 — Give a hint

Pick the single best feature to try next from the **available** (not locked) features. Prefer higher-tier features when the user's level supports it.

Present a short, positive recommendation:

- Name the feature
- Explain why it's useful (one sentence)
- Give a concrete example of how to use it

Example: "**Try MCP Tools** — connect external services like databases or APIs directly into your workflow. Start by adding an MCP server config to your project."

## Game Mode Pitch

If game mode is not active, present this instead of the roadmap:

> Want to track your progress and master Claude Code? Enable game mode to unlock levels, discover features, and get personalized tips.

Ask: "Would you like to enable game mode?"

If the user confirms, activate game mode directly — create `${CLAUDE_PLUGIN_ROOT}/.local/` if needed and write `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json` with the initial schema from `/guide:game-mode`. Then tell them it's active and show the roadmap.

If the user declines, acknowledge and move on. Do not push.
