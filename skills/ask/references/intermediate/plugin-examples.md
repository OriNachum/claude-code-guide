---
title: "Plugin Examples"
parent: "Configuration & Extensions"
nav_order: 4
permalink: /plugin-examples/
---

# Plugin Examples

> **Level: 🌿 Intermediate** | **Source:** [Plugins](https://docs.anthropic.com/en/docs/claude-code/plugins)

[← Back to Plugins](plugins.md)

A curated showcase of notable Claude Code plugins — what they do, what patterns they demonstrate, and how to install them. Use these as inspiration for your own plugins or as starting points for extending Claude Code.

## Official Plugins

These are maintained by Anthropic and available in the default marketplace (`claude-plugins-official`).

### frontend-design

**What it does:** Improves Claude's frontend and UI work by providing design-aware guidance. When you're building UI components, the skill activates automatically based on your prompt — no slash command needed.

**Components:** Skill (auto-invoked)

**Pattern: Auto-invocation via description matching.** The skill's `description` field matches frontend/design-related prompts, so Claude invokes it without you typing a slash command. This is the simplest plugin architecture — a single skill file that enhances Claude's behavior in a specific domain.

```shell
/plugin install frontend-design@claude-plugins-official
```

### code-review

**What it does:** Performs thorough code reviews by spawning five parallel sub agents, each focused on a different aspect: correctness, security, performance, maintainability, and test coverage. The agents work simultaneously and their findings are synthesized into a unified review.

**Components:** Agents (5 parallel), Skills

**Pattern: Parallel sub agent architecture.** Demonstrates how to decompose a complex task into independent specialist agents that run in parallel. Each agent has its own system prompt and focus area. The orchestrating skill combines their outputs into a coherent review.

```shell
/plugin install code-review@claude-plugins-official
```

### plugin-dev

**What it does:** Guides you through creating a new Claude Code plugin end-to-end — component design, implementation, and validation. Walks you through scaffolding the directory structure, writing the manifest, creating skills/agents/hooks, and testing.

**Components:** Skills

**Pattern: Meta-plugin (guides plugin creation).** Uses Claude's own extension system to help you build new extensions. This is a useful pattern for tooling that bootstraps or configures other tooling — the plugin equivalent of a project generator.

```shell
/plugin install plugin-dev@claude-plugins-official
```

## Community-Managed Plugins (on Official Marketplace)

These are available on the official marketplace but maintained by community members rather than Anthropic.

### context7 (Upstash)

**What it does:** Gives Claude access to up-to-date library and framework documentation via MCP. When you're working with a library, context7 fetches the current docs so Claude doesn't rely on training data that may be outdated.

**Components:** MCP, Skills, Agents, Commands

**Pattern: MCP-in-a-plugin.** Shows how to bundle an MCP server inside a plugin, giving Claude access to an external service (in this case, a documentation API). The plugin also includes skills and commands that make the MCP integration user-friendly.

```shell
/plugin install context7@claude-plugins-official
```

### claude-code-setup (schuettc)

**What it does:** A meta-plugin that helps configure Claude Code itself. It detects your project type and suggests appropriate CLAUDE.md content, permissions, and tool configurations.

**Components:** Skills, project detection

**Pattern: Meta-plugin (configures Claude).** Rather than adding new capabilities, this plugin improves Claude's existing setup process. It reads your project structure and generates tailored configuration — a useful pattern for teams that want to standardize how Claude Code is configured across projects.

```shell
/plugin marketplace add schuettc/claude-code-setup
/plugin install claude-code-setup@claude-code-setup
```

## Content-Only Plugins

### claude-code-guide (this repo)

**What it does:** Provides interactive onboarding and Q&A about Claude Code features, backed by comprehensive reference documentation.

**Components:** Skills, reference docs

**Pattern: Content-only plugin.** No hooks, no MCP servers, no agents — just skills that read markdown reference files and answer questions. This pattern is ideal for documentation, guides, and knowledge bases. The plugin has zero side effects and works purely through prompts.

```shell
/plugin marketplace add OriNachum/claude-code-guide
/plugin install guide@claude-code-guide
```

## Patterns at a Glance

| Plugin | Author | Components | Key pattern |
|---|---|---|---|
| **frontend-design** | Anthropic | Skill | Auto-invocation via description matching |
| **code-review** | Anthropic | Agents, Skills | Parallel sub agent architecture |
| **plugin-dev** | Anthropic | Skills | Meta-plugin (guides plugin creation) |
| **context7** | Upstash | MCP, Skills, Agents, Commands | MCP-in-a-plugin |
| **claude-code-setup** | schuettc | Skills | Meta-plugin (configures Claude) |
| **claude-code-guide** | OriNachum | Skills, docs | Content-only plugin |

## Finding More Plugins

- **`/plugin`** — Browse the Discover tab in the built-in plugin browser
- **Official marketplace** — Available by default, curated by Anthropic
- **Community marketplaces** — Add with `/plugin marketplace add owner/repo`
- **GitHub search** — Search for repos with `.claude-plugin/plugin.json`

See [Marketplace](marketplace.md) for details on discovering, evaluating, and managing plugin sources.

## Next Steps

- Run `/plugin` to browse and install plugins
- See [Marketplace](marketplace.md) for marketplace management and publishing
- Return to [Plugins](plugins.md) for creating your own plugin
- See [Automating Your Workflows](automating-your-workflows.md) for the bigger picture
