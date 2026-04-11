#!/usr/bin/env bats
# Tests for hooks/scripts/migrate-data.sh (schema migration)

load helpers/setup.sh

setup() { setup_common; }
teardown() { teardown_common; }

SCRIPT_NAME="hooks/scripts/migrate-data.sh"

run_migrate() {
  local rc=0
  bash "${CLAUDE_PLUGIN_ROOT}/${SCRIPT_NAME}" || rc=$?
  [ "$rc" -eq 0 ] || { echo "run_migrate failed with exit code $rc" >&2; return 1; }
}

# --- Adding missing fields ---

@test "Missing feature categories are added" {
  # Start with minimal game-data.json — only enabled and empty features
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  # All 13 categories should exist
  local count
  count="$(jq '.features | keys | length' "$DATA_FILE")"
  [ "$count" -eq 13 ]
}

@test "All 13 expected categories are present after migration" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  for cat in shell editing reading search agents skills plugins web planning mcp notebooks loop btw; do
    local val
    val="$(jq -r --arg c "$cat" '.features[$c]' "$DATA_FILE")"
    [ "$val" != "null" ]
  done
}

@test "Missing tokens field is added" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  [ "$(jq '.tokens.read' "$DATA_FILE")" -eq 0 ]
  [ "$(jq '.tokens.write' "$DATA_FILE")" -eq 0 ]
  [ "$(jq '.tokens.total' "$DATA_FILE")" -eq 0 ]
}

@test "Missing sessionCount is added" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  [ "$(jq '.sessionCount' "$DATA_FILE")" -eq 0 ]
}

@test "Missing suggestedFeatures is added" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  [ "$(jq '.suggestedFeatures | length' "$DATA_FILE")" -eq 0 ]
}

@test "Missing migrations array is added" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  [ "$(jq '.migrations | length' "$DATA_FILE")" -eq 0 ]
}

@test "Missing skillUsage is added" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  [ "$(jq -r '.skillUsage | type' "$DATA_FILE")" = "object" ]
}

@test "Missing mcpUsage is added" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  [ "$(jq -r '.mcpUsage | type' "$DATA_FILE")" = "object" ]
}

@test "Missing agentUsage is added" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  [ "$(jq -r '.agentUsage | type' "$DATA_FILE")" = "object" ]
}

# --- Preserving existing data ---

@test "Existing feature counts are preserved" {
  jq '.features.shell.count = 42 | .features.editing.count = 7' \
    "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  run_migrate
  [ "$(jq '.features.shell.count' "$DATA_FILE")" -eq 42 ]
  [ "$(jq '.features.editing.count' "$DATA_FILE")" -eq 7 ]
}

@test "Existing tokens are preserved" {
  jq '.tokens.read = 500 | .tokens.write = 200 | .tokens.total = 700' \
    "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  run_migrate
  [ "$(jq '.tokens.read' "$DATA_FILE")" -eq 500 ]
  [ "$(jq '.tokens.write' "$DATA_FILE")" -eq 200 ]
  [ "$(jq '.tokens.total' "$DATA_FILE")" -eq 700 ]
}

@test "Existing sessionCount is preserved" {
  jq '.sessionCount = 13' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  run_migrate
  [ "$(jq '.sessionCount' "$DATA_FILE")" -eq 13 ]
}

@test "Existing suggestedFeatures are preserved" {
  jq '.suggestedFeatures = ["skills","web"]' \
    "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  run_migrate
  [ "$(jq '.suggestedFeatures | length' "$DATA_FILE")" -eq 2 ]
  [ "$(jq -r '.suggestedFeatures[0]' "$DATA_FILE")" = "skills" ]
}

# --- Idempotency ---

@test "Running migration twice produces same result" {
  echo '{"enabled": true, "features": {"shell": {"count": 5, "lastUsed": "2025-01-01T00:00:00Z"}}}' > "$DATA_FILE"
  run_migrate
  local first
  first="$(cat "$DATA_FILE")"
  run_migrate
  local second
  second="$(cat "$DATA_FILE")"
  [ "$first" = "$second" ]
}

# --- Missing file handling ---

@test "Missing data file exits silently" {
  rm -f "$DATA_FILE"
  # Ensure no cache directory exists for fallback
  export HOME="$(mktemp -d)"
  run_migrate
  # Should not create the file
  [ ! -f "$DATA_FILE" ]
}

# --- Full template validation ---

@test "Full template has correct structure after migration" {
  echo '{"enabled": true, "features": {}}' > "$DATA_FILE"
  run_migrate
  # Validate each new feature category has count and lastUsed
  for cat in shell editing reading search agents skills plugins web planning mcp notebooks loop btw; do
    [ "$(jq -r --arg c "$cat" '.features[$c].count' "$DATA_FILE")" = "0" ]
    [ "$(jq -r --arg c "$cat" '.features[$c].lastUsed' "$DATA_FILE")" = "null" ]
  done
}
