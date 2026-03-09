#!/usr/bin/env bash
# Lightweight schema migration — adds missing fields so tracking works
# immediately after upgrade. Does NOT set pluginVersion or record migration
# history — that is the game-mode skill's responsibility (user-initiated).
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
DATA_FILE="${PLUGIN_ROOT}/.local/game-data.json"

# Exit if data file doesn't exist
[ -f "$DATA_FILE" ] || exit 0

# Define expected feature categories
EXPECTED='["shell","editing","reading","search","agents","skills","plugins","web","planning","mcp","notebooks","loop"]'

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
  .migrations //= []
' "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"
