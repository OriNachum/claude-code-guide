---
title: "Discovering Plugins"
parent: "User Stories"
nav_order: 6
permalink: /stories/discovering-plugins/
---

# Discovering and Installing Plugins

> **Level: 🌱 Beginner** | **Related:** [Plugins](https://docs.anthropic.com/en/docs/claude-code/plugins), [Plugin Marketplaces](https://docs.anthropic.com/en/docs/claude-code/plugin-marketplaces)

[← Back to References](intermediate/plugins.md)

## The Scenario

You've been using Claude Code for a few weeks. You're comfortable with the basics — asking questions, editing files, running commands. But you've heard about plugins and haven't explored them yet. Today, you decide to see what's available and set up your first plugins.

---

## The Walkthrough

### Step 1: Opening the Plugin Browser

You type `/plugin` and see the plugin browser for the first time. There are two tabs: **Installed** (empty) and **Discover**. You switch to Discover and see a list of available plugins from Anthropic's official marketplace.

Each plugin shows its name, a short description, who made it, and what components it includes (skills, agents, hooks, MCP servers). You scroll through and see plugins for code review, frontend design, language servers, and more.

> **What's Happening:** The [Marketplace](intermediate/marketplace.md) ecosystem has multiple tiers. The official Anthropic marketplace is available by default — no setup needed. Community marketplaces can be added later for more options.

### Step 2: Your First Plugin — frontend-design

You've been building a React dashboard this week and Claude's UI suggestions have been decent but generic. You notice **frontend-design** in the list: "Improves Claude's frontend and UI work." It's from Anthropic, and it contains a single auto-invoked skill. Low commitment.

You select it and choose **User** scope — you want it available across all your projects, not just this one. Claude installs it and you restart your session.

Now when you ask Claude to build a component, the responses are more design-aware — better spacing, accessibility considerations, responsive patterns. You didn't invoke anything — the skill's description matched your frontend prompts and activated automatically.

> **What's Happening:** Skills with a `description` field can be [auto-invoked](intermediate/skills.md) when the description matches what you're asking about. This is the simplest plugin pattern — a single skill that enhances Claude's behavior in a domain without requiring you to learn new commands.

### Step 3: A Heavier Plugin — code-review

Your team has been doing manual code reviews and you want Claude to help. You find **code-review** in the Discover tab. This one is more substantial: it includes 5 parallel agents (correctness, security, performance, maintainability, test coverage) plus orchestrating skills.

You install this one at **Project** scope — it goes into `.claude/settings.json` so your teammates get it too when they pull. After restarting, you test it on a recent PR branch. Claude spawns five agents that work in parallel, each focused on a different review dimension. The results come back as a unified review document.

> **What's Happening:** [Plugins](intermediate/plugins.md) can be installed at different scopes. **User** scope (in `~/.claude/settings.json`) is personal and global. **Project** scope (in `.claude/settings.json`) is shared with the team via version control. Choose the scope that matches who should have the plugin.

### Step 4: Building Your Own — plugin-dev

You've now installed two plugins and seen how they work. The claude-code-guide plugin you installed earlier was just markdown files — no application code at all. You think: "I could build something like this for my team's deployment runbook."

Back in the Discover tab, you find **plugin-dev** from Anthropic. It's a guided plugin creation workflow — skills, agents, hooks, structure, validation, the whole process. You install it.

```shell
/plugin install plugin-dev@claude-plugins-official
```

Now you can run `/plugin-dev:create-plugin` and Claude walks you through scaffolding a new plugin from scratch: choosing components, writing the manifest, creating skills, and testing with `--plugin-dir`. Within an hour you have a working deployment-runbook plugin ready to share with your team.

> **What's Happening:** Plugins can help you build more plugins. The [plugin-dev](intermediate/plugin-examples.md) plugin demonstrates the meta-plugin pattern — using Claude's own extension system to guide creation of new extensions. See [Plugins](intermediate/plugins.md) for the full manual approach to plugin creation.

### Step 5: An MCP Plugin — context7

Your current project uses several libraries with fast release cycles, and Claude sometimes suggests outdated APIs. Still in the Discover tab, you find **context7** from Upstash — it provides current library documentation via MCP. You notice it's marked as **community-managed**, meaning Upstash maintains it rather than Anthropic.

You check the description and components: MCP server, skills, agents, and commands. It's more substantial than a skills-only plugin, so you read the README before installing. Everything looks solid — active maintenance and clear documentation.

You install it and try asking about a library. Now Claude fetches the latest docs instead of relying on training data. The difference is immediate — function signatures match the version you're actually using.

```shell
/plugin install context7@claude-plugins-official
```

> **What's Happening:** [MCP servers](intermediate/mcp.md) connect Claude to external data sources. The context7 plugin bundles an MCP server that fetches library documentation on demand. Community-managed plugins on the official [marketplace](intermediate/marketplace.md) are maintained by their authors — check their documentation and activity before installing. See [Plugin Examples](intermediate/plugin-examples.md) for more examples of the MCP-in-a-plugin pattern.

### Step 6: Taking Stock

You check your plugin setup:

```shell
/plugin
```

On the **Installed** tab, you see:

| Plugin | Scope | Components | Why you installed it |
|---|---|---|---|
| **frontend-design** | User | Skill (auto-invoked) | Better UI/design output across all projects |
| **code-review** | Project | Agents, Skills | Team code review workflow for this project |
| **plugin-dev** | User | Skills | Guided plugin creation workflow |
| **context7** | User | MCP, Skills, Agents | Up-to-date library docs across all projects |

The pattern: lightweight personal tools at User scope, team workflow tools at Project scope. If you ever need to disable something, it's a quick `/plugin disable` away without uninstalling.

> **What's Happening:** Plugin management is designed to be low-friction. Install, disable, re-enable, uninstall — all from `/plugin`. See [Plugins](intermediate/plugins.md) for the full management commands.

---

## Key Takeaways

- **Start with `/plugin` → Discover tab.** Browse what's available before committing to anything.
- **Install lightweight plugins at User scope.** Skills-only plugins like frontend-design are low-risk and broadly useful.
- **Install team workflow plugins at Project scope.** Heavier plugins like code-review benefit from shared configuration.
- **Add community marketplaces for more options.** But evaluate community plugins before installing — check the author, components, and documentation.
- **MCP plugins connect Claude to live data.** If Claude's training data is insufficient for your libraries, MCP plugins like context7 bridge the gap.
- **You can always disable or uninstall.** Plugin management is reversible, so experiment freely.
