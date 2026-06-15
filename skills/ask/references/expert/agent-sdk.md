---
title: "Claude Agent SDK"
parent: "Integrations"
nav_order: 1
permalink: /agent-sdk/
---

# Claude Agent SDK

> **Level: 🌳 Expert** | **Source:** [Claude Agent SDK](https://docs.anthropic.com/en/docs/claude-code/sdk)
>
> **Rename notice:** The Claude Code SDK has been renamed to the **Claude Agent SDK**. The packages are now `@anthropic-ai/claude-agent-sdk` (TypeScript) and `claude-agent-sdk` (Python). If you're migrating from the old package names, see the [Migration Guide](https://platform.claude.com/docs/en/agent-sdk/migration-guide).

The Claude Agent SDK gives you programmatic access to Claude Code from TypeScript and Python. It wraps the CLI in a native API with structured inputs/outputs, streaming, tool control, session management, and hooks — all from your own application code.

**Packages:**

- TypeScript: `@anthropic-ai/claude-agent-sdk` ([npm](https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk))
- Python: `claude-agent-sdk` ([PyPI](https://pypi.org/project/claude-agent-sdk/))

---

## When to Use the SDK

| Scenario | Best tool |
|---|---|
| Interactive coding session | CLI (`claude`) |
| PR review, issue triage in CI | [GitHub Actions](../intermediate/github-actions.md) |
| Connecting external tools to Claude | [MCP](../intermediate/mcp.md) |
| Lifecycle guardrails & automation | [Hooks](../intermediate/hooks.md) |
| Embedding Claude Code in your app, building custom tooling, orchestrating multi-turn workflows programmatically | **Agent SDK** |

Use the SDK when you need **programmatic control** — launching Claude from application code, processing structured outputs, managing sessions, or building custom agents on top of Claude Code.

---

## Getting Started: TypeScript

Install:

```bash
npm install @anthropic-ai/claude-agent-sdk
```

Minimal example:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

const messages = [];
for await (const message of query({
  prompt: "Explain what this project does",
  options: {
    maxTurns: 3,
  },
})) {
  messages.push(message);
}

console.log(messages);
```

The `query()` function is the primary interface. It returns an async generator that yields conversation messages as they arrive — use `for await` to iterate. Pass `options.abortController` to cancel a running query.

---

## Getting Started: Python

Install:

```bash
pip install claude-agent-sdk
```

Minimal example:

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    messages = []
    async for message in query(
        prompt="Explain what this project does",
        options=ClaudeAgentOptions(max_turns=3),
    ):
        messages.append(message)
    print(messages)

anyio.run(main)
```

The Python SDK mirrors the TypeScript API. It requires Python 3.10+ and the Claude Code CLI installed on the machine — the SDK spawns `claude` under the hood, using whatever authentication and configuration you already have.

---

## Key Concepts

### The `query()` API

Both SDKs expose a `query()` function as the primary interface:

- **`prompt`** — the user message to send
- **`options.maxTurns`** / **`max_turns`** — limit how many agentic turns Claude can take
- **`options.systemPrompt`** / **`system_prompt`** — custom system prompt
- **`options.cwd`** / **`cwd`** — working directory for file operations
- **`options.permissionMode`** / **`permission_mode`** — set permission behavior (e.g., `"bypassPermissions"` for CI)
- **`options.settingSources`** / **`setting_sources`** — which config to load: `"user"`, `"project"`, `"local"`. Not loaded by default; include `"project"` to load CLAUDE.md and project hooks

### Built-in Tools

Claude Code's built-in tools (Read, Write, Edit, Bash, Glob, Grep, etc.) are available in SDK sessions — the same tools Claude uses in CLI mode. Use the `tools` option to set which tools are available, and `allowedTools` / `allowed_tools` to auto-approve specific tools without prompting.

### Hooks

[Hooks](../intermediate/hooks.md) work the same way in SDK sessions as in CLI sessions. Your `hooks.json` configuration fires on the same lifecycle events (PreToolUse, PostToolUse, Stop, etc.). You can also configure hooks programmatically via the options.

### Sub Agents

You can run [sub agents](sub-agents.md) from SDK sessions. The SDK supports the full agent delegation model — sub agents get their own context, tools, and permissions, just like when launched from the CLI.

### MCP Integration

[MCP servers](../intermediate/mcp.md) configured in your project are available in SDK sessions. You can also configure MCP servers programmatically via the options.

### Session Management

The SDK supports session continuity:

- **Resume** — continue a previous conversation by passing `options.resume` / `resume` with a session ID
- **Continue** — automatically continue the most recent session with `options.continue` (mutually exclusive with `resume`)
- **Fork** — branch from a resumed session with `options.forkSession` / `fork_session`

This enables building multi-step workflows where each step picks up from the previous one.

### Permissions and Safety

The SDK offers layered permission control:

- **`permissionMode`** / **`permission_mode`** — `default`, `acceptEdits`, `auto`, `bypassPermissions`, `plan`, or `dontAsk`. Use `bypassPermissions` for CI (equivalent to `--dangerously-skip-permissions`) — requires also setting `allowDangerouslySkipPermissions: true`.
- **`canUseTool`** / **`can_use_tool`** — callback invoked when Claude requests tool approval. Return `{ behavior: "allow", updatedInput }` or `{ behavior: "deny", message }`. See the [Real-World Example](#real-world-example-claude-code--slack) for a production use of this pattern.
- **`disallowedTools`** / **`disallowed_tools`** — block specific tools even in `bypassPermissions` mode.

For production, combine `tools` (restrict the base set) with `disallowedTools` (block dangerous ones) and `canUseTool` (custom approval logic).

### Structured Outputs

You can request structured output by passing a JSON schema via `options.outputFormat` / `output_format`. Claude will return a response conforming to the schema, useful for building pipelines that consume Claude's output programmatically.

---

## Cloud Provider Support

The SDK works with Claude on Bedrock, Vertex AI, and Azure AI Foundry via environment variables:

| Provider | Environment variables |
|---|---|
| **Amazon Bedrock** | `CLAUDE_CODE_USE_BEDROCK=1`, plus standard AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`) |
| **Google Vertex AI** | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| **Azure AI Foundry** | `CLAUDE_CODE_USE_FOUNDRY=1`, plus Azure credentials |

These same environment variables work for both CLI and SDK usage.

---

## SDK vs Other Integration Methods

| Aspect | SDK | GitHub Actions | MCP | Hooks | CLI |
|---|---|---|---|---|---|
| **Primary use** | Embed in apps | CI/CD pipelines | Connect external tools | Lifecycle automation | Interactive use |
| **Language** | TypeScript, Python | YAML workflows | JSON config | Shell, HTTP, LLM prompts | Shell |
| **Structured output** | Yes (JSON schema) | Text only | N/A | N/A | Text / JSON |
| **Session management** | Resume, fork | Single-shot | N/A | N/A | Resume |
| **Tool control** | Programmatic | Via settings JSON | Server-defined | Event-based | Interactive |
| **Best for** | Custom tooling, pipelines, apps | Automated PR review, scheduled tasks | External services, databases | Guardrails, validation, logging | Day-to-day development |

---

## Real-World Example: Claude Code + Slack

[`claude-code-slack-vscode`](https://github.com/OriNachum/autonomous-intelligence) is a VS Code extension that bridges Claude Code with Slack using the Agent SDK. It demonstrates several advanced SDK patterns in a production context.

**What it does:** Lets you run Claude Code sessions from Slack threads, with bidirectional streaming of messages, permissions, and file uploads — all orchestrated through a VS Code extension.

**SDK features used:**

- **`query()`** — launches Claude sessions from TypeScript application code
- **`canUseTool` / `can_use_tool` permission callbacks** — custom permission flow where Slack Block Kit buttons and VS Code webview race to respond (first-response-wins)
- **Session management** — resume capability for long-running conversations
- **Hooks** — `Notification` and `SessionInit` events for lifecycle integration

**Architecture:**

```text
VS Code Extension
  └─► Agent SDK client (query())
        ├─► Claude Code session
        └─► Slack thread (bidirectional)
              ├─ Messages streamed to/from Slack
              ├─ Permission requests → Block Kit buttons
              └─ File uploads via Slack API
Python daemon (Docker) ─► Slack Socket Mode + file-based IPC
```

**Key pattern:** The permission flow is the most interesting part. When Claude requests tool approval, the `canUseTool` callback sends a Block Kit message to Slack *and* shows a prompt in VS Code. Whichever responds first wins — the other is dismissed. This lets operators approve actions from their phone via Slack without needing VS Code open.

---

## Next Steps

- [Official SDK documentation](https://docs.anthropic.com/en/docs/claude-code/sdk) — full API reference, advanced options, and examples
- [GitHub Actions](../intermediate/github-actions.md) — if your use case is CI/CD, Actions may be simpler than the SDK
- [Hooks](../intermediate/hooks.md) — lifecycle automation that works in both CLI and SDK sessions
- [Sub Agents](sub-agents.md) — delegate tasks to specialist agents
- [Automating Your Workflows](../intermediate/automating-your-workflows.md) — overview of all automation mechanisms
