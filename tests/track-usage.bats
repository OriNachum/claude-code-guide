#!/usr/bin/env bats
# Tests for hooks/scripts/track-usage.sh (PostToolUse hook)

load helpers/setup.sh

setup() { setup_common; }
teardown() { teardown_common; }

SCRIPT_NAME="hooks/scripts/track-usage.sh"

run_hook() {
  echo "$1" | bash "${CLAUDE_PLUGIN_ROOT}/${SCRIPT_NAME}"
}

# --- Tool-to-category mapping ---

@test "Bash tool increments shell count" {
  run_hook '{"tool_name": "Bash"}'
  [ "$(get_count shell)" -eq 1 ]
}

@test "Edit tool increments editing count" {
  run_hook '{"tool_name": "Edit"}'
  [ "$(get_count editing)" -eq 1 ]
}

@test "Write tool increments editing count" {
  run_hook '{"tool_name": "Write"}'
  [ "$(get_count editing)" -eq 1 ]
}

@test "Read tool increments reading count" {
  run_hook '{"tool_name": "Read"}'
  [ "$(get_count reading)" -eq 1 ]
}

@test "Grep tool increments search count" {
  run_hook '{"tool_name": "Grep"}'
  [ "$(get_count search)" -eq 1 ]
}

@test "Glob tool increments search count" {
  run_hook '{"tool_name": "Glob"}'
  [ "$(get_count search)" -eq 1 ]
}

@test "WebFetch tool increments web count" {
  run_hook '{"tool_name": "WebFetch"}'
  [ "$(get_count web)" -eq 1 ]
}

@test "WebSearch tool increments web count" {
  run_hook '{"tool_name": "WebSearch"}'
  [ "$(get_count web)" -eq 1 ]
}

@test "EnterPlanMode tool increments planning count" {
  run_hook '{"tool_name": "EnterPlanMode"}'
  [ "$(get_count planning)" -eq 1 ]
}

@test "NotebookEdit tool increments notebooks count" {
  run_hook '{"tool_name": "NotebookEdit"}'
  [ "$(get_count notebooks)" -eq 1 ]
}

# --- MCP tools ---

@test "mcp__ tool increments mcp count" {
  run_hook '{"tool_name": "mcp__myserver__mytool"}'
  [ "$(get_count mcp)" -eq 1 ]
}

@test "mcp__ tool tracks server in mcpUsage" {
  run_hook '{"tool_name": "mcp__myserver__mytool"}'
  local srv_count
  srv_count="$(jq -r '.mcpUsage.myserver.count' "$DATA_FILE")"
  [ "$srv_count" -eq 1 ]
}

# --- Agent tracking ---

@test "Agent with custom subagent_type increments agents count" {
  run_hook '{"tool_name": "Agent", "tool_input": {"subagent_type": "my-custom-agent"}}'
  [ "$(get_count agents)" -eq 1 ]
}

@test "Agent with custom subagent_type tracks in agentUsage" {
  run_hook '{"tool_name": "Agent", "tool_input": {"subagent_type": "my-custom-agent"}}'
  local agt_count
  agt_count="$(jq -r '.agentUsage["my-custom-agent"].count' "$DATA_FILE")"
  [ "$agt_count" -eq 1 ]
}

@test "Agent with Explore subagent_type is skipped" {
  run_hook '{"tool_name": "Agent", "tool_input": {"subagent_type": "Explore"}}'
  [ "$(get_count agents)" -eq 0 ]
}

@test "Agent with Plan subagent_type is skipped" {
  run_hook '{"tool_name": "Agent", "tool_input": {"subagent_type": "Plan"}}'
  [ "$(get_count agents)" -eq 0 ]
}

@test "Agent with plugin subagent_type (colon) is skipped" {
  run_hook '{"tool_name": "Agent", "tool_input": {"subagent_type": "superpowers:code-reviewer"}}'
  [ "$(get_count agents)" -eq 0 ]
}

@test "Agent with no subagent_type increments agents count" {
  run_hook '{"tool_name": "Agent", "tool_input": {}}'
  [ "$(get_count agents)" -eq 1 ]
}

# --- Plan-file detection ---

@test "Write to plans directory increments planning count" {
  run_hook '{"tool_name": "Write", "tool_input": {"file_path": "/home/user/.claude/plans/my-plan.md"}}'
  [ "$(get_count planning)" -eq 1 ]
}

@test "Write to non-plans path increments editing count" {
  run_hook '{"tool_name": "Write", "tool_input": {"file_path": "/home/user/project/file.txt"}}'
  [ "$(get_count editing)" -eq 1 ]
}

# --- Skip/ignore cases ---

@test "Skill tool is skipped" {
  run_hook '{"tool_name": "Skill"}'
  [ "$(get_count skills)" -eq 0 ]
}

@test "Unknown tool is skipped" {
  run_hook '{"tool_name": "SomethingRandom"}'
  # All counts should remain 0
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

@test "Empty tool_name is skipped" {
  run_hook '{"other_field": "value"}'
  local total
  total="$(jq '[.features[].count] | add' "$DATA_FILE")"
  [ "$total" -eq 0 ]
}

@test "Game mode disabled causes no-op" {
  jq '.enabled = false' "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
  run_hook '{"tool_name": "Bash"}'
  [ "$(get_count shell)" -eq 0 ]
}

# --- Cumulative ---

@test "Multiple calls accumulate counts" {
  run_hook '{"tool_name": "Bash"}'
  run_hook '{"tool_name": "Bash"}'
  run_hook '{"tool_name": "Bash"}'
  [ "$(get_count shell)" -eq 3 ]
}

@test "lastUsed is set to a timestamp" {
  run_hook '{"tool_name": "Read"}'
  local ts
  ts="$(jq -r '.features.reading.lastUsed' "$DATA_FILE")"
  [ "$ts" != "null" ]
  # Should be ISO 8601 format
  echo "$ts" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
}
