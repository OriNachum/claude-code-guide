---
description: "Generate an HTML dashboard visualizing all installed Claude Code skills and MCP servers. Scans global and project-level skills and MCPs, then opens an interactive filterable dashboard in the browser."
disable-model-invocation: true
allowed-tools: Read, Glob, Bash, Write
---

# Visualize Skills

Generate an interactive HTML dashboard of all installed
Claude Code skills and MCP servers, with scope/type filters.

## Procedure

### Step 1 — Discover and parse data sources

#### Step 1a — Global skills (existing)

Read every `~/.claude/skills/*/SKILL.md` file.
For each one, extract:

- **name**: from YAML frontmatter `name` field;
  fall back to the directory name
- **description**: from YAML frontmatter `description`
  field
- **license**: from YAML frontmatter `license` field
  (default `"—"`)
- **has_scripts**: whether a `scripts/` subdirectory
  exists under that skill
- **body**: the markdown content after the frontmatter
  (everything below the closing `---`)
- **scope**: `"global"`
- **type**: `"skill"`

#### Step 1b — Project-level skills (new)

Read every `<CWD>/.claude/skills/*/SKILL.md` file.
Same parsing as Step 1a but tag with:

- **scope**: `"project"`
- **type**: `"skill"`

Skip silently if `<CWD>/.claude/skills/` does not exist.

#### Step 1c — Global MCP servers (new)

Read `~/.claude/settings.json` and look for the
`mcpServers` key. For each entry extract:

- **name**: the object key
- **command**: the `command` value
- **args**: the `args` array (join with spaces for
  display)
- **env**: the `env` object keys only (never expose
  values)
- **scope**: `"global"`
- **type**: `"mcp"`

Skip silently if the `mcpServers` key is missing or
the file doesn't exist.

#### Step 1d — Project-level MCP servers (new)

Read `<CWD>/.mcp.json` and look for the `mcpServers`
key. Same extraction as Step 1c but tag with:

- **scope**: `"project"`
- **type**: `"mcp"`

Skip silently if the file doesn't exist or the key
is missing.

### Step 2 — Categorize skills

Use this exact mapping (applies to both global and
project skills):

| Category           | Color   | Skills                                |
| ------------------ | ------- | ------------------------------------- |
| Communication      | #10b981 | message-user, ask-slack, slack-bridge |
| DevOps & CI/CD     | #f97316 | automate, az-devops                   |
| Project Management | #3b82f6 | jira, confluence                      |
| Browser & Testing  | #a855f7 | playwright-mcp                        |
| Utilities          | #f59e0b | count-tokens, visualize-setup         |

Any skill not in the mapping goes into an **Other**
category with color `#6b7280`.

MCP servers are **not** categorized — they appear in
their own dedicated section.

### Step 3 — Generate HTML dashboard

Write a **single self-contained HTML file** to
`/tmp/claude-skills-dashboard.html`.

Embed the parsed data as two JavaScript arrays at the
top of a `<script>` block:

- `const skills = [...]` — each with: name,
  description, license, has_scripts, body, category,
  categoryColor, scope
- `const mcpServers = [...]` — each with: name,
  command, args, env, scope

The browser cannot read the filesystem, so all data
must be inlined.

#### Design spec

**Theme & layout:**

- Background: `#FFFAF5`
- Card background: `#FFFFFF`
- Card border: `1px solid #E5DDD4`
- Text: `#1A1A1A` (body), `#6B6560` (secondary)
- Header: large title with gradient text
  (`#D97706` to `#B45309`)
- Font: system-ui / -apple-system / sans-serif stack
- Max content width: `1200px`, centered

**Search bar:**

- Full-width input at the top, below the header
- Filters cards in real-time by name, description,
  or category
- Styled with warm input (`#FFF8F0` background),
  rounded corners, subtle border glow on focus

**Filter bar (between search bar and stats ribbon):**

- Two groups of pill toggle buttons in a horizontal
  row
- **Scope group:** `All` | `Global` | `Project` —
  radio behavior (one active at a time)
- **Type group:** `All` | `Skills` | `MCPs` —
  radio behavior (one active at a time)
