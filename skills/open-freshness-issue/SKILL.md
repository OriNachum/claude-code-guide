---
description: "Open a GitHub issue summarizing docs-freshness findings — lists which reference docs need updating and why."
allowed-tools: Bash, Read
---

# Open Freshness Issue

Create a GitHub issue listing reference docs that may be outdated
compared to official Anthropic documentation.

## When to use

- After running a docs-freshness check (manually or in CI)
- When you have identified inaccuracies but want to track them as an issue
  rather than (or in addition to) fixing them directly

## Procedure

### Step 1 --- Gather findings

If you already have findings from a previous analysis, use those.
Otherwise, delegate to the `doc-verifier` agent to produce a
verification report, then extract the failures.

Format findings as a JSON array:

```json
[
  {
    "file": "beginner/memory.md",
    "finding": "Default model listed as claude-3-sonnet, should be claude-4-sonnet",
    "source_url": "https://docs.anthropic.com/en/docs/claude-code/memory"
  }
]
```

### Step 2 --- Create the issue

Write the JSON to a temporary file and run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/open-freshness-issue/scripts/create-issue.sh" /tmp/freshness-findings.json
```

Or pipe directly:

```bash
echo '<json>' | bash "${CLAUDE_PLUGIN_ROOT}/skills/open-freshness-issue/scripts/create-issue.sh"
```

The script will:

- Validate the JSON input
- Skip if no findings (zero-length array)
- Skip if an open `docs-freshness` issue already exists (dedup)
- Create a GitHub issue with a markdown table of findings
- Output the issue URL to stdout

### Step 3 --- Report

Share the issue URL with the user.

If the script reports an existing open issue, share that URL instead
and let the user know.

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GH_TOKEN` or `GITHUB_TOKEN` | Yes | GitHub auth for `gh` CLI (automatic in CI) |
| `FRESHNESS_PR_URL` | No | Link to an associated PR (added to issue body) |

## Prerequisites

- `gh` CLI authenticated (`gh auth status`)
- `jq` installed
- The `docs-freshness` label must exist in the repository
