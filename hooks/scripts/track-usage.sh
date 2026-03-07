#!/usr/bin/env bash
# PostToolUse hook — tracks feature usage for game mode
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

# Extract tool name
TOOL_NAME="$(echo "$PAYLOAD" | jq -r '.tool_name // empty')"
[ -n "$TOOL_NAME" ] || exit 0

# If tool is Skill, check if it's a guide:* invocation — skip those
if [ "$TOOL_NAME" = "Skill" ]; then
  SKILL_NAME="$(echo "$PAYLOAD" | jq -r '.tool_input.skillName // .tool_input.skill_name // .tool_input.name // empty')"
  case "$SKILL_NAME" in
    guide:*) exit 0 ;;
  esac
fi

# Map tool name to feature category
CATEGORY=""
case "$TOOL_NAME" in
  Bash)                          CATEGORY="shell" ;;
  Edit|Write)                    CATEGORY="editing" ;;
  Read)                          CATEGORY="reading" ;;
  Grep|Glob)                     CATEGORY="search" ;;
  Skill)                         CATEGORY="skills" ;;
  WebFetch|WebSearch)            CATEGORY="web" ;;
  EnterPlanMode|ExitPlanMode)    CATEGORY="planning" ;;
  NotebookEdit)                  CATEGORY="notebooks" ;;
  Agent)                         CATEGORY="agents" ;;
  mcp__*)                        CATEGORY="mcp" ;;
  *)                             exit 0 ;;  # Unknown tool, skip
esac

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Update data file atomically
TMPFILE="$(mktemp "${DATA_FILE}.XXXXXX")"
jq --arg cat "$CATEGORY" --arg now "$NOW" '
  .features[$cat].count += 1 |
  .features[$cat].lastUsed = $now
' "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"
