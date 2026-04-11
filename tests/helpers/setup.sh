#!/usr/bin/env bash
# Common test setup for hook script tests

# Full game-data.json template with all expected fields
GAME_DATA_TEMPLATE='{
  "enabled": true,
  "features": {
    "shell": {"count": 0, "lastUsed": null},
    "editing": {"count": 0, "lastUsed": null},
    "reading": {"count": 0, "lastUsed": null},
    "search": {"count": 0, "lastUsed": null},
    "agents": {"count": 0, "lastUsed": null},
    "skills": {"count": 0, "lastUsed": null},
    "plugins": {"count": 0, "lastUsed": null},
    "web": {"count": 0, "lastUsed": null},
    "planning": {"count": 0, "lastUsed": null},
    "mcp": {"count": 0, "lastUsed": null},
    "notebooks": {"count": 0, "lastUsed": null},
    "loop": {"count": 0, "lastUsed": null},
    "btw": {"count": 0, "lastUsed": null},
    "tasks": {"count": 0, "lastUsed": null},
    "worktrees": {"count": 0, "lastUsed": null}
  },
  "tokens": {"read": 0, "write": 0, "total": 0},
  "sessionCount": 0,
  "suggestedFeatures": [],
  "migrations": [],
  "skillUsage": {},
  "mcpUsage": {},
  "agentUsage": {}
}'

setup_common() {
  # Create temp plugin root with expected directory structure
  export CLAUDE_PLUGIN_ROOT="$(mktemp -d)"
  mkdir -p "${CLAUDE_PLUGIN_ROOT}/.local"
  mkdir -p "${CLAUDE_PLUGIN_ROOT}/hooks/scripts"

  # Copy all hook scripts to temp root
  local repo_root
  repo_root="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
  cp "${repo_root}/hooks/scripts/"*.sh "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/"

  # Write default game-data.json
  echo "$GAME_DATA_TEMPLATE" > "${CLAUDE_PLUGIN_ROOT}/.local/game-data.json"

  # Convenience alias
  export DATA_FILE="${CLAUDE_PLUGIN_ROOT}/.local/game-data.json"
  return 0
}

teardown_common() {
  [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]] && rm -rf "$CLAUDE_PLUGIN_ROOT"
  return 0
}

# Helper: get a feature count from game-data.json
get_count() {
  local category="$1"
  jq -r --arg c "$category" '.features[$c].count' "$DATA_FILE"
  return 0
}

# Helper: get a top-level numeric field
get_field() {
  local field="$1"
  jq -r ".$field" "$DATA_FILE"
  return 0
}
