#!/usr/bin/env bash
# Stop hook — token tracking + Fibonacci-spaced nudges for game mode
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

# Migrate schema if plugin version changed
bash "${PLUGIN_ROOT}/hooks/scripts/migrate-data.sh"

# --- Token tracking (best-effort) ---

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

# --- Increment session count ---

TMPFILE="$(mktemp "${DATA_FILE}.XXXXXX")"
jq --argjson read "$READ_TOKENS" --argjson write "$WRITE_TOKENS" '
  .tokens.read += $read |
  .tokens.write += $write |
  .tokens.total += ($read + $write) |
  .sessionCount = ((.sessionCount // 0) + 1)
' "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"

# --- Fibonacci check ---

SESSION="$(jq -r '.sessionCount' "$DATA_FILE")"

is_fibonacci() {
  local n="$1" a=1 b=1 tmp
  while [ "$b" -lt "$n" ]; do
    tmp=$b
    b=$((a + b))
    a=$tmp
  done
  [ "$b" -eq "$n" ]
}

is_fibonacci "$SESSION" || exit 0

# --- Calculate level and score ---

eval "$(jq -r '
  def multiplier:
    if . == "shell" or . == "editing" or . == "reading" or . == "search" then 1
    elif . == "agents" then 100
    else 10
    end;

  .features | to_entries |
  reduce .[] as $e (
    {raw: 0, unique: 0};
    .raw += ($e.value.count * ($e.key | multiplier)) |
    if $e.value.count > 0 then .unique += 1 else . end
  ) |
  "RAW=\(.raw) UNIQUE=\(.unique)"
' "$DATA_FILE")"

SCORE="$(awk "BEGIN { printf \"%.1f\", sqrt($RAW) }")"
SCORE_INT="$(awk "BEGIN { printf \"%d\", sqrt($RAW) }")"

# Determine level
LEVEL=1; TITLE="Novice"
if [ "$SCORE_INT" -ge 55 ] && [ "$UNIQUE" -ge 10 ]; then
  LEVEL=5; TITLE="Master"
elif [ "$SCORE_INT" -ge 30 ] && [ "$UNIQUE" -ge 8 ]; then
  LEVEL=4; TITLE="Expert"
elif [ "$SCORE_INT" -ge 15 ] && [ "$UNIQUE" -ge 5 ]; then
  LEVEL=3; TITLE="Practitioner"
elif [ "$SCORE_INT" -ge 5 ] && [ "$UNIQUE" -ge 3 ]; then
  LEVEL=2; TITLE="Apprentice"
fi

# --- Weighted random feature suggestion ---

# Dependencies: feature -> required features (space-separated)
dep_met() {
  local feature="$1"
  case "$feature" in
    agents)       jq -e '.features.skills.count > 0 and .features.planning.count > 0' "$DATA_FILE" >/dev/null 2>&1 ;;
    *)            return 0 ;;
  esac
}

# Level gating: levels 1-2 see intermediate only; 3+ see intermediate + expert
if [ "$LEVEL" -ge 3 ]; then
  CANDIDATES="skills plugins web planning notebooks mcp loop agents"
else
  CANDIDATES="skills plugins web planning notebooks mcp loop"
fi

# Filter: unused, not yet suggested, deps met
SUGGESTED="$(jq -r '.suggestedFeatures // [] | .[]' "$DATA_FILE")"
ELIGIBLE=""
for feat in $CANDIDATES; do
  # Skip if already used
  COUNT="$(jq -r --arg f "$feat" '.features[$f].count // 0' "$DATA_FILE")"
  [ "$COUNT" -eq 0 ] || continue
  # Skip if already suggested
  echo "$SUGGESTED" | grep -qx "$feat" && continue
  # Skip if deps not met
  dep_met "$feat" || continue
  ELIGIBLE="$ELIGIBLE $feat"
done
ELIGIBLE="$(echo "$ELIGIBLE" | xargs)"

# Pick weighted random (expert=3x weight, intermediate=1x)
if [ -n "$ELIGIBLE" ]; then
  WEIGHTED=""
  for feat in $ELIGIBLE; do
    case "$feat" in
      agents) WEIGHTED="$WEIGHTED $feat $feat $feat" ;;
      *)      WEIGHTED="$WEIGHTED $feat" ;;
    esac
  done
  WEIGHTED="$(echo "$WEIGHTED" | xargs)"
  COUNT_W="$(echo "$WEIGHTED" | wc -w)"
  IDX="$(( (RANDOM % COUNT_W) + 1 ))"
  PICK="$(echo "$WEIGHTED" | cut -d' ' -f"$IDX")"

  # Feature display names and tips
  case "$PICK" in
    skills)    TIP="Skills — try /guide:ask to get answers from reference docs" ;;
    plugins)   TIP="Plugins — install a plugin to extend Claude with new skills" ;;
    web)       TIP="Web Research — use WebSearch/WebFetch to pull live info" ;;
    planning)  TIP="Planning — enter plan mode to think before building" ;;
    notebooks) TIP="Notebooks — edit Jupyter notebooks directly with NotebookEdit" ;;
    mcp)       TIP="MCP Tools — connect external services via Model Context Protocol" ;;
    loop)      TIP="Loop Scheduling — use /loop to monitor deploys or triage tickets on a timer" ;;
    agents)    TIP="Sub Agents — delegate complex tasks to run in parallel" ;;
    *)         TIP="$PICK" ;;
  esac

  # Record suggestion
  TMPFILE="$(mktemp "${DATA_FILE}.XXXXXX")"
  jq --arg feat "$PICK" '.suggestedFeatures = ((.suggestedFeatures // []) + [$feat])' \
    "$DATA_FILE" > "$TMPFILE" && mv "$TMPFILE" "$DATA_FILE"

  echo "🎮 Lvl ${LEVEL} ${TITLE} | ${SCORE} pts | Try: ${TIP} (/guide:level-up for more)"
else
  echo "🎮 Lvl ${LEVEL} ${TITLE} | ${SCORE} pts | ${UNIQUE}/12 features (/guide:level-up)"
fi
