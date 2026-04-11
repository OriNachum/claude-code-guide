#!/usr/bin/env bats
# Tests for hooks/scripts/track-stop.sh (Stop hook)

load helpers/setup.sh

setup() { setup_common; }
teardown() { teardown_common; }

SCRIPT_NAME="hooks/scripts/track-stop.sh"

run_hook() {
  echo "$1" | bash "${CLAUDE_PLUGIN_ROOT}/${SCRIPT_NAME}"
}

# --- Token tracking ---

@test "Token counts are recorded from usage field" {
  run_hook '{"usage": {"input_tokens": 100, "output_tokens": 50}}'
  [ "$(jq '.tokens.read' "$DATA_FILE")" -eq 100 ]
  [ "$(jq '.tokens.write' "$DATA_FILE")" -eq 50 ]
  [ "$(jq '.tokens.total' "$DATA_FILE")" -eq 150 ]
}

@test "Token counts accumulate across calls" {
  run_hook '{"usage": {"input_tokens": 100, "output_tokens": 50}}'
  run_hook '{"usage": {"input_tokens": 200, "output_tokens": 75}}'
  [ "$(jq '.tokens.read' "$DATA_FILE")" -eq 300 ]
  [ "$(jq '.tokens.write' "$DATA_FILE")" -eq 125 ]
  [ "$(jq '.tokens.total' "$DATA_FILE")" -eq 425 ]
}

@test "Zero tokens when usage field is missing" {
  run_hook '{"other": "data"}'
  [ "$(jq '.tokens.read' "$DATA_FILE")" -eq 0 ]
  [ "$(jq '.tokens.write' "$DATA_FILE")" -eq 0 ]
}

# --- Session counting ---

@test "Session count increments from 0 to 1" {
  run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}'
  [ "$(jq '.sessionCount' "$DATA_FILE")" -eq 1 ]
}

@test "Session count increments across calls" {
  run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}'
  run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}'
  run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}'
  [ "$(jq '.sessionCount' "$DATA_FILE")" -eq 3 ]
}

# --- Fibonacci detection ---
# The script's is_fibonacci: a=1,b=1 and checks b==n
# Fibonacci sequence (starting 1,1): 1, 1, 2, 3, 5, 8, 13, 21, 34, 55

@test "Session 1 is Fibonacci — produces output" {
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -n "$output" ]
}

@test "Session 2 is Fibonacci — produces output" {
  jq '.sessionCount = 1' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -n "$output" ]
}

@test "Session 3 is Fibonacci — produces output" {
  jq '.sessionCount = 2' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -n "$output" ]
}

@test "Session 4 is NOT Fibonacci — no output" {
  jq '.sessionCount = 3' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -z "$output" ]
}

@test "Session 5 is Fibonacci — produces output" {
  jq '.sessionCount = 4' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -n "$output" ]
}

@test "Session 8 is Fibonacci — produces output" {
  jq '.sessionCount = 7' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -n "$output" ]
}

@test "Session 6 is NOT Fibonacci — no output" {
  jq '.sessionCount = 5' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -z "$output" ]
}

@test "Session 7 is NOT Fibonacci — no output" {
  jq '.sessionCount = 6' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -z "$output" ]
}

# --- Level calculation ---
# Score = sqrt(RAW), where RAW = sum(count * multiplier)
# Multipliers: shell/editing/reading/search/btw=1, agents=100, rest=10
# Level thresholds: L2 >= 5 pts & 3 unique, L3 >= 15 & 5, L4 >= 30 & 8, L5 >= 55 & 10

@test "Level 1 Novice with no usage" {
  # Session 1 (Fibonacci) — all features at 0
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  echo "$output" | grep -q "Lvl 1 Novice"
}

@test "Level 2 Apprentice with moderate usage" {
  # Need score_int >= 5 and unique >= 3
  # 3 features used: shell=25 (25*1=25), editing=1 (1*1=1), skills=1 (1*10=10)
  # RAW = 25+1+10 = 36, sqrt(36) = 6.0 => score_int = 6 >= 5, unique = 3 >= 3
  jq '.features.shell.count = 25 |
      .features.editing.count = 1 |
      .features.skills.count = 1' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  echo "$output" | grep -q "Lvl 2 Apprentice"
}

