#!/usr/bin/env bash
# Lightweight schema migration — adds missing fields so tracking works
# immediately after upgrade. Does NOT set pluginVersion or record migration
# history — that is the game-mode skill's responsibility (user-initiated).
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
DATA_FILE="${PLUGIN_ROOT}/.local/game-data.json"

# If data file doesn't exist, look for it in older cached plugin versions
if [ ! -f "$DATA_FILE" ]; then
  CACHE_BASE="$HOME/.claude/plugins/cache/claude-code-guide/guide"
  LATEST_OLD=""
  if [ -d "$CACHE_BASE" ]; then
    for dir in "$CACHE_BASE"/*/; do
      candidate="${dir}.local/game-data.json"
      [ -f "$candidate" ] || continue
      # Only consider files where game mode was enabled
      if [ "$(jq -r '.enabled' "$candidate" 2>/dev/null)" = "true" ]; then
        # Pick the most recently modified one
        if [ -z "$LATEST_OLD" ] || [ "$candidate" -nt "$LATEST_OLD" ]; then
          LATEST_OLD="$candidate"
        fi
      fi
    done
  fi

  if [ -n "$LATEST_OLD" ]; then
    mkdir -p "$(dirname "$DATA_FILE")"
    cp "$LATEST_OLD" "$DATA_FILE"
  else
    exit 0
  fi
fi

# jq is required for JSON processing; exit silently if unavailable
command -v jq >/dev/null 2>&1 || exit 0

# Define expected feature categories
EXPECTED='["shell","editing","reading","search","agents","skills","plugins","web","planning","mcp","notebooks","loop","btw","tasks","worktrees"]'

# Add missing fields and categories, preserve all existing data
# Intentionally does not touch pluginVersion or migrations — those are
# managed by the game-mode skill so the user sees the migration notice.
TMPFILE="$(mktemp "${DATA_FILE}.XXXXXX")"
jq --argjson feats "$EXPECTED" '
  reduce ($feats[]) as $f (.;
    if .features[$f] == null then
      .features[$f] = {"count": 0, "lastUsed": null}
    else . end
  ) |
  .tokens //= {"read": 0, "write": 0, "total": 0} |
  .sessionCount //= 0 |
  .suggestedFeatures //= [] |
  .migrations //= [] |
  .skillUsage //= {} |
  .mcpUsage //= {} |
  .agentUsage //= {}
' "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"
