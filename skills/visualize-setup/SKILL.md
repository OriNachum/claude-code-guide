---
description: "Generate an HTML dashboard visualizing all installed Claude Code skills, plugins, and MCP servers with usage statistics and martial arts belt levels."
disable-model-invocation: true
allowed-tools: Bash, Read
---

# Visualize Setup

Generate an interactive HTML dashboard of all installed
Claude Code skills, plugins, and MCP servers.

## Procedure

### Step 1 — Build and open the dashboard

Run the build script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/visualize-setup/scripts/build-dashboard.sh"
```

This script:

1. Discovers global, project, and plugin-installed skills
2. Discovers global and project MCP servers
3. Reads game-mode usage data (if enabled)
4. Injects all data into the HTML template
5. Writes `/tmp/claude-skills-dashboard.html`
6. Opens it in the default browser

### Step 2 — Handle errors

If the script fails:

- Read the error output and diagnose
- Common issues: `jq` not installed, missing permissions
- Read the failing script to understand the issue
- Fix and re-run

## Important notes

- Re-scans fresh each invocation (no caching)
- The HTML template is at `assets/template.html`
  relative to this skill — do not regenerate it
- Discovery script is at `scripts/discover.sh`
