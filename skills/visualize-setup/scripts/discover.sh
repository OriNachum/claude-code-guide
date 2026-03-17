#!/usr/bin/env bash
set -euo pipefail

# Discovers skills, MCP servers, sub agents, and game data → outputs JSON to stdout.
# Requires: jq, awk

# --- Helpers ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_frontmatter_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    /^---$/ { block++; next }
    block == 1 && $0 ~ "^"f":" {
      sub("^"f":[[:space:]]*", "")
      gsub(/^"|"$/, "")
      print
      exit
    }
    block >= 2 { exit }
  ' "$file"
}

get_category() {
  case "$1" in
    message-user|ask-slack|slack-bridge) echo "Communication|#10b981" ;;
    automate|az-devops) echo "DevOps & CI/CD|#f97316" ;;
    jira|confluence) echo "Project Management|#3b82f6" ;;
    playwright-mcp) echo "Browser & Testing|#a855f7" ;;
    count-tokens|visualize-setup|visualize-skills) echo "Utilities|#f59e0b" ;;
    *) echo "Other|#6b7280" ;;
  esac
}

extract_cap_tags() {
  local body="$1"
  echo "$body" | grep -oiE 'curl|bash|MCP|webhook|REST API|jq|GitHub|Slack|browser|Playwright' \
    | sort -uf | jq -R . | jq -s . 2>/dev/null || echo '[]'
}

process_skill_file() {
  local file="$1" scope="$2" plugin_name="${3:-}"

  local skill_dir
  skill_dir="$(dirname "$file")"
  local dir_name
  dir_name="$(basename "$skill_dir")"

  # Parse frontmatter (individual extractions — safe for special chars)
  local NAME DESC LICENSE
  NAME="$(get_frontmatter_field "$file" "name")"
  NAME="${NAME:-$dir_name}"
  DESC="$(get_frontmatter_field "$file" "description")"
  LICENSE="$(get_frontmatter_field "$file" "license")"
  LICENSE="${LICENSE:-—}"

  # Check for scripts directory
  local has_scripts=false
  [ -d "$skill_dir/scripts" ] && has_scripts=true

  # Context cost (file size in bytes)
  local context_bytes
  context_bytes="$(wc -c < "$file" | tr -d ' ')"

  # Extract body (after second ---)
  local body
  body="$(awk '/^---$/{n++;next} n>=2' "$file")"

  # Truncate body for display
  local body_short
  body_short="$(echo "$body" | head -5 | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-200)"

  # Capability tags
  local cap_tags
  cap_tags="$(extract_cap_tags "$body")"

  # Category
  local cat_info
  cat_info="$(get_category "$dir_name")"
  local category="${cat_info%%|*}"
  local category_color="${cat_info##*|}"

  # Build command
  local cmd
  if [ -n "$plugin_name" ]; then
    cmd="/${plugin_name}:${dir_name}"
  else
    cmd="/${dir_name}"
  fi

  jq -n \
    --arg name "$NAME" \
    --arg description "$DESC" \
    --arg license "$LICENSE" \
    --argjson has_scripts "$has_scripts" \
    --arg body "$body_short" \
    --argjson capTags "$cap_tags" \
    --arg category "$category" \
    --arg categoryColor "$category_color" \
    --arg scope "$scope" \
    --arg type "skill" \
    --arg pluginName "$plugin_name" \
    --arg cmd "$cmd" \
    --argjson contextBytes "$context_bytes" \
    '{
      name: $name,
      description: $description,
      license: $license,
      has_scripts: $has_scripts,
      body: $body,
      capTags: $capTags,
      category: $category,
      categoryColor: $categoryColor,
      scope: $scope,
      type: $type,
      pluginName: (if $pluginName == "" then null else $pluginName end),
      cmd: $cmd,
      contextBytes: $contextBytes
    }'
}

# --- Shared constants ---

INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"

# --- Collect skills ---

SKILLS_ARRAY="[]"