@test "Level 3 Practitioner" {
  # Need score_int >= 15 and unique >= 5
  # shell=10(10), editing=5(5), reading=5(5), search=5(5), skills=20(200)
  # RAW = 10+5+5+5+200 = 225, sqrt(225) = 15 => score_int = 15 >= 15, unique = 5 >= 5
  jq '.features.shell.count = 10 |
      .features.editing.count = 5 |
      .features.reading.count = 5 |
      .features.search.count = 5 |
      .features.skills.count = 20' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  echo "$output" | grep -q "Lvl 3 Practitioner"
}

@test "Level 4 Expert" {
  # Need score_int >= 30 and unique >= 8
  # shell=10(10), editing=10(10), reading=10(10), search=10(10), skills=5(50),
  # plugins=5(50), web=5(50), planning=5(50), mcp=60(600)
  # RAW = 10+10+10+10+50+50+50+50+600 = 840, sqrt(840) ~ 28.98 => not quite
  # Let's increase: mcp=70(700), RAW = 10+10+10+10+50+50+50+50+700 = 940, sqrt(940) ~ 30.7
  jq '.features.shell.count = 10 |
      .features.editing.count = 10 |
      .features.reading.count = 10 |
      .features.search.count = 10 |
      .features.skills.count = 5 |
      .features.plugins.count = 5 |
      .features.web.count = 5 |
      .features.planning.count = 5 |
      .features.mcp.count = 70' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  echo "$output" | grep -q "Lvl 4 Expert"
}

@test "Level 5 Master" {
  # Need score_int >= 55 and unique >= 10
  # Use agents=30 (30*100=3000) + 9 other features with count>=1
  # shell=5(5), editing=5(5), reading=5(5), search=5(5), skills=5(50),
  # plugins=5(50), web=5(50), planning=5(50), mcp=5(50), agents=30(3000)
  # RAW = 5+5+5+5+50+50+50+50+50+3000 = 3270, sqrt(3270) ~ 57.2
  # unique = 10 >= 10
  jq '.features.shell.count = 5 |
      .features.editing.count = 5 |
      .features.reading.count = 5 |
      .features.search.count = 5 |
      .features.skills.count = 5 |
      .features.plugins.count = 5 |
      .features.web.count = 5 |
      .features.planning.count = 5 |
      .features.mcp.count = 5 |
      .features.agents.count = 30' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  echo "$output" | grep -q "Lvl 5 Master"
}

# --- Output format ---

@test "Output contains score" {
  jq '.features.shell.count = 10' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  echo "$output" | grep -qE 'pts'
}

@test "Output contains game emoji" {
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  echo "$output" | grep -q "🎮"
}

# --- Feature suggestion ---

@test "Feature suggestion is included in output for unused features" {
  # Session 1, all features at 0 — should suggest something
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  echo "$output" | grep -qE "Try:"
}

@test "Suggested feature is recorded in suggestedFeatures" {
  run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}'
  local count
  count="$(jq '.suggestedFeatures | length' "$DATA_FILE")"
  [ "$count" -ge 1 ]
}

@test "Already-suggested features are not re-suggested" {
  # Suggest all eligible features until none remain
  # Pre-populate suggestedFeatures with all level 1-2 candidates
  jq '.suggestedFeatures = ["btw","skills","plugins","web","planning","notebooks","mcp","loop"]' \
    "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  # Should show the "features" summary line instead of "Try:"
  echo "$output" | grep -qE "features"
}

# --- Game mode disabled ---

@test "Game mode disabled causes no-op" {
  jq '.enabled = false' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  output="$(run_hook '{"usage": {"input_tokens": 0, "output_tokens": 0}}')"
  [ -z "$output" ]
  # Session count should not increment
  [ "$(jq '.sessionCount' "$DATA_FILE")" -eq 0 ]
}
