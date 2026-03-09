---
description: Track your Claude Code feature usage, earn levels, and see your stats. Gamified learning mode.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Agent
---

# Game Mode

You are managing the game-mode feature for the guide plugin. Branch on `$ARGUMENTS`:

## `help`

Present the available commands:

| Command | What it does |
|---|---|
| `/guide:game-mode` | Enable game mode and start tracking |
| `/guide:game-mode stats` | Show your dashboard with scores and levels |
| `/guide:game-mode help` | Show this help |
| `/guide:game-mode off` | Pause tracking (data preserved) |
| `/guide:game-mode reset` | Delete all game data |
| `/guide:level-up` | Show your feature roadmap and next-step hint |

## `on` (or empty arguments)

### Migration check (runs first if data file already exists)

1. If `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json` exists, read it and read the current version from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`
2. If `pluginVersion` is missing or doesn't match the plugin version:
   a. **Snapshot**: Copy `game-data.json` to `.local/game-data.pre-<new-version>.json` as a backup
   b. **Migrate**: Add any missing feature categories with `{"count": 0, "lastUsed": null}`, add missing top-level fields (`pluginVersion`, `migrations`, `sessionCount`, `suggestedFeatures`, `tokens`) with defaults, set `pluginVersion` to the current plugin version
   c. **Record**: Append `{"from": "<old-version-or-unknown>", "to": "<new-version>", "date": "<UTC date YYYY-MM-DD>"}` to the `migrations` array
   d. **Inform**: Tell the user their data was migrated and a backup was saved at the snapshot path
   e. Set `enabled` to `true` and proceed (skip creating a fresh file)
3. If versions match: set `enabled` to `true` and proceed (skip creating a fresh file)

### Fresh install (no existing data file)

1. Create the directory `${CLAUDE_PLUGIN_ROOT}/.local/` if it doesn't exist
2. Read the current version from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`
3. Write `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json` with this initial content:

```json
{
  "pluginVersion": "<version from plugin.json>",
  "enabled": true,
  "startDate": "<current UTC date in YYYY-MM-DD format>",
  "sessionCount": 0,
  "suggestedFeatures": [],
  "migrations": [],
  "features": {
    "shell":     { "count": 0, "lastUsed": null },
    "editing":   { "count": 0, "lastUsed": null },
    "reading":   { "count": 0, "lastUsed": null },
    "search":    { "count": 0, "lastUsed": null },
    "agents":    { "count": 0, "lastUsed": null },
    "skills":    { "count": 0, "lastUsed": null },
    "plugins":   { "count": 0, "lastUsed": null },
    "web":       { "count": 0, "lastUsed": null },
    "planning":  { "count": 0, "lastUsed": null },
    "mcp":       { "count": 0, "lastUsed": null },
    "notebooks": { "count": 0, "lastUsed": null },
    "loop":      { "count": 0, "lastUsed": null }
  },
  "tokens": {
    "read": 0,
    "write": 0,
    "total": 0
  }
}
```

1. Tell the user game mode is now active. Mention:
   - Tool usage is being tracked across 12 feature categories
   - Use `/guide:game-mode stats` to see their dashboard
   - Use `/guide:game-mode off` to pause tracking
   - Data is stored locally and never transmitted

## `stats` or `status`

### Migration check (runs first)

1. Read `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json`
2. If the file doesn't exist or `enabled` is false, tell the user game mode is not active and suggest `/guide:game-mode` to enable it
3. Read the current version from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`
4. If `pluginVersion` is missing or doesn't match the plugin version:
   a. **Snapshot**: Copy `game-data.json` to `.local/game-data.pre-<new-version>.json` as a backup
   b. **Migrate**: Add any missing feature categories with `{"count": 0, "lastUsed": null}`, add missing top-level fields with defaults, set `pluginVersion` to current
   c. **Record**: Append `{"from": "<old-version-or-unknown>", "to": "<new-version>", "date": "<UTC date YYYY-MM-DD>"}` to the `migrations` array
   d. **Inform**: Tell the user their data was migrated and a backup was saved
5. If versions match: proceed normally

### Calculate and display

1. Calculate scoring using these tier multipliers:

| Tier | Multiplier | Features |
|---|---|---|
| Beginner | x1 | shell, editing, reading, search |
| Intermediate | x10 | skills, plugins, web, planning, notebooks, mcp, loop |
| Expert | x100 | agents |

1. Compute: `raw_points = sum(feature.count * multiplier)` and `score = sqrt(raw_points)` to 2 decimal places
1. Count unique features (count > 0)
1. Determine level (highest where BOTH criteria are met):

| Level | Title | Min Score | Min Unique Features |
|---|---|---|---|
| 1 | Novice | 0 | 0 |
| 2 | Apprentice | 5.00 | 3 |
| 3 | Practitioner | 15.00 | 5 |
| 4 | Expert | 30.00 | 8 |
| 5 | Master | 55.00 | 10 |

1. Present a formatted dashboard like this:

```text
+=======================================================+
|  GAME MODE -- Level 4: Expert                         |
|  Score: 32.45  |  Active since: 2026-03-08            |
+=======================================================+
|  Feature         Tier  Count  Points  Last Used       |
|  --------------- ----- ------ ------- ----------      |
|  Shell Commands   B      45      45   2h ago          |
|  Code Editing     B      32      32   1h ago          |
|  File Reading     B      28      28   30m ago         |
|  Code Search      B      18      18   1h ago          |
|  Skills           I       5      50   1d ago          |
|  Plugins          I       2      20   3d ago          |
|  Web Research     I       3      30   2d ago          |
|  Planning         I       2      20   5d ago          |
|  Notebooks        I       0       0   never           |
|  Sub Agents       E       8     800   3h ago          |
|  MCP Tools        I       1      10   7d ago          |
|  Loop/Schedule    I       0       0   never           |
+=======================================================+
|  Raw: 1053 pts | Score: sqrt(1053) = 32.45            |
|  Features: 10/12 unlocked                             |
|  Tokens: ~12.4K read, ~3.1K write                     |
|  Next level: Master (score 55+, 10+ features)         |
|  Migrated: unknown → 2.2.0 (2026-03-09)              |
+=======================================================+
```

- For "Last Used", show relative time (e.g., "2h ago", "1d ago") or "never"
- For tokens, use human-friendly formatting (e.g., "12.4K")
- Show progress toward the next level, or "MAX LEVEL" if at level 5
- If the `migrations` array is non-empty, show each migration as `Migrated: <from> → <to> (<date>)` in the dashboard footer. Omit the line if there are no migrations.

## `off`

1. Read `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json`
2. Set `enabled` to `false`
3. Write the file back
4. Tell the user tracking is paused. Their data is preserved — they can resume with `/guide:game-mode` anytime.

## `reset`

1. Ask the user to confirm: "This will delete all your game mode data. Type 'yes' to confirm."
2. If confirmed, delete `${CLAUDE_PLUGIN_ROOT}/.local/game-data.json`
3. Confirm the reset is complete
