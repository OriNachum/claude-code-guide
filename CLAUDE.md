# CLAUDE.md — Agent Instructions

This file tells Claude Code (and other AI agents) how to work with this repository.

---

## What This Repo Is

A Claude Code guide, packaged as a plugin. There are seven skills:

- **`/guide:onboard`** — Interactive getting-started walkthrough for new users
- **`/guide:ask`** — Q&A skill backed by comprehensive reference documentation in `skills/ask/references/`
- **`/guide:introspect`** — Introspective Development — audit lifecycle coverage, find gaps, and improve your development environment
- **`/guide:game-mode`** — Gamified usage tracker that rewards feature breadth and depth with a level system
- **`/guide:level-up`** — Feature roadmap and personalized next-step coaching
- **`/guide:migrate-to-claude`** — Smart migration from other AI coding assistants (Cursor, Windsurf, Copilot, Codex, etc.) to Claude Code
- **`/guide:visualize-setup`** — Generate an interactive HTML dashboard of all installed Claude Code skills and MCP servers

This repo serves two audiences: humans browsing the docs on GitHub, and Claude Code users who install it as a plugin to get guided help.

This is primarily a **content** repo — no application code. The docs website builds with Jekyll and is deployed to Cloudflare Pages (see [Deployment](#deployment)). Bash hook scripts are tested with bats-core (see `tests/`).

---

## Plugin vs. Project Tooling

This repo serves two purposes — distinguish them before starting any work:

### Plugin features (ships to users)

Everything under `skills/`, `hooks/`, `.claude-plugin/`, and reference docs. These are what users get when they install the plugin:

- Skills (SKILL.md files)
- Hooks (hooks.json + tracking scripts)
- Reference documentation (`skills/ask/references/`)
- Game mode, level-up, migration, visualize-setup
- Plugin manifests (plugin.json, marketplace.json)

### Project tooling (maintains the repo)

Infrastructure that helps develop and maintain the plugin but does NOT ship to users:

- Agents (`agents/`) — doc-verifier, pr-review, version-bump
- CI workflows (`.github/workflows/`) — docs-freshness, pages, tests
- Test suite (`tests/`) — bats tests for hook scripts
- CLAUDE.md, README.md — repo documentation

### Before starting work

**Always ask: "Is this a plugin feature or project tooling?"** This determines:

| | Plugin feature | Project tooling |
|---|---|---|
| **Where** | `skills/`, `hooks/`, `.claude-plugin/` | `agents/`, `.github/`, `tests/` |
| **Version bump?** | Always | Usually not |
| **How to test** | User-facing verification | `bats tests/*.bats` or CI |

If it's unclear, ask before proceeding.

---

## Repository Structure

```text
claude-code-guide/
├── .claude-plugin/
│   ├── plugin.json ........................ Plugin manifest (name: "guide", version, metadata)
│   └── marketplace.json .................. Marketplace manifest
├── .github/
│   └── workflows/
│       ├── docs-freshness.yml ............. Weekly automated docs accuracy checker
│       └── tests.yml ...................... Bash test suite (bats-core)
├── _includes/
│   ├── footer_custom.html ................. Disclaimer footer
│   └── head_custom.html ................... .md twin <link rel=alternate> header
├── _plugins/
│   └── llm_markdown.rb .................... Build-time generator: .md twin per page + llms-full.txt
├── _sass/
│   └── color_schemes/
│       └── anthropic.scss ................. Anthropic cream color scheme
├── hooks/
│   ├── hooks.json ......................... Hook event configuration (PostToolUse, UserPromptSubmit, Stop)
│   └── scripts/
│       ├── track-usage.sh ................. PostToolUse handler — tracks feature usage
│       ├── track-prompt.sh ................ UserPromptSubmit handler — tracks slash-command usage
│       ├── track-stop.sh .................. Stop handler — token tracking, session counting, and Fibonacci nudges
│       └── migrate-data.sh ................ Lightweight schema migration on version upgrade
├── skills/
│   ├── onboard/
│   │   └── SKILL.md ...................... Interactive getting-started walkthrough
│   ├── ask/
│   │   ├── SKILL.md ...................... Q&A against reference docs
│   │   └── references/ ................... Reference docs organized by difficulty tier
│   │           ├── beginner/ ............. 🌱 Beginner feature docs
│   │           │   ├── built-ins.md
│   │           │   ├── choosing-your-model.md
│   │           │   ├── memory.md
│   │           │   ├── setting-your-environment.md
│   │           │   └── starting-to-work.md
│   │           ├── intermediate/ ......... 🌿 Intermediate feature docs
│   │           │   ├── automating-your-workflows.md
│   │           │   ├── best-practices.md
│   │           │   ├── configuring-your-claude.md
│   │           │   ├── github-actions.md
│   │           │   ├── hooks.md
│   │           │   ├── loop.md
│   │           │   ├── marketplace.md
│   │           │   ├── mcp.md
│   │           │   ├── plugin-examples.md
│   │           │   ├── plugins.md
│   │           │   └── skills.md
│   │           ├── expert/ ............... 🌳 Expert feature docs
│   │           │   ├── agent-sdk.md
│   │           │   ├── hooks-http.md
│   │           │   ├── ongoing-work.md
│   │           │   ├── introspective-development.md
│   │           │   ├── sub-agents.md
│   │           │   └── team-mode.md
│   │           ├── daily-workflow.md ...... Story walkthrough
│   │           ├── starting-new-repo.md
│   │           ├── new-project-existing-repo.md
│   │           ├── auto-maintain-claude-md.md
│   │           ├── context-management-and-clear.md
│   │           ├── discovering-plugins.md
│   │           ├── memory-in-practice.md
│   │           ├── sub-agents-in-monolith.md
│   │           ├── automated-briefings.md
│   │           └── migrating-from-other-tools.md
│   ├── introspect/
│   │   └── SKILL.md ...................... Introspective Development — audit and improve your project
│   ├── game-mode/
│   │   └── SKILL.md ...................... Gamified usage tracker with levels
│   ├── level-up/
│   │   └── SKILL.md ...................... Feature roadmap and coaching hints
│   ├── migrate-to-claude/
│   │   └── SKILL.md ...................... AI tool config migration assistant
│   └── visualize-setup/
│       ├── SKILL.md ...................... Interactive HTML setup dashboard generator
│       ├── scripts/
│       │   ├── discover.sh ............... Discovers skills, MCP servers, game data → JSON
│       │   └── build-dashboard.sh ........ Runs discover, injects into template, opens browser
│       └── assets/
│           └── template.html ............. Complete HTML/CSS/JS with data placeholders
├── agents/
│   ├── doc-verifier.md .................... On-demand reference doc accuracy verifier (Sonnet agent)
│   ├── pr-review.md ....................... Waits for bot reviews, triages, fixes, replies, resolves (Sonnet agent)
│   ├── version-bump.md .................... Synced version bumper for plugin.json + marketplace.json (Haiku agent)
│   └── scripts/
│       ├── wait-for-reviews.sh ............ Polls for Qodo + Copilot reviews on a PR
│       ├── fetch-pr-comments.sh ........... Fetches all PR comments in structured format
│       └── reply-and-resolve.sh ........... Replies to a comment and resolves its thread
├── tests/
│   ├── helpers/
│   │   └── setup.sh ...................... Common test fixtures and mock data
│   ├── track-usage.bats .................. Tests for PostToolUse hook
│   ├── track-prompt.bats ................. Tests for UserPromptSubmit hook
│   ├── track-stop.bats ................... Tests for Stop hook (Fibonacci, levels, scoring)
│   └── migrate-data.bats ................. Tests for schema migration
├── _config.yml ............................ Jekyll configuration (just-the-docs theme; include: _worker.js/_redirects)
├── _worker.js ............................. Cloudflare Pages advanced-mode Worker (markdown content negotiation)
├── _redirects ............................. Cloudflare Pages rules (catch-all real 404)
├── 404.md ................................. Custom 404 page (served by _redirects)
├── llms.txt ............................... Agent-facing documentation index
├── Gemfile ................................ Ruby dependencies
├── docs/
│   ├── getting-started.md ................. Nav parent: Getting Started
│   ├── automation.md ...................... Nav parent: Automation
│   ├── configuration.md ................... Nav parent: Configuration & Extensions
│   ├── integrations.md .................... Nav parent: Integrations
│   ├── user-stories.md .................... Nav parent: User Stories
│   └── windows-support.md ................ Windows setup and adjustments
├── index.md ............................... Website landing page
├── .local/ ................................ Runtime data (gitignored)
│   └── game-data.json .................... Usage data (created at runtime)
├── CLAUDE.md .............................. This file — agent instructions
├── PRIVACY.md ............................. Privacy policy
├── LICENSE ................................ CC BY 4.0
└── README.md .............................. Human-facing entry point (GitHub only)
```

---

## Critical Rules for Content

These rules MUST be followed when editing or creating skills:

1. **Slash commands are a subset of Skills** — never list them as a separate category. They are the same mechanism.

2. **Three automation mechanisms only**: Hooks, Skills, Sub Agents. Agent Teams are NOT a fourth mechanism — they are architecturally distinct (separate full Claude instances) and always flagged as experimental.

3. **Worktrees are an isolation layer**, not a coordination mechanism. They provide git-level isolation for parallel work.

4. **Agent Teams are experimental** — always flag them with ⚠️ and note they may change.

5. **The onboarding skill is interactive**, not a reference dump. It walks users through setup step by step. The ask skill answers questions by reading reference docs.

6. **IKEA analogy**: Hooks = assembly events (they fire during the process), Skills = packages with instruction sheets (reusable, pre-written), Sub Agents = packages + a handyperson (delegate and they deliver).

7. **Difficulty tiers** — Every reference doc has a `> **Level: 🌱/🌿/🌳**` badge after the title. Sections that differ from the file's overall level get an emoji prefix on the `##` heading. Only tag sections that differ — don't repeat the file-level tag on every heading.

---

## Versioning

The authoritative plugin version lives in `.claude-plugin/plugin.json` (`"version": "X.Y.Z"`). The `marketplace.json` plugin entry also has a `version` field — **`plugin.json` takes priority**, but keep both in sync to avoid confusion.

### Why bumping matters

Installed plugins are cached at `~/.claude/plugins/cache`. **Version is the cache key** — if you change code but don't bump the version, users won't see the update. Always bump the version when shipping changes.

### Semantic versioning

| Change type | Bump | Examples |
|---|---|---|
| **Major** (X) | Breaking changes, structural redesigns | Removing a skill, renaming hook events, changing game-data schema incompatibly |
| **Minor** (Y) | New features, new reference docs, new hook behaviors | Adding a skill, adding a tracking category, new reference doc |
| **Patch** (Z) | Bug fixes, wording tweaks, small improvements | Fixing a regex in a hook script, typo in a reference doc, adjusting a case branch |

### Rules

- Always bump the version in the same commit as the change itself — never leave a functional change without a version bump
- Bump both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
- Use the `version-bump` agent (`agents/version-bump.md`) to keep both files in sync automatically — it infers bump type from the git diff

---

## Deployment

The docs website is served by **Cloudflare Pages** (native Git integration) on
`claude-code-guide.org` — Cloudflare clones the repo, runs the Jekyll build, and
serves the result. **There is no deploy workflow in the repo**; the Pages project
and custom domain are provisioned out-of-band (via the `cultureflare` CLI / its
`cf-pages-project-create.sh` + `cf-pages-domain-add.sh`).

The build is **advanced-mode Pages**: a root `_worker.js` intercepts every
request to serve agent-readable markdown. The moving parts must stay in lockstep:

- `_plugins/llm_markdown.rb` — at build time, writes a `.md` twin of every
  content page (and a concatenated `llms-full.txt`). Its `twin_relpath` path
  scheme is the source of truth.
- `_worker.js` — serves a page's `.md` twin on `Accept: text/markdown` or an
  explicit `.md` URL, and maps `/` → `/llms.txt`. Its `markdownTwin()` **must
  match** the plugin's `twin_relpath`.
- `_includes/head_custom.html` — emits `<link rel="alternate" type="text/markdown">`
  pointing at the same twin URL.
- `_redirects` + `404.md` — catch-all that returns a real 404.
- `_config.yml` `include:` — force-copies the underscore-prefixed `_worker.js`
  and `_redirects` into the build root (Jekyll skips `_`-files otherwise).

If you change the twin path scheme, change it in all three of `llm_markdown.rb`,
`_worker.js`, and `head_custom.html`.

These files are the **website**, not plugin content — changing them needs **no
version bump** (see [Plugin vs. Project Tooling](#plugin-vs-project-tooling)).

---

## Git Workflow

Before staging or committing changes, check the current branch. If you are on `main`, create a new descriptive branch first — never commit directly to `main`.

### After implementing a plan

When a plan's implementation is complete, run the PR review cycle:

1. **Branch** — if on `main`, create a descriptive branch (`feature/short-name`)
2. **Commit & push** — stage only files changed by the task (never `git add -A`), commit, push with `-u`
3. **Create PR** — `gh pr create` with a summary of the changes
4. **Wait for reviewers** — wait ~5 minutes, then check for automated review comments and CI status
5. **Triage in plan mode** — enter plan mode and categorize each comment: fix, fix + pushback, pushback, or acknowledge
6. **Fix & push** — apply approved fixes, commit, push
7. **Follow-up issues** — open GitHub issues for items outside the PR's scope
8. **Reply & resolve** — reply to every comment thread and resolve it

Use the `pr-review` agent (`agents/pr-review.md`) and its helper scripts to automate steps 4-8.

### After completing work

When a task is done and merged, clean up:

- Compact or clear conversation history if context is getting long
- Delete merged feature branches locally: `git branch -d feature/branch-name`
- Close related GitHub issues (use `closes #N` in commit messages for auto-close)
- Run `/guide:introspect` to review what could be improved for next time

---

## How to Edit

- The onboarding skill lives at `skills/onboard/SKILL.md`
- The ask/Q&A skill lives at `skills/ask/SKILL.md`
- Reference docs live at `skills/ask/references/beginner/`, `intermediate/`, and `expert/` — organized by difficulty tier
- User stories live at `skills/ask/references/` (root level) — narrative scenario walkthroughs
- The visualize-setup skill lives at `skills/visualize-setup/SKILL.md`
- The plugin manifest is at `.claude-plugin/plugin.json` (plugin name: `guide`)
- README.md is the human-facing entry point
- This file (CLAUDE.md) provides agent context — update the structure tree when adding/removing references
