#!/usr/bin/env bash
# Stop hook — best-effort token tracking for game mode
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

# Try to extract token counts from various possible payload structures
READ_TOKENS="$(echo "$PAYLOAD" | jq -r '
  .usage.input_tokens //
  .stats.input_tokens //
  .summary.input_tokens //
  0
' 2>/dev/null || echo 0)"

WRITE_TOKENS="$(echo "$PAYLOAD" | jq -r '
  .usage.output_tokens //
  .stats.output_tokens //
  .summary.output_tokens //
  0
' 2>/dev/null || echo 0)"

# If no tokens found, exit silently
if [ "$READ_TOKENS" = "0" ] && [ "$WRITE_TOKENS" = "0" ]; then
  exit 0
fi

# Update data file atomically
TMPFILE="$(mktemp "${DATA_FILE}.XXXXXX")"
jq --argjson read "$READ_TOKENS" --argjson write "$WRITE_TOKENS" '
  .tokens.read += $read |
  .tokens.write += $write |
  .tokens.total += ($read + $write)
' "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"
