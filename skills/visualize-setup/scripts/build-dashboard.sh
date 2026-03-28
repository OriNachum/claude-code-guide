#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE="${SKILL_DIR}/assets/template.html"
OUTPUT="/tmp/claude-skills-dashboard.html"

# Run discovery
DATA="$("${SCRIPT_DIR}/discover.sh")"

# Extract the four data pieces and escape </script> sequences to prevent XSS
SKILLS_JSON="$(echo "$DATA" | jq -c '.skills' | sed 's|</|<\\/|g')"
MCP_JSON="$(echo "$DATA" | jq -c '.mcpServers' | sed 's|</|<\\/|g')"
AGENTS_JSON="$(echo "$DATA" | jq -c '.agents' | sed 's|</|<\\/|g')"
GAME_JSON="$(echo "$DATA" | jq -c '.gameData' | sed 's|</|<\\/|g')"

# Inject into template — use ENVIRON to avoid awk -v escape processing,
# and printf+substr to avoid gsub & replacement issues.
export SKILLS_JSON MCP_JSON AGENTS_JSON GAME_JSON
awk '
  BEGIN {
    skills = ENVIRON["SKILLS_JSON"]
    mcp    = ENVIRON["MCP_JSON"]
    agents = ENVIRON["AGENTS_JSON"]
    game   = ENVIRON["GAME_JSON"]
  }
  function replace(line, placeholder, value,    p, len) {
    len = length(placeholder)
    while ((p = index(line, placeholder)) > 0) {
      line = substr(line, 1, p-1) value substr(line, p+len)
    }
    return line
  }
  {
    $0 = replace($0, "__SKILLS_DATA__", skills)
    $0 = replace($0, "__MCP_DATA__", mcp)
    $0 = replace($0, "__AGENTS_DATA__", agents)
    $0 = replace($0, "__GAME_DATA__", game)
    printf "%s\n", $0
  }
' "$TEMPLATE" > "$OUTPUT"

# Open in browser
open "$OUTPUT" 2>/dev/null || xdg-open "$OUTPUT" 2>/dev/null || true

echo "Dashboard written to $OUTPUT"
