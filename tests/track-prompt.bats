#!/usr/bin/env bats
# Tests for hooks/scripts/track-prompt.sh (UserPromptSubmit hook)

load helpers/setup.sh

setup() { setup_common; }
teardown() { teardown_common; }

SCRIPT_NAME="hooks/scripts/track-prompt.sh"

run_hook() {
  echo "$1" | bash "${CLAUDE_PLUGIN_ROOT}/${SCRIPT_NAME}"
}

# --- Category routing ---

@test "/loop command increments loop count" {
  run_hook '{"prompt": "/loop 5m check-build"}'
  [ "$(get_count loop)" -eq 1 ]
}

@test "/btw command increments btw count" {
  run_hook '{"prompt": "/btw what is X"}'
  [ "$(get_count btw)" -eq 1 ]
}

@test "plugin command (colon syntax) increments plugins count" {
  run_hook '{"prompt": "/foo:bar some args"}'
  [ "$(get_count plugins)" -eq 1 ]
}

@test "regular skill command increments skills count" {
  run_hook '{"prompt": "/my-skill arg1 arg2"}'
  [ "$(get_count skills)" -eq 1 ]
}

# --- Built-in commands are skipped ---

@test "/help is skipped" {
  run_hook '{"prompt": "/help"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

@test "/clear is skipped" {
  run_hook '{"prompt": "/clear"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

@test "/compact is skipped" {
  run_hook '{"prompt": "/compact"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

@test "/status is skipped" {
  run_hook '{"prompt": "/status"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

@test "/model is skipped" {
  run_hook '{"prompt": "/model"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

# --- Own plugin is skipped ---

@test "/guide:ask is skipped (own plugin)" {
  run_hook '{"prompt": "/guide:ask how do hooks work"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

@test "/guide:onboard is skipped (own plugin)" {
  run_hook '{"prompt": "/guide:onboard"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

# --- Non-slash prompts ---

@test "Normal text prompt is ignored" {
  run_hook '{"prompt": "just a normal question"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

@test "Empty prompt is ignored" {
  run_hook '{"prompt": ""}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

# --- skillUsage tracking ---

@test "Slash command is recorded in skillUsage" {
  run_hook '{"prompt": "/my-skill do stuff"}'
  local cmd_count
  cmd_count="$(jq -r '.skillUsage["my-skill"].count' "$DATA_FILE")"
  [ "$cmd_count" -eq 1 ]
}

@test "Multiple uses of same command accumulate in skillUsage" {
  run_hook '{"prompt": "/my-skill first"}'
  run_hook '{"prompt": "/my-skill second"}'
  local cmd_count
  cmd_count="$(jq -r '.skillUsage["my-skill"].count' "$DATA_FILE")"
  [ "$cmd_count" -eq 2 ]
}

@test "Plugin command is recorded in skillUsage with full name" {
  run_hook '{"prompt": "/foo:bar baz"}'
  local cmd_count
  cmd_count="$(jq -r '.skillUsage["foo:bar"].count' "$DATA_FILE")"
  [ "$cmd_count" -eq 1 ]
}

# --- Game mode disabled ---

@test "Game mode disabled causes no-op" {
  jq '.enabled = false' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  run_hook '{"prompt": "/my-skill"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

# --- Alternate payload fields ---

@test "Prompt in content field is detected" {
  run_hook '{"content": "/loop check"}'
  [ "$(get_count loop)" -eq 1 ]
}

@test "lastUsed is set to a timestamp" {
  run_hook '{"prompt": "/my-skill"}'
  local ts
  ts="$(jq -r '.features.skills.lastUsed' "$DATA_FILE")"
  [ "$ts" != "null" ]
  echo "$ts" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
}
