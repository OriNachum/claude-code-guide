---
title: "Plugins"
parent: "Configuration & Extensions"
nav_order: 2
permalink: /plugins/
---

# Plugins

> **Level: 🌿 Intermediate** | **Source:** [Plugins](https://docs.anthropic.com/en/docs/claude-code/plugins), [Plugins Reference](https://docs.anthropic.com/en/docs/claude-code/plugins-reference)

[← Back to Automating Your Workflows](automating-your-workflows.md)

Plugins are shareable bundles of skills, agents, hooks, and MCP servers packaged into a single installable unit. Think of them as the "app store" layer on top of Claude Code's extension system.

## When to Use Plugins vs Standalone Config

| Approach | Best for |
|---|---|
| Standalone (`.claude/` directory) | Personal workflows, project-specific tweaks, quick experiments |
| Plugins | Sharing with teammates, distributing to community, reusing across projects |

**Rule of thumb:** Start with standalone config in `.claude/`. Convert to a plugin when you want to share it.

## Installing Plugins

> **Requires Claude Code v1.0.33 or later.** Run `claude --version` to check.

### From the built-in marketplace

```
/plugin
```

This opens an interactive browser where you can search, install, enable, and disable plugins. The official Anthropic marketplace (`claude-plugins-official`) is available by default.

To install directly by name:

```shell
/plugin install plugin-name@claude-plugins-official
```

### From a GitHub marketplace

Add a GitHub repo as a marketplace, then install plugins from it:

```shell
/plugin marketplace add owner/repo
/plugin install plugin-name@owner-repo
```

Or from the CLI:

```bash
claude plugin marketplace add owner/repo
claude plugin install plugin-name@owner-repo
```

### From a local directory (permanent install)

Add a local plugin directory as a marketplace, then install:

```shell
/plugin marketplace add ./my-plugin
/plugin install my-plugin@my-plugin
```

### From a team marketplace

If your team has a custom marketplace, it may be configured automatically via `extraKnownMarketplaces` in your project's `.claude/settings.json`. When you open the project, Claude Code prompts you to install the marketplace and its plugins.

### Load for current session only (development/testing)

```bash
claude --plugin-dir ./my-plugin
```

This loads the plugin without installing it permanently — useful for development and testing. You can load multiple plugins at once:

```bash
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

> **After installing a plugin, restart Claude Code** for its skills to become available. The `--plugin-dir` flag does not require a restart since it loads the plugin at launch.

## Installation Scopes

When you install a plugin, you choose where it applies:

| Scope | Settings file | Use case |
|---|---|---|
| **User** (default) | `~/.claude/settings.json` | Personal — available across all your projects |
| **Project** | `.claude/settings.json` | Team — shared via version control with all collaborators |
| **Local** | `.claude/settings.local.json` | Private to you in this repo only (gitignored) |

From the interactive UI (`/plugin` → Discover tab → select a plugin), you'll see all three options. From the CLI, use `--scope`:

```bash
claude plugin install my-plugin@marketplace --scope project
claude plugin uninstall my-plugin@marketplace --scope project
```

**Managed** scope is a fourth read-only scope set by administrators via managed settings — these plugins cannot be modified by users.

## Managing Installed Plugins

```shell
/plugin                    # Interactive UI — Installed tab to view/manage
/plugin disable name@mkt   # Disable without uninstalling
/plugin enable name@mkt    # Re-enable
/plugin uninstall name@mkt # Remove completely
/reload-plugins            # Apply changes without restarting
```

## What Plugins Can Include

A plugin is a directory with a `.claude-plugin/plugin.json` manifest and any combination of:

| Component | Directory | What it does |
|---|---|---|
| Skills | `skills/` | Reusable prompts and workflows (invoked as `/plugin-name:skill-name`) |
| Agents | `agents/` | Custom sub agents with their own tools and permissions |
| Hooks | `hooks/hooks.json` | Event handlers that fire on lifecycle events |
| MCP servers | `.mcp.json` | External tool integrations |
| LSP servers | `.lsp.json` | Language intelligence (go-to-definition, type errors, etc.) |
| Settings | `settings.json` | Default configuration applied when the plugin is enabled |

## Creating Your First Plugin

### 1. Create the directory structure

```bash
mkdir -p my-plugin/.claude-plugin
mkdir -p my-plugin/skills/hello
```

### 2. Write the manifest

Create `my-plugin/.claude-plugin/plugin.json`:

```json
{
  "name": "my-plugin",
  "description": "A helpful plugin for my team",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

### 3. Add a skill

Create `my-plugin/skills/hello/SKILL.md`:

```markdown
---
description: Greet the user and offer help
disable-model-invocation: true
---

Greet the user warmly and ask how you can help them today.
```

### 4. Test it

```bash
claude --plugin-dir ./my-plugin
```

Then type `/my-plugin:hello` to invoke your skill.

> **Important:** Don't put `skills/`, `agents/`, or `hooks/` inside `.claude-plugin/`. Only `plugin.json` goes in there. Everything else goes at the plugin root.

## Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (required)
├── skills/
│   └── code-review/
│       └── SKILL.md          # /my-plugin:code-review
├── agents/
│   └── security-reviewer.md  # Custom sub agent
├── hooks/
│   └── hooks.json            # Lifecycle hooks
├── .mcp.json                 # MCP server configs
├── .lsp.json                 # Language server configs
└── settings.json             # Default settings
```

## Namespacing

Plugin skills are namespaced to prevent conflicts: `/plugin-name:skill-name`. This means two plugins can both have a `review` skill without clashing.

## Converting Standalone Config to a Plugin

If you already have skills, agents, or hooks in `.claude/`, you can convert them:

1. Create a plugin directory with `.claude-plugin/plugin.json`
2. Copy your `.claude/skills/` → `my-plugin/skills/`
3. Copy your `.claude/agents/` → `my-plugin/agents/`
4. Move hook config from `.claude/settings.json` → `my-plugin/hooks/hooks.json`
5. Test with `claude --plugin-dir ./my-plugin`

After migrating, you can remove the originals from `.claude/` to avoid duplicates.

## Key Plugins to Know About

Notable plugins from the official and community marketplaces:

- **frontend-design** (Anthropic) — Auto-invoked skill that improves Claude's frontend/UI output
- **code-review** (Anthropic) — Parallel sub agent architecture for thorough code reviews
- **plugin-dev** (Anthropic) — Guided end-to-end plugin creation workflow
- **context7** (Upstash, community-managed) — MCP-powered access to up-to-date library documentation
- **claude-code-setup** (schuettc) — Meta-plugin that helps configure Claude Code for your project

For detailed descriptions, install instructions, and the patterns each plugin demonstrates, see [Plugin Examples](plugin-examples.md).

## 🌳 Distributing Your Plugin

Push your plugin to a Git repository and share it through a marketplace. You can submit to the [official Anthropic marketplace](https://claude.ai/settings/plugins/submit), create your own community marketplace on GitHub, or distribute via your team's internal marketplace using `extraKnownMarketplaces`.

For the full guide to marketplace creation, publishing, and discovery, see [Marketplace](marketplace.md).

## Next Steps

- Run `/plugin` to browse and install plugins
- See [Plugin Examples](plugin-examples.md) for a curated showcase of notable plugins and patterns
- See [Marketplace](marketplace.md) for discovering, browsing, evaluating, and publishing plugins
- See the [official plugin docs](https://code.claude.com/docs/en/plugins) for advanced patterns like LSP servers
- Return to [Automating Your Workflows](automating-your-workflows.md) for the bigger picture
