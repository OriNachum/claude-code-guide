#!/usr/bin/env bash
# UserPromptSubmit hook — tracks /loop usage for game mode
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
DATA_FILE="${PLUGIN_ROOT}/.local/game-data.json"

# Exit silently if data file doesn't exist
[ -f "$DATA_FILE" ] || exit 0

# Read stdin (hook payload)
PAYLOAD="$(cat)"

# Exit if game mode is not enabled
ENABLED="$(jq -r '.enabled' "$DATA_FILE")"
[ "$ENABLED" = "true" ] || exit 0

# Extract the user's prompt text
PROMPT="$(echo "$PAYLOAD" | jq -r '.prompt // .content // .message.content // empty')"
[ -n "$PROMPT" ] || exit 0

# Check if input starts with /loop
if echo "$PROMPT" | grep -qE '^\s*/loop\b'; then
  NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  TMPFILE="$(mktemp "${DATA_FILE}.XXXXXX")"
  jq --arg now "$NOW" '
    .features.loop.count += 1 |
    .features.loop.lastUsed = $now
  ' "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"
fi
