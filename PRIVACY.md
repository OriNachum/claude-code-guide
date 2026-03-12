# Privacy Policy

**Claude Code Guide Plugin**
**Last updated:** March 12, 2026

## Overview

The Claude Code Guide plugin is an open-source plugin that provides interactive guidance for Claude Code. This privacy policy explains what data the plugin collects and how it is handled.

## Data Collection

### Game Mode (opt-in)

When you enable Game Mode (`/guide:game-mode on`), the plugin tracks your usage of Claude Code features **locally on your machine**:

- **Feature usage counts** — which categories of tools you use (e.g., shell, editing, search) and how many times
- **Session count** — how many Claude Code sessions you've completed
- **Token usage** — approximate input/output tokens per session (best-effort, from hook payload)
- **Suggested features** — which feature suggestions have been shown to you

This data is stored in `.local/game-data.json` within the plugin directory. This file is gitignored and **never leaves your machine**.

### What Is NOT Collected

- No personal information
- No network requests are made
- No data is transmitted to any server, API, or third party
- No cookies or browser storage
- No telemetry or analytics

## What the Plugin Contains

The plugin includes:

- **Four skills:** `/guide:onboard` (getting-started walkthrough), `/guide:ask` (Q&A against reference docs), `/guide:game-mode` (gamified usage tracker), `/guide:level-up` (feature roadmap and coaching)
- **Reference documentation** in `skills/ask/references/` (Markdown files)
- **Three hook events** that power Game Mode:
  - `PostToolUse` — detects which tool category was used ([track-usage.sh](hooks/scripts/track-usage.sh))
  - `UserPromptSubmit` — detects slash-command usage ([track-prompt.sh](hooks/scripts/track-prompt.sh))
  - `Stop` — counts sessions, tracks tokens, and shows Fibonacci-spaced nudges ([track-stop.sh](hooks/scripts/track-stop.sh))
- **A data migration script** ([migrate-data.sh](hooks/scripts/migrate-data.sh)) for schema upgrades
- Plugin and marketplace manifests (`.claude-plugin/`)

Hooks only run when Game Mode is enabled. When disabled, each hook script exits immediately after checking the enabled flag.

## Third-Party Services

This plugin does not integrate with any third-party services. It has no MCP servers and makes no network requests. Hook scripts use standard system utilities (`jq`, `flock`) when available.

## Open Source

The full source code is publicly available at [https://github.com/OriNachum/claude-code-guide](https://github.com/OriNachum/claude-code-guide) under the CC BY 4.0 license. You can inspect every file the plugin includes.

## Changes to This Policy

If the plugin's functionality changes in a way that affects data handling, this privacy policy will be updated accordingly. Changes will be reflected in the repository and the "Last updated" date above.

## Contact

For questions about this privacy policy, please open an issue on the [GitHub repository](https://github.com/OriNachum/claude-code-guide/issues) or contact the maintainer, Ori Nachum.
