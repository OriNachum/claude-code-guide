# Plugins

[← Back to Automating Your Workflows](automating-your-workflows.md)

Plugins are shareable bundles of skills, agents, hooks, and MCP servers packaged into a single installable unit. Think of them as the "app store" layer on top of Claude Code's extension system.

## When to Use Plugins vs Standalone Config

| Approach | Best for |
|---|---|
| Standalone (`.claude/` directory) | Personal workflows, project-specific tweaks, quick experiments |
| Plugins | Sharing with teammates, distributing to community, reusing across projects |

**Rule of thumb:** Start with standalone config in `.claude/`. Convert to a plugin when you want to share it.

## Installing Plugins

### From the built-in marketplace

```
/plugin
```

This opens an interactive browser where you can search, install, enable, and disable plugins.

### From a team marketplace

If your team has a custom marketplace, it may be configured automatically via `extraKnownMarketplaces` in your project's `.claude/settings.json`. When you open the project, Claude Code prompts you to install the marketplace and its plugins.

### From a local directory (for development/testing)

```bash
claude --plugin-dir ./my-plugin
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

### Code Intelligence (LSP) Plugins

If you work with a typed language, install an LSP plugin to give Claude precise "go to definition", "find references", and automatic error detection after edits. Pre-built plugins exist for TypeScript, Python, Rust, and more — browse them in `/plugin`.

### Community Plugins

Browse the official Anthropic marketplace via `/plugin` for community-contributed plugins covering formatting, deployment, testing, and more.

## Distributing Your Plugin

Once your plugin is ready:

1. Push it to a Git repository
2. Create or join a marketplace (or submit to the [official Anthropic marketplace](https://claude.ai/settings/plugins/submit))
3. Others install it via `/plugin`

## Next Steps

- Run `/plugin` to browse and install plugins
- See the [official plugin docs](https://code.claude.com/docs/en/plugins) for advanced patterns like LSP servers and marketplace creation
- Return to [Automating Your Workflows](automating-your-workflows.md) for the bigger picture
