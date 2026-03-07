# Ongoing Work

[← Back to Automating Your Workflows](automating-your-workflows.md)

Some maintenance shouldn't wait for a human to remember it. This guide covers automated ongoing processes — things that run on a schedule or trigger without you, keeping your project healthy over time.

This is distinct from [Configuring Your Claude](configuring-your-claude.md), which covers the manual, iterative evolution of your setup. Here we focus on the automated processes that complement that manual work.

---

## When to Think About This

- **Docs are going stale** — reference material drifts from official sources over weeks and months
- **Configuration validity** — CLAUDE.md instructions, skill files, hook scripts, or agent configs may reference features that have changed
- **Scheduled quality maintenance** — periodic checks for code conventions, dependency health, or documentation completeness
- **Drift detection** — any content that should stay in sync with an external source (APIs, upstream docs, schema definitions)

---

## Key Patterns

### Scheduled Doc Freshness

The most concrete pattern: periodically compare your docs against authoritative sources and fix what's drifted.

This repo uses this pattern in `.github/workflows/docs-freshness.yml`. A cron-triggered GitHub Actions workflow:

1. Reads all reference docs
2. Fetches official Anthropic documentation
3. Compares for factual inaccuracies (not stylistic differences)
4. Opens a PR with targeted fixes if anything is outdated

The key design decisions:
- **Runs on a schedule** (weekday mornings), not on every commit — freshness is a slow drift, not a per-change concern
- **Uses Sonnet** for cost efficiency on a recurring task
- **Skips if a freshness PR is already open** — avoids piling up duplicate PRs
- **Scoped narrowly** — only fixes factual errors, doesn't restructure or restyle

See [GitHub Actions](github-actions.md) for the mechanics of setting up scheduled workflows.

### Periodic Configuration Review

As your Claude Code setup matures, the configuration itself can drift. Set up periodic checks for:

| What to check | What to look for |
|---|---|
| **CLAUDE.md** | References to files/paths that no longer exist, outdated model names, stale conventions |
| **Skills** | Skills whose descriptions no longer match what they do, skills referencing deprecated features |
| **Hooks** | Hook scripts that error silently, hooks referencing tools or events that have changed |
| **Sub Agents** | Agent configs with outdated model IDs, tool restrictions that are too broad or too narrow |
| **Plugins** | Pinned versions that are behind, plugins whose APIs have changed |

A simple approach: create a scheduled workflow that asks Claude to audit your `.claude/` directory and `CLAUDE.md` files, looking for inconsistencies or staleness.

### CI-Driven Validation

Some checks should run on every PR, not on a schedule:

- **Skill frontmatter validation** — verify that all `SKILL.md` files have valid YAML frontmatter with required fields
- **Hook script testing** — run hook scripts with sample inputs to verify they still work
- **Agent config validation** — check that agent YAML configs reference valid models and tools
- **Cross-reference integrity** — verify that links between docs, skills, and configs resolve correctly

These are fast, deterministic checks that fit naturally into a PR pipeline alongside tests and linting.

### Drift Detection

Generalize the doc freshness pattern to anything that should stay in sync with an external source:

- **API schema drift** — compare your API client code against the latest schema
- **Upstream dependency changes** — check if dependencies have released breaking changes
- **Configuration schema drift** — verify your config files match the expected schema for your tools
- **Documentation cross-references** — ensure all internal links between docs resolve

The recipe is always the same:
1. Define what "in sync" means (the authoritative source)
2. Schedule a periodic comparison
3. Auto-fix or open a PR when drift is detected
4. Scope changes narrowly to avoid noise

---

## Combining with Manual Configuration

[Configuring Your Claude](configuring-your-claude.md) describes how your setup evolves through a natural timeline — foundations in weeks 1-2, specialization in months 1-2, maturity at month 3+.

Automated ongoing work fits into the **maturity** phase. Once your skills, hooks, and agents have stabilized:

1. **Start with doc freshness** — it's the most universally useful pattern and the easiest to set up
2. **Add configuration audits** — once you have enough config files that manual review becomes tedious
3. **Add CI validation** — once your team is contributing skills and hooks, validate them automatically
4. **Add drift detection** — for any external dependencies your setup relies on

Don't automate maintenance for a setup that's still changing rapidly. Let it stabilize first.

---

## Next Steps

- See [GitHub Actions](github-actions.md) for setting up the scheduled workflows that power these patterns
- See [Configuring Your Claude](configuring-your-claude.md) for the manual configuration evolution these automated checks complement
- See [Hooks](hooks.md) for lifecycle automation that can trigger validation on specific events
