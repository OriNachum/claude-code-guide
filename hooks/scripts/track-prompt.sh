#!/usr/bin/env bash
# UserPromptSubmit hook — tracks slash-command usage for game mode
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

# Acquire exclusive lock to prevent race conditions (flock is Linux-only)
if command -v flock >/dev/null 2>&1; then
  exec 9>"${DATA_FILE}.lock"
  flock 9
fi

# Migrate schema if plugin version changed
bash "${PLUGIN_ROOT}/hooks/scripts/migrate-data.sh"

# Extract the user's prompt text
PROMPT="$(echo "$PAYLOAD" | jq -r '.prompt // .content // .message.content // empty')"
[ -n "$PROMPT" ] || exit 0

# Track slash commands (skill invocations)
if echo "$PROMPT" | grep -qE '^\s*/[a-zA-Z]'; then
  SLASH_CMD="$(echo "$PROMPT" | sed -E 's/^\s*\/([a-zA-Z][a-zA-Z0-9_:-]*).*/\1/')"

  case "$SLASH_CMD" in
    loop)
      CATEGORY="loop" ;;
    btw)
      CATEGORY="btw" ;;
    guide:*)
      exit 0 ;;  # Our own plugin skills — skip
    help|clear|compact|cost|doctor|init|login|logout|status|model|config|\
permissions|vim|terminal-setup|listen|add-dir|bug|review|pr-comments|\
allowed-tools|hooks|mcp|ide|fast|slow|context)
      exit 0 ;;  # Built-in CLI commands — not skill invocations
    *:*)
      CATEGORY="plugins" ;;
    *)
      CATEGORY="skills" ;;
  esac

  NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  TMPFILE="$(mktemp "${DATA_FILE}.XXXXXX")"
  jq --arg cat "$CATEGORY" --arg cmd "$SLASH_CMD" --arg now "$NOW" '
    .features[$cat].count += 1 |
    .features[$cat].lastUsed = $now |
    .skillUsage[$cmd] //= {"count": 0, "lastUsed": null} |
    .skillUsage[$cmd].count += 1 |
    .skillUsage[$cmd].lastUsed = $now
  ' "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"
fi