# Step 1a — Global skills
if [ -d "$HOME/.claude/skills" ]; then
  for file in "$HOME"/.claude/skills/*/SKILL.md; do
    [ -f "$file" ] || continue
    skill_json="$(process_skill_file "$file" "global")"
    SKILLS_ARRAY="$(echo "$SKILLS_ARRAY" | jq --argjson s "$skill_json" '. + [$s]')"
  done
fi

# Step 1b — Project-level skills
if [ -d "$PWD/.claude/skills" ]; then
  for file in "$PWD"/.claude/skills/*/SKILL.md; do
    [ -f "$file" ] || continue
    skill_json="$(process_skill_file "$file" "project")"
    SKILLS_ARRAY="$(echo "$SKILLS_ARRAY" | jq --argjson s "$skill_json" '. + [$s]')"
  done
fi

# Step 1e — Plugin-installed skills
if [ -f "$INSTALLED_PLUGINS" ]; then
  while IFS= read -r install_path; do
    [ -n "$install_path" ] || continue
    [ -d "$install_path" ] || continue

    # Get plugin name from plugin.json
    local_plugin_json="${install_path}/.claude-plugin/plugin.json"
    plugin_name=""
    if [ -f "$local_plugin_json" ]; then
      plugin_name="$(jq -r '.name // ""' "$local_plugin_json")"
    fi

    # Scan skills
    if [ -d "${install_path}/skills" ]; then
      for file in "${install_path}"/skills/*/SKILL.md; do
        [ -f "$file" ] || continue
        skill_json="$(process_skill_file "$file" "plugin" "$plugin_name")"
        SKILLS_ARRAY="$(echo "$SKILLS_ARRAY" | jq --argjson s "$skill_json" '. + [$s]')"
      done
    fi
  done < <(jq -r '.plugins | to_entries[] | .value[0].installPath // empty' "$INSTALLED_PLUGINS" 2>/dev/null)
fi

# --- Collect agents ---

AGENTS_ARRAY="[]"

process_agent_file() {
  local file="$1" scope="$2" plugin_name="${3:-}"

  local agent_name
  agent_name="$(basename "$file" .md)"

  # Parse YAML frontmatter fields
  local DESC MODEL TOOLS
  DESC="$(get_frontmatter_field "$file" "description")"
  MODEL="$(get_frontmatter_field "$file" "model")"
  MODEL="${MODEL:-sonnet}"
  TOOLS="$(get_frontmatter_field "$file" "allowed-tools")"

  # Context cost (file size in bytes)
  local context_bytes
  context_bytes="$(wc -c < "$file" | tr -d ' ')"

  jq -n \
    --arg name "$agent_name" \
    --arg description "$DESC" \
    --arg model "$MODEL" \
    --arg tools "$TOOLS" \
    --arg scope "$scope" \
    --arg type "agent" \
    --arg pluginName "$plugin_name" \
    --argjson contextBytes "$context_bytes" \
    '{
      name: $name,
      description: $description,
      model: $model,
      tools: $tools,
      scope: $scope,
      type: $type,
      pluginName: (if $pluginName == "" then null else $pluginName end),
      contextBytes: $contextBytes
    }'
}

# Global agents
if [ -d "$HOME/.claude/agents" ]; then
  for file in "$HOME"/.claude/agents/*.md; do
    [ -f "$file" ] || continue
    agent_json="$(process_agent_file "$file" "global")"
    AGENTS_ARRAY="$(echo "$AGENTS_ARRAY" | jq --argjson a "$agent_json" '. + [$a]')"
  done
fi

# Project-level agents
if [ -d "$PWD/.claude/agents" ]; then
  for file in "$PWD"/.claude/agents/*.md; do
    [ -f "$file" ] || continue
    agent_json="$(process_agent_file "$file" "project")"
    AGENTS_ARRAY="$(echo "$AGENTS_ARRAY" | jq --argjson a "$agent_json" '. + [$a]')"
  done
fi

# Plugin-installed agents
if [ -f "$INSTALLED_PLUGINS" ]; then
  while IFS= read -r install_path; do
    [ -n "$install_path" ] || continue
    [ -d "$install_path" ] || continue

    local_plugin_json="${install_path}/.claude-plugin/plugin.json"
    plugin_name=""
    if [ -f "$local_plugin_json" ]; then
      plugin_name="$(jq -r '.name // ""' "$local_plugin_json")"
    fi

    if [ -d "${install_path}/agents" ]; then
      for file in "${install_path}"/agents/*.md; do
        [ -f "$file" ] || continue
        agent_json="$(process_agent_file "$file" "plugin" "$plugin_name")"
        AGENTS_ARRAY="$(echo "$AGENTS_ARRAY" | jq --argjson a "$agent_json" '. + [$a]')"
      done
    fi
  done < <(jq -r '.plugins | to_entries[] | .value[0].installPath // empty' "$INSTALLED_PLUGINS" 2>/dev/null)
fi

# --- Collect MCP servers ---

MCP_ARRAY="[]"

extract_mcp_servers() {
  local file="$1" scope="$2" key_path="$3"

  [ -f "$file" ] || return 0

  local servers
  servers="$(jq -r "${key_path} // {} | to_entries[] | @base64" "$file" 2>/dev/null)" || return 0

  for entry in $servers; do
    local decoded
    decoded="$(echo "$entry" | base64 --decode)"

    local name command args_str env_keys
    name="$(echo "$decoded" | jq -r '.key')"
    command="$(echo "$decoded" | jq -r '.value.command // ""')"
    args_str="$(echo "$decoded" | jq -r '.value.args // [] | join(" ")')"
    env_keys="$(echo "$decoded" | jq '[.value.env // {} | keys[]]')"

    # Query MCP server for tool schema size
    local context_bytes
    local args_array
    args_array="$(echo "$decoded" | jq -r '.value.args // [] | .[]')"
    # shellcheck disable=SC2086
    context_bytes="$("${SCRIPT_DIR}/query-mcp.sh" "$command" $args_array 2>/dev/null || echo "-1")"

    local srv
    srv="$(jq -n \
      --arg name "$name" \
      --arg command "$command" \
      --arg args "$args_str" \
      --argjson env "$env_keys" \
      --arg scope "$scope" \
      --argjson contextBytes "$context_bytes" \
      '{name: $name, command: $command, args: $args, env: $env, scope: $scope, contextBytes: $contextBytes}')"

    MCP_ARRAY="$(echo "$MCP_ARRAY" | jq --argjson s "$srv" '. + [$s]')"
  done
}

# Step 1c — Global MCP servers
extract_mcp_servers "$HOME/.claude/settings.json" "global" ".mcpServers"

# Step 1d — Project-level MCP servers
extract_mcp_servers "$PWD/.mcp.json" "project" ".mcpServers"

# --- Game data ---

GAME_FILE="${CLAUDE_PLUGIN_ROOT:-.}/.local/game-data.json"

# Fallback: search older cached plugin versions if current game data missing
if [ ! -f "$GAME_FILE" ]; then
  CACHE_BASE="$HOME/.claude/plugins/cache/claude-code-guide/guide"
  if [ -d "$CACHE_BASE" ]; then
    for dir in "$CACHE_BASE"/*/; do
      candidate="${dir}.local/game-data.json"
      [ -f "$candidate" ] || continue
      if [ "$(jq -r '.enabled' "$candidate" 2>/dev/null)" = "true" ]; then
        if [ -z "${GAME_FILE_FALLBACK:-}" ] || [ "$candidate" -nt "$GAME_FILE_FALLBACK" ]; then
          GAME_FILE_FALLBACK="$candidate"
        fi
      fi
    done
    [ -n "${GAME_FILE_FALLBACK:-}" ] && GAME_FILE="$GAME_FILE_FALLBACK"
  fi
fi

GAME_JSON="null"
if [ -f "$GAME_FILE" ] && [ "$(jq -r '.enabled' "$GAME_FILE" 2>/dev/null)" = "true" ]; then
  GAME_JSON="$(jq '{ features, skillUsage, mcpUsage, agentUsage, sessionCount }' "$GAME_FILE")"
fi

# --- Final output ---

jq -n \
  --argjson skills "$SKILLS_ARRAY" \
  --argjson mcpServers "$MCP_ARRAY" \
  --argjson agents "$AGENTS_ARRAY" \
  --argjson gameData "$GAME_JSON" \
  '{ skills: $skills, mcpServers: $mcpServers, agents: $agents, gameData: $gameData }'
