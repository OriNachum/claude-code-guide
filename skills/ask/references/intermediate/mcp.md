---
title: "MCP"
parent: "Configuration & Extensions"
nav_order: 5
permalink: /mcp/
---

# MCP (Model Context Protocol)

> **Level: 🌿 Intermediate** | **Source:** [MCP](https://docs.anthropic.com/en/docs/claude-code/mcp)

← [Back to Automating Your Workflows](automating-your-workflows.md)

MCP gives Claude access to external tools and data sources through a standardized protocol. An MCP server exposes a set of tools, and Claude can call them during a session.

But before you reach for MCP, understand when it's the right choice — and when it isn't.

## The Restaurant Analogy

Think of MCP like eating at a restaurant.

You sit down, get a **menu** (the list of tools the MCP server exposes), you **choose** what you want (Claude picks the right tool for the task), and a **server prepares it for you** (the MCP server executes the tool and returns results). You don't cook anything yourself — you order, and it arrives.

For **eating out**, this is great. You get food you couldn't easily make at home, prepared by specialists, without setting up your own kitchen.

For **eating at home**, you wouldn't call a restaurant every time you want toast. You'd just make it yourself — or have someone in your household (a sub agent) prepare it for you.

**MCP is eating out.** It's the right choice when the capability is hosted elsewhere, maintained by someone else, and you want it constantly available on a menu. It's the wrong choice when you could just do the thing directly.

## When to Use MCP

MCP makes sense in two specific situations:

**1. The capability is hosted elsewhere and constantly needed**

The service lives on a remote server, it's maintained by a third party, and you want it available as a persistent menu of tools in every session. Examples: GitHub (issues, PRs, repos), Sentry (error monitoring), Notion (docs), Slack (messaging).

**2. You need the menu-serve design pattern**

The value comes from having a structured menu of operations that Claude can browse and invoke — and having the server execute them. This is the streaming, always-available, tool-discovery pattern that MCP provides natively.

## When NOT to Use MCP

Most of the time, prefer simpler alternatives:

| Situation | Instead of MCP, use... |
|---|---|
| CLI tool exists for the service | Just use the CLI directly. Claude works great with `gh`, `aws`, `gcloud`, `kubectl`, `jq`, `curl`, and most CLI tools. Try: "Use gh to list open PRs." |
| You want Claude to run a script or tool | Use a **Skill** that tells Claude how to run it, or a **Sub Agent** that runs it in isolation |
| One-off API call | Use `curl` or `WebFetch` — no server needed |
| You wrote a custom tool for your project | Make it a **Skill** or a **Sub Agent** with bash access. Simpler, no protocol overhead |
| You want to query a local database | A sub agent with bash access to `psql`/`sqlite3` is often simpler than an MCP server |

**Rule of thumb:** If you can do it with a CLI command, a skill, or a sub agent — do that instead. MCP adds protocol overhead, another process to manage, and another thing that can break. Reserve it for things that genuinely benefit from the menu-serve pattern with an external host.

## Adding an MCP Server

### Remote HTTP server (recommended for cloud services)

```bash
# Basic syntax
claude mcp add --transport http <name> <url>

# Example: Connect to GitHub
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# With authentication header
claude mcp add --transport http my-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

### Local stdio server

```bash
# Basic syntax
claude mcp add [options] <name> -- <command> [args...]

# Example: Database access
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@host:5432/mydb"
```

**Important:** All options (`--transport`, `--env`, `--scope`) must come before the server name. The `--` separates the server name from the command that gets passed to the MCP server.

> **Note:** The SSE (Server-Sent Events) transport is deprecated. Use HTTP servers instead, where available.

### Authentication for remote servers

Many cloud MCP servers use OAuth. After adding the server, authenticate inside Claude Code:

```
/mcp
```

Follow the browser flow to log in. Tokens are stored securely and refreshed automatically.

## Managing Servers

```bash
# List all configured servers
claude mcp list

# Get details for a specific server
claude mcp get github

# Remove a server
claude mcp remove github

# Check status inside Claude Code
/mcp
```

## Scopes: Who Can See the Server

| Scope | Stored in | Shared? | Use for |
|---|---|---|---|
| `local` (default) | `~/.claude.json` | No — just you, this project | Personal servers, experiments, sensitive credentials |
| `project` | `.mcp.json` (project root) | Yes — committed to git | Team-shared servers, project-specific tools |
| `user` | `~/.claude.json` | No — just you, all projects | Personal utilities you use across projects |

```bash
# Add a project-scoped server (shared with team)
claude mcp add --transport http notion --scope project https://mcp.notion.com/mcp

# Add a user-scoped server (personal, all projects)
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

For team sharing via `.mcp.json`, Claude Code prompts for approval before using project-scoped servers. Reset with `claude mcp reset-project-choices`.

### Environment variables in .mcp.json

Use `${VAR}` or `${VAR:-default}` for machine-specific paths and secrets:

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

## 🌳 MCP in Plugins

Plugins can bundle MCP servers alongside skills, agents, and hooks. When a plugin is enabled, its MCP servers start automatically. Define them in `.mcp.json` at the plugin root or inline in `plugin.json`.

See [Plugins](plugins.md) for details on plugin structure and distribution.

## MCP Resources and Prompts

MCP servers can expose more than tools:

**Resources** — reference data with `@server:protocol://path` in your prompts. Type `@` to see available resources from connected servers.

**Prompts** — server-provided commands available as `/mcp__servername__promptname`. Type `/` to discover them.

## Tool Search (Scaling with Many Servers)

When you have many MCP servers, tool definitions can eat context. Claude Code automatically enables Tool Search when MCP tool descriptions exceed 10% of the context window — tools load on-demand instead of all at once.

Control with `ENABLE_TOOL_SEARCH`:
- `auto` (default) — activates when tools exceed 10% of context
- `auto:5` — custom threshold (5%)
- `true` — always on
- `false` — disabled, all tools loaded upfront

## Practical Tips

- **Check `/mcp` regularly** to verify your servers are healthy and connected
- **Set `MAX_MCP_OUTPUT_TOKENS`** if you work with servers that return large results (default: 25,000 tokens, warning at 10,000)
- **Import from Claude Desktop:** `claude mcp add-from-claude-desktop` brings over your existing config
- **Claude.ai servers sync automatically** if you're logged in with a Claude.ai account
- **Use Claude Code as an MCP server** for other apps: `claude mcp serve` exposes Claude's tools via stdio

## The Decision Checklist

Before adding an MCP server, ask yourself:

1. **Is there a CLI tool for this?** → Use the CLI instead
2. **Can a skill or sub agent handle it?** → Use those instead
3. **Is this a one-off call?** → Use `curl` or `WebFetch`
4. **Is the capability hosted elsewhere and constantly needed?** → MCP is a good fit
5. **Do I need the menu-serve pattern with streaming?** → MCP is a good fit

If you answered yes to 4 or 5 — add the MCP server. Otherwise, keep it simple.

## Next Steps

- Run `/mcp` to see your currently configured servers
- See [Setting Your Environment](../beginner/setting-your-environment.md) for initial MCP setup
- See [Plugins](plugins.md) for bundling MCP servers in plugins
- See [Automating Your Workflows](automating-your-workflows.md) for the bigger picture
- See the [official MCP docs](https://code.claude.com/docs/en/mcp) for advanced configuration, managed deployments, and OAuth details