- Active pill: `#D97706` background, white text
- Inactive pill: `#F5EDE4` background, `#6B6560` text
- Rounded corners, smooth transitions
- Filters combine with search bar as AND conditions

**Stats ribbon (6 stats):**

- A horizontal row of 6 stat boxes below the filter
  bar:
  1. Total Skills — count of visible skills
  2. Categories — count of distinct categories among
     visible skills
  3. With Scripts — count of visible skills where
     `has_scripts` is true
  4. Licensed — count of visible skills where license
     is not `"—"`
  5. **MCP Servers** — count of visible MCP servers
  6. **Project Items** — count of visible items with
     scope `"project"`
- Grid: `repeat(auto-fill, minmax(150px, 1fr))`
- Each stat box: subtle background (`#F5F0EB`), large
  number, small label below

**Category sections:**

- Each category gets a section with a colored
  left-border header bar
- Header shows category name + skill count badge
- Skills within the category are displayed as cards
  in a responsive grid
- Section is hidden when all cards within it are
  hidden by filters

**Skill cards:**

- Add `data-scope` and `data-type="skill"` attributes
  to each card element
- **Scope badge** in top-right corner:
  - Global: `#FFF7ED` bg, `#B45309` text
  - Project: `#F0FDF4` bg, `#15803D` text
- Card shows:
  - Skill name (bold, `#2D2B27`)
  - Description (first 120 chars visible;
    "Show more" toggle if longer)
  - Capability tags extracted from the body (look for
    keywords: `curl`, `bash`, `MCP`, `webhook`,
    `REST API`, `jq`, `GitHub`, `Slack`, `browser`,
    `Playwright`; show matching ones as pill badges)
  - Quick command block: `/skill-name` displayed in a
    monospace code block with a copy-to-clipboard
    button
  - Footer: license badge + "has scripts" badge
    (if applicable)
- Hover: card lifts with `translateY(-4px)` and
  subtle shadow increase
- Transition: `all 0.2s ease`

**MCP Server section (below all skill categories):**

- Header: "MCP Servers" with `#D97706` left-border
  bar + count badge
- Same responsive grid as skill categories
- Section hidden entirely when zero MCP servers are
  visible
- **MCP card** shows:
  - Server name (bold, `#2D2B27`)
  - Scope badge in top-right corner (same colors as
    skill scope badges)
  - Type badge: "MCP" pill (`#92400E` bg,
    `#FFFFFF` text)
  - Command block: `command args...` in monospace
    with a copy-to-clipboard button
  - Env var keys as pill badges (keys only, never
    values — for security)
- Add `data-scope` and `data-type="mcp"` attributes
  to each MCP card
- Same hover/animation effects as skill cards

**Animations:**

- Cards fade in with staggered delay on page load
  (CSS `@keyframes fadeInUp`)
- Each card's `animation-delay` = `index * 0.05s`

**Responsive:**

- Grid: `repeat(auto-fill, minmax(340px, 1fr))`
- Below 768px: single column, smaller padding
- Below 480px: further reduced font sizes

**No external dependencies** — all CSS and JS must be
inline in the HTML file.

#### JavaScript behavior

- `filterAll()` — combines search text + scope
  filter + type filter as AND conditions. Hides cards
  that don't match, hides category/MCP section headers
  when all their cards are hidden, and updates the
  stats ribbon
- Scope pill click: sets active scope, calls
  `filterAll()`
- Type pill click: sets active type, calls
  `filterAll()`
- Search input: calls `filterAll()` on each keystroke
- Copy button — writes text to clipboard, shows brief
  "Copied!" tooltip
- "Show more" / "Show less" — toggles full description
  visibility on skill cards
- Stats ribbon updates on every filter change (counts
  only visible items)

### Step 4 — Open in browser

```bash
open /tmp/claude-skills-dashboard.html
```

## Important notes

- Always re-scan skills and MCPs fresh each invocation
  (don't cache)
- Include `visualize-setup` itself in the dashboard
- The HTML must be fully self-contained with zero
  external requests
- Use semantic HTML (`<main>`, `<section>`,
  `<article>`, etc.)
- Skip missing files or keys silently — never error on
  absent project skills or MCP configs
