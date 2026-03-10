---
title: "Hooks HTTP"
parent: "Automation"
nav_order: 3
permalink: /hooks-http/
---

# HTTP Hooks

> **Level: 🌳 Expert** | **Source:** [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks)

[← Back to Hooks](../intermediate/hooks.md)

HTTP hooks send lifecycle event data as HTTP POST requests to a URL endpoint, instead of running a shell command. They use the same JSON input/output format as command hooks, making them interchangeable for most use cases.

## When to Use HTTP Hooks

HTTP hooks are the right choice when your hook logic lives outside the local machine:

- **External validation services** — a shared API that checks code quality or security policies
- **Centralized logging/auditing** — send every tool invocation to your observability stack
- **CI/CD webhooks** — trigger builds or deployments from Claude Code events
- **Team-shared policy servers** — enforce organization-wide rules from a single endpoint
- **Services that aren't local scripts** — anything reachable over HTTP that can process JSON

If your logic is a local script or one-liner, a [command hook](../intermediate/hooks.md) is simpler. Use HTTP hooks when the handler is a running service.

## Configuration

HTTP hooks are configured in the same `hooks` section of your settings JSON as command hooks. Instead of `type: "command"`, use `type: "http"`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:8080/validate",
            "headers": {
              "Authorization": "Bearer $API_TOKEN"
            },
            "allowedEnvVars": ["API_TOKEN"],
            "timeout": 30,
            "statusMessage": "Validating command..."
          }
        ]
      }
    ]
  }
}
```

### Fields

| Field | Required | Description |
|---|---|---|
| `type` | Yes | Must be `"http"` |
| `url` | Yes | URL to POST to |
| `headers` | No | Key-value pairs for request headers. Supports env var interpolation via `$VAR_NAME` or `${VAR_NAME}` |
| `allowedEnvVars` | No | List of env var names allowed for interpolation in `headers` |
| `timeout` | No | Seconds before canceling the request (command hooks default to 600; no documented default specific to HTTP) |
| `statusMessage` | No | Custom spinner text shown while the request is in flight |

## How It Works

Claude Code POSTs the event's JSON input to your URL with `Content-Type: application/json`. The request body is the same JSON that a command hook receives on stdin.

### Response handling

| Response | Result |
|---|---|
| 2xx + empty body | Success — execution continues |
| 2xx + plain text body | Success — text is added as context to the conversation |
| 2xx + JSON body | Parsed using the same JSON output schema as command hooks |
| Non-2xx status | Non-blocking error — execution continues |
| Connection failure / timeout | Non-blocking error — execution continues |

### Blocking actions

To block an action (e.g., deny a tool call), return a 2xx response with a JSON body containing a blocking decision:

```json
{
  "decision": "block",
  "reason": "This command is not allowed by policy"
}
```

For `PermissionRequest` hooks, use `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "permissionDecision": "deny"
  }
}
```

## Common Patterns

### Local validation service

A `PreToolUse` hook that validates Bash commands against a local policy service:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:9000/validate-command",
            "headers": {
              "Authorization": "Bearer $POLICY_TOKEN"
            },
            "allowedEnvVars": ["POLICY_TOKEN"],
            "statusMessage": "Checking command policy..."
          }
        ]
      }
    ]
  }
}
```

### Centralized audit logging

A `PostToolUse` hook that logs every tool invocation to a remote endpoint (fire-and-forget):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "http",
            "url": "https://logs.example.com/claude-audit",
            "headers": {
              "X-Team": "engineering"
            },
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Policy server for permission decisions

A `PermissionRequest` hook that delegates allow/deny decisions to a centralized policy server:

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "http",
            "url": "https://policy.internal.example.com/claude/permissions",
            "headers": {
              "Authorization": "Bearer $POLICY_SERVER_KEY"
            },
            "allowedEnvVars": ["POLICY_SERVER_KEY"],
            "statusMessage": "Checking permissions..."
          }
        ]
      }
    ]
  }
}
```

The server returns `{"hookSpecificOutput": {"permissionDecision": "allow"}}` or `{"hookSpecificOutput": {"permissionDecision": "deny"}}`.

## Important Notes

- **Manual configuration only** — HTTP hooks must be configured by editing settings JSON directly. The `/hooks` interactive menu only supports command hooks.
- **Deduplication** — Identical HTTP hooks are deduplicated by URL. If the same URL appears multiple times for the same event, it is called only once.
- **Parallel execution** — All matching hooks for an event run in parallel, including HTTP hooks alongside command or prompt hooks.

## Next Steps

- See [Hooks](../intermediate/hooks.md) for lifecycle events, matchers, and command/prompt hook types
- See the [official hooks reference](https://code.claude.com/docs/en/hooks) for full event schemas
- Return to [Automating Your Workflows](../intermediate/automating-your-workflows.md) to compare with Skills and Sub Agents
