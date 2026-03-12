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

# Acquire exclusive lock to prevent race conditions (flock is Linux-only)
if command -v flock >/dev/null 2>&1; then
  exec 9>"${DATA_FILE}.lock"
  flock 9
fi

# Migrate schema if plugin version changed
bash "${PLUGIN_ROOT}/hooks/scripts/migrate-data.sh"

# Extract tool name
TOOL_NAME="$(echo "$PAYLOAD" | jq -r '.tool_name // empty')"
[ -n "$TOOL_NAME" ] || exit 0

# Skills/plugins are tracked via UserPromptSubmit (track-prompt.sh), not here
[ "$TOOL_NAME" = "Skill" ] && exit 0

# Detect plan-file writes as planning usage
if [ "$TOOL_NAME" = "Write" ]; then
  FILE_PATH="$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')"
  if [[ "$FILE_PATH" == *"/.claude/plans/"* ]]; then
    CATEGORY="planning"
  fi
fi

# Map tool name to feature category (CATEGORY may already be set by plan-file write detection above)
: "${CATEGORY:=}"
case "$TOOL_NAME" in
  Bash)                          CATEGORY="shell" ;;
  Edit|Write)                    [ -z "$CATEGORY" ] && CATEGORY="editing" ;;
  Read)                          CATEGORY="reading" ;;
  Grep|Glob)                     CATEGORY="search" ;;
  WebFetch|WebSearch)            CATEGORY="web" ;;
  EnterPlanMode|ExitPlanMode)    CATEGORY="planning" ;;
  NotebookEdit)                  CATEGORY="notebooks" ;;
  Agent)
    # Only count user-initiated agents (not built-in or plugin ones)
    SUBAGENT_TYPE="$(echo "$PAYLOAD" | jq -r '.tool_input.subagent_type // empty')"
    case "$SUBAGENT_TYPE" in
      Explore|Plan|general-purpose|statusline-setup)
        exit 0 ;;  # Internal agent — skip
      *:*)
        exit 0 ;;  # Plugin agent (e.g. superpowers:code-reviewer) — skip
      *)
        CATEGORY="agents" ;;
    esac
    ;;
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
