# Privacy Policy

**Claude Code Guide Plugin**
**Last updated:** March 5, 2026

## Overview

The Claude Code Guide plugin is an open-source, content-only plugin that provides interactive guidance for Claude Code. This privacy policy explains what data the plugin does and does not collect.

## Data Collection

**This plugin does not collect, store, transmit, or process any user data.**

Specifically, the plugin:

- Does **not** collect personal information
- Does **not** collect usage analytics or telemetry
- Does **not** make network requests
- Does **not** use cookies or local storage
- Does **not** include any executable scripts, hooks, or MCP servers
- Does **not** communicate with any external services

## What the Plugin Contains

The plugin consists entirely of static Markdown files:

- Two skills: `/guide:onboard` (getting-started walkthrough) and `/guide:ask` (Q&A against reference docs)
- Reference documentation in `skills/ask/references/` (Markdown files)
- A plugin manifest (`.claude-plugin/plugin.json`)
- A marketplace manifest (`.claude-plugin/marketplace.json`)

All content is read-only and runs entirely within your local Claude Code session. No data leaves your machine as a result of using this plugin.

## Third-Party Services

This plugin does not integrate with any third-party services. It has no MCP servers, no hooks, and no external dependencies.

## Open Source

The full source code is publicly available at [https://github.com/OriNachum/claude-code-guide](https://github.com/OriNachum/claude-code-guide) under the CC BY 4.0 license. You can inspect every file the plugin includes.

## Changes to This Policy

If the plugin's functionality changes in a way that affects data handling, this privacy policy will be updated accordingly. Changes will be reflected in the repository and the "Last updated" date above.

## Contact

For questions about this privacy policy, please open an issue on the [GitHub repository](https://github.com/OriNachum/claude-code-guide/issues) or contact the maintainer, Ori Nachum.
