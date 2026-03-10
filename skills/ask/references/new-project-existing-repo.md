---
title: "New Project in Existing Repo"
parent: "User Stories"
nav_order: 3
permalink: /stories/new-project-existing-repo/
---

# Adding a New Module to an Existing Codebase

> **Level: 🌿 Intermediate** | **Related:** [Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)

[← Back to References](intermediate/best-practices.md)

## The Scenario

You're working on a mature e-commerce platform. The codebase has been around for three years — well-established patterns, a clear directory structure, existing conventions in `CLAUDE.md`. Your task: add a new "gift cards" module. This isn't a bug fix or a small feature — it's a new domain that needs to fit seamlessly into the existing architecture.

---

## The Walkthrough

### Step 1: Understand the Existing Patterns

Before writing a single line of gift card code, you need to know how the codebase expects new modules to look:

```
> I need to add a new "gift cards" module to this codebase. Before we start, study the existing modules — look at how "coupons" and "loyalty-points" are structured. What patterns do they follow for models, services, API routes, and tests?
```

Claude reads the `CLAUDE.md` (which documents the module structure), then examines the coupons and loyalty-points modules side by side. It reports back: each module has a `models/` folder, a `services/` folder with a main service class, `routes/` with versioned API endpoints, and `tests/` mirroring the source structure. Services always go through a repository layer — no direct ORM calls in route handlers.

> **What's Happening:** Claude reads your [CLAUDE.md](beginner/setting-your-environment.md) first, then validates those conventions against the actual code. This catches cases where documentation has drifted from reality — if the coupons module does something differently than CLAUDE.md says, you'll know.

### Step 2: Plan the Module Structure

Now you know the patterns. Time to plan:

```
> /plan Create a gift cards module following the same patterns as coupons and loyalty-points. Gift cards should support: creation with a balance, redemption (partial or full), balance checks, and expiration. Plan the full module structure — models, services, routes, and tests.
```

Claude produces a plan:
- `src/gift-cards/models/gift-card.ts` — GiftCard model with balance, expiration, status
- `src/gift-cards/repository/gift-card-repository.ts` — database access layer
- `src/gift-cards/services/gift-card-service.ts` — business logic (create, redeem, check balance)
- `src/gift-cards/routes/v1/gift-cards.ts` — REST endpoints
- `tests/gift-cards/` — mirroring each source file

You scan the plan. It matches the existing patterns. One adjustment:

```
> Add a gift-card-transaction model too — we need to track every redemption as a separate record, like how loyalty-points tracks point transactions.
```

Claude updates the plan. You approve it.

> **What's Happening:** [Plan Mode](beginner/starting-to-work.md) is essential for structural work. You're not just writing code — you're establishing the shape of a new module that will live in this codebase for years. Getting the structure right before implementation prevents costly restructuring later.

### Step 3: Implement Incrementally

You don't ask Claude to implement everything at once. That would consume too much context and make review harder. Instead, you go layer by layer:

```
> Implement the gift card models and repository layer first. Follow the patterns from the coupons module exactly.
```

Claude creates the model and repository files, matching the naming conventions, export patterns, and typing style of the existing modules. It runs the linter and type checker — no issues.

```
> /clear
```

Fresh context. Now the service layer:

```
> Implement the gift card service layer. The service should handle creation, redemption (partial and full), balance checks, and expiration. Follow the pattern from the coupons service.
```

Claude reads the plan it made earlier (it's in the codebase as a TODO or you re-state the key points), reads the models it just created, and implements the service.

> **What's Happening:** Clearing between layers is a [context management](intermediate/best-practices.md) technique. Each layer gets Claude's full attention and a fresh context window. The completed code from previous layers is on disk — Claude reads it as needed rather than relying on conversation history.

### Step 4: Wire It Up

After implementing each layer (with `/clear` between), you connect everything:

```
> Register the gift cards module in the main app router and add it to the module index. Follow how coupons is registered.
```

Claude finds the app initialization file, the router registry, and adds the gift cards module following the exact same pattern.

### Step 5: Test the Full Module

```
> Run the full test suite to make sure the gift cards module works and nothing else broke.
```

Claude runs the tests. Two gift card tests fail — an edge case in partial redemption where the balance goes below zero. Claude fixes the logic and re-runs. All green.

> **What's Happening:** The [self-testing loop](intermediate/best-practices.md) catches issues that code review alone might miss. Running the full suite also catches integration issues — maybe the gift card routes conflict with an existing route pattern.

### Step 6: Update Documentation

```
> Update CLAUDE.md to add the gift cards module to the module list. Also update any relevant reference in README.md.
```

The codebase's documentation stays current, and the next developer (human or AI) who opens this repo will know the gift cards module exists and follows the standard pattern.

---

## Key Takeaways

- **Study existing patterns before creating new ones.** Let Claude analyze similar modules first. Consistency is more important than cleverness.
- **Plan structural work explicitly.** Use Plan Mode for anything that creates new files or establishes new patterns. Review the structure before writing code.
- **Implement in small steps, expect corrections in bigger ones.** Small, focused changes — one layer, one file, one concern — land cleanly. The bigger the ask, the more likely you'll need to course-correct. That's normal, not a failure. Plan for review-and-adjust cycles on larger work.
- **Follow existing conventions exactly.** Tell Claude to match specific modules, not to invent new approaches. "Follow how coupons does it" is better than "use best practices."
- **Run the full test suite.** New modules can have unexpected interactions with existing code. Integration testing catches what unit tests miss.
