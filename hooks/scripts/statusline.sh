#!/usr/bin/env bash
# Statusline script — outputs compact level string for game mode
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
DATA_FILE="${PLUGIN_ROOT}/.local/game-data.json"

# Exit silently if data file doesn't exist or not enabled
[ -f "$DATA_FILE" ] || exit 0
ENABLED="$(jq -r '.enabled' "$DATA_FILE")"
[ "$ENABLED" = "true" ] || exit 0

# Calculate raw points with tier multipliers and unique features
eval "$(jq -r '
  def multiplier:
    if . == "shell" or . == "editing" or . == "reading" or . == "search" then 1
    elif . == "skills" or . == "web" or . == "planning" or . == "notebooks" then 10
    elif . == "agents" or . == "mcp" then 100
    else 0
    end;

  .features | to_entries |
  reduce .[] as $e (
    {raw: 0, unique: 0};
    .raw += ($e.value.count * ($e.key | multiplier)) |
    if $e.value.count > 0 then .unique += 1 else . end
  ) |
  "RAW=\(.raw) UNIQUE=\(.unique)"
' "$DATA_FILE")"

# Calculate score using awk for sqrt
SCORE="$(awk "BEGIN { printf \"%.2f\", sqrt($RAW) }")"

# Determine level
LEVEL=1
TITLE="Novice"
SCORE_INT="$(awk "BEGIN { printf \"%d\", sqrt($RAW) }")"

if [ "$SCORE_INT" -ge 55 ] && [ "$UNIQUE" -ge 9 ]; then
  LEVEL=5; TITLE="Master"
elif [ "$SCORE_INT" -ge 30 ] && [ "$UNIQUE" -ge 7 ]; then
  LEVEL=4; TITLE="Expert"
elif [ "$SCORE_INT" -ge 15 ] && [ "$UNIQUE" -ge 5 ]; then
  LEVEL=3; TITLE="Practitioner"
elif [ "$SCORE_INT" -ge 5 ] && [ "$UNIQUE" -ge 3 ]; then
  LEVEL=2; TITLE="Apprentice"
fi

echo "Lvl ${LEVEL} ${TITLE} | ${SCORE} pts | ${UNIQUE}/10"
