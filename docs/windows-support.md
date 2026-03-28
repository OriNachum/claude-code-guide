---
title: Windows Support
parent: Getting Started
nav_order: 6
permalink: /getting-started/windows-support/
---

# Windows Support

This plugin is tested and supported on **Windows**, **macOS**, and **Linux (Ubuntu)**.

On Windows, Claude Code runs hook scripts via **Git Bash (MINGW64)**, which ships with [Git for Windows](https://gitforwindows.org/). This provides a POSIX-compatible environment where the plugin's bash scripts work correctly.

## What works out of the box

Most GNU utilities that the plugin depends on are included with Git Bash:

| Tool | Used for | Git Bash status |
|------|----------|-----------------|
| `bash` | Hook script execution | Included |
| `mktemp` | Atomic file writes | Included |
| `date -u` | UTC timestamps | Included (GNU date) |
| `sed -E` | Regex parsing | Included (GNU sed) |
| `grep -E` | Pattern matching | Included (GNU grep) |
| `awk` | Score calculations | Included (GNU awk) |
| `wc`, `tr`, `cut`, `xargs` | Text processing | Included |

## Required: jq

The one dependency **not** included with Git Bash is [`jq`](https://jqlang.github.io/jq/), a JSON processor used by all hook scripts for reading and writing game data.

**Without jq:** Most plugin skills (`/guide:onboard`, `/guide:ask`, `/guide:migrate-to-claude`) work normally. Game Mode hooks will silently skip tracking — no errors, but no usage data will be collected. When you run `/guide:game-mode` or `/guide:level-up`, Claude will detect jq is missing and show installation instructions.

### Installing jq on Windows

**Option 1 — Download to your user bin directory (Git Bash):**

```bash
mkdir -p ~/bin
curl -sL https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe -o ~/bin/jq.exe
chmod +x ~/bin/jq.exe
```

Git Bash includes `~/bin` in `PATH` by default. Verify with:

```bash
jq --version
```

**Option 2 — Chocolatey:**

```powershell
choco install jq
```

**Option 3 — Ask Claude:**

Just tell Claude: "install jq" — it will handle the download.

### Installing jq on other platforms

| Platform | Command |
|----------|---------|
| macOS | `brew install jq` |
| Ubuntu/Debian | `sudo apt install jq` |
| Fedora/RHEL | `sudo yum install jq` |

## Windows-specific adjustments

The plugin includes the following adjustments for Windows compatibility:

### Path normalization

Claude Code on Windows provides file paths with backslashes (e.g., `C:\Users\you\.claude\plans\file.md`). The hook scripts normalize these to forward slashes before pattern matching, so features like plan-file detection work correctly on all platforms.

**Affected file:** `hooks/scripts/track-usage.sh`

### Graceful jq fallback

All hook scripts check for `jq` availability before running. If jq is not installed, hooks exit silently with no error output. This ensures the plugin never disrupts your workflow — hooks install automatically with the plugin and should never produce unexpected errors.

**Affected files:** All scripts in `hooks/scripts/`

### File locking

The plugin uses `flock` for file locking when it is available. If `flock` is unavailable (for example, in default Windows or macOS setups), locking is gracefully skipped. This is safe because hook invocations within a single Claude Code session are sequential, and the game data file is low-risk (worst case: a counter is off by one).

**Affected files:** All tracking scripts in `hooks/scripts/`

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Game mode shows zero counts after use | jq not installed | Install jq (see above) |
| Hook errors in terminal | Unexpected — hooks are designed to fail silently | Check `jq --version`; if missing, install it |
| Plan-file writes tracked as "editing" instead of "planning" | Path normalization issue | Update to latest plugin version |

## Platform test matrix

| Platform | Shell | Status |
|----------|-------|--------|
| Windows 11 | Git Bash (MINGW64) | Tested |
| macOS | zsh / bash | Tested |
| Ubuntu Linux | bash | Tested |
