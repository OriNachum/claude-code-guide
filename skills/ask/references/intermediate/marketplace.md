---
title: "Marketplace"
parent: "Configuration & Extensions"
nav_order: 3
permalink: /marketplace/
---

# Marketplace

> **Level: 🌿 Intermediate** | **Source:** [Plugin Marketplaces](https://docs.anthropic.com/en/docs/claude-code/plugin-marketplaces)

[← Back to Plugins](plugins.md)

The marketplace is how plugins get discovered and distributed. Claude Code supports multiple marketplace tiers, from Anthropic's official catalog to community-run collections and team-internal registries.

## Marketplace Tiers

| Tier | Source | How to access |
|---|---|---|
| **Official** | `anthropics/claude-plugins-official` (GitHub) | Available by default — just open `/plugin` |
| **Community** | Any GitHub repo with a `marketplace.json` | Add manually with `/plugin marketplace add owner/repo` |
| **Enterprise / Team** | Internal repos configured via `extraKnownMarketplaces` in project settings | Auto-prompted when you open the project |

The official marketplace is curated by Anthropic. Community marketplaces are maintained by their authors and are not reviewed by Anthropic. Team marketplaces let organizations distribute internal plugins without publishing them publicly.

## Browsing and Discovering Plugins

Open the plugin browser:

```shell
/plugin
```

Switch to the **Discover** tab to browse available plugins across all your configured marketplaces. For each plugin you'll see:

- **Name** and **description** — what it does in one line
- **Author** — who built and maintains it
- **Components** — which parts it includes (skills, agents, hooks, MCP servers, LSP servers)
- **Marketplace source** — which marketplace it comes from

### Marketplace Categories

Plugins generally fall into these categories:

| Category | What it covers | Examples |
|---|---|---|
| **Code Intelligence / LSP** | Language servers for go-to-definition, type errors, find references | TypeScript, Python, Rust LSP plugins |
| **External Integrations / MCP** | Connect Claude to external services and APIs | context7 (library docs), database connectors |
| **Development Workflows** | Skills and agents for common development tasks | code-review, frontend-design, TDD workflows |
| **Output Styles** | Control how Claude writes code and communicates | Formatting conventions, comment styles |

## Evaluating a Plugin Before Installing

Before installing, look at:

1. **README and description** — Does it clearly explain what the plugin does?
2. **Components** — What does it actually include? A plugin with hooks and MCP servers has more surface area than one with just skills.
3. **Author** — Is it from Anthropic, a known community maintainer, or an unknown source?
4. **Activity** — Is the repository actively maintained?

### Security Considerations

Plugins can include powerful components. Understand what you're installing:

- **Hooks** run shell commands on your machine in response to lifecycle events. A malicious hook could execute arbitrary code.
- **MCP servers** connect Claude to external services. They can send data outside your machine.
- **Skills** are just prompts — they're the safest component. They can't do anything Claude couldn't already do.
- **Agents** can use tools and modify files, but within Claude's existing permission model.

Anthropic reviews plugins in the official marketplace. Community marketplace plugins are **not** reviewed by Anthropic — evaluate them yourself before installing.

## Managing Marketplaces

### Add a marketplace

From within Claude Code:

```shell
/plugin marketplace add owner/repo
```

Or from the CLI:

```bash
claude plugin marketplace add owner/repo
```

### List configured marketplaces

```shell
/plugin marketplace list
```

### Remove a marketplace

```shell
/plugin marketplace remove owner/repo
```

### Add a local directory as a marketplace

```shell
/plugin marketplace add ./path/to/marketplace
```

This is useful for developing plugins locally or for team marketplaces distributed via file shares.

## 🌳 Creating Your Own Marketplace

A marketplace is a GitHub repository (or local directory) containing a `marketplace.json` file at the root. This file lists all plugins available in the marketplace.

### marketplace.json Format

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./my-plugin"
    },
    {
      "name": "another-plugin",
      "source": "./another-plugin"
    }
  ]
}
```

Each entry points to a directory within the repo that contains a valid plugin (with `.claude-plugin/plugin.json`).

### Hosting on GitHub

1. Create a GitHub repo for your marketplace
2. Add plugin directories to the repo, each with their own `.claude-plugin/plugin.json`
3. Create `marketplace.json` at the root listing all plugins with `"source": "./<plugin-dir>"`
4. Others add your marketplace with `/plugin marketplace add your-org/your-marketplace`

### Team Marketplaces via Settings

For team-wide distribution, add your marketplace to the project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": ["your-org/your-marketplace"]
}
```

When team members open the project, Claude Code prompts them to install the marketplace and its plugins. This avoids the manual `/plugin marketplace add` step.

## Publishing to the Official Marketplace

To submit a plugin to Anthropic's official marketplace:

1. Ensure your plugin has a complete `plugin.json` manifest (name, description, version, author)
2. Test it thoroughly with `claude --plugin-dir ./your-plugin`
3. Submit via the [official submission page](https://claude.ai/settings/plugins/submit)
4. Anthropic reviews the plugin before it appears in the official catalog

## Next Steps

- See [Plugin Examples](plugin-examples.md) for a curated showcase of notable plugins and the patterns they demonstrate
- Return to [Plugins](plugins.md) for installation, creation, and configuration details
- See [Automating Your Workflows](automating-your-workflows.md) for the bigger picture of hooks, skills, and sub agents
