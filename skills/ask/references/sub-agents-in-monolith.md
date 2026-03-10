---
title: "Sub Agents in a Monolith"
parent: "User Stories"
nav_order: 7
permalink: /stories/sub-agents-in-monolith/
---

# Navigating a Monolith with Sub Agents

> **Level: 🌳 Expert** | **Related:** [Sub Agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)

[← Back to References](expert/sub-agents.md)

## The Scenario

You're working on a large monolithic application — 500K+ lines of code across 40 modules. The codebase has a shared database, intertwined services, and layers of legacy code alongside newer patterns. You need to add a cross-cutting feature: audit logging for all payment-related operations. This touches multiple modules and requires understanding code you've never read. Sub agents turn this from an overwhelming task into a manageable one.

---

## The Walkthrough

### The Problem with a Single Context

If you tried this in a single Claude session, here's what would happen:

1. You'd ask Claude to read the payment module — that's 50+ files
2. Then the order module, which calls payment code — another 40 files
3. Then the user module, for authentication context — more files
4. By the time Claude understands the landscape, the context window is 80% full
5. There's barely room left to plan and implement the actual feature

This is the exact scenario [sub agents](expert/sub-agents.md) are designed for: **research-heavy tasks where understanding the codebase consumes more context than implementing the change**.

### Step 1: Research with Parallel Sub Agents

Instead of reading everything in your main session, you delegate research to specialized sub agents:

```
> I need to add audit logging to all payment-related operations. Before we implement anything, I want to understand the landscape. Use sub agents to research these areas in parallel:
>
> 1. The payment module — find all public methods that modify payment state (create, refund, capture, void)
> 2. The order module — find all places that call payment methods
> 3. The existing logging system — how does the app currently log things? Is there an audit log table or service already?
```

Claude spawns three sub agents, each with their own context window. They work in parallel:

- **Agent 1** reads through `src/payments/` and maps every state-changing method
- **Agent 2** greps for payment service calls across the order module and traces the call paths
- **Agent 3** explores the logging infrastructure — finds a `LogService`, an `audit_logs` table, and existing audit patterns in the compliance module

Each agent returns a focused summary. Your main context receives three concise reports, not hundreds of file contents.

> **What's Happening:** [Sub agents](expert/sub-agents.md) each get their own context window. They can read as many files as needed without consuming your main session's context. The key insight: raw file contents stay in the sub agent's context, and only the distilled findings come back to you.

### Step 2: Synthesize and Plan

With the three research reports in your main context, you have a clear picture:

- 12 payment methods need audit logging
- They're called from 8 places in the order module and 3 places in the subscription module
- There's an existing `AuditLogger` service that writes to the `audit_logs` table — the compliance module already uses it

Now you plan:

```
> /plan Based on the research: add audit logging to all 12 payment state-changing methods using the existing AuditLogger service. The pattern should match how the compliance module does it. Plan the implementation.
```

Claude produces a plan that leverages the existing infrastructure. No need to build a new logging system — just extend the pattern that already exists.

> **What's Happening:** [Plan Mode](beginner/starting-to-work.md) works best with good context. The sub agent research gave you exactly the context you need for planning — the right methods, the existing patterns, the infrastructure — without the noise of full file contents.

### Step 3: Implement with Focused Sub Agents

The implementation is also modular. You use sub agents again, but this time for writing code:

```
> Implement the audit logging in two phases using sub agents:
>
> Phase 1: Add AuditLogger calls to all 12 payment methods in src/payments/
> Phase 2: Add integration tests that verify audit logs are created for each payment operation
>
> Each sub agent should follow the pattern from the compliance module: log the operation type, the user ID, the affected entity, and a before/after snapshot.
```

Claude spawns two sub agents:

- **Agent 1** reads the compliance module's audit pattern, then adds `AuditLogger` calls to each payment method. It runs the linter after each file to catch issues immediately.
- **Agent 2** (after Agent 1 completes) writes integration tests that create payments, trigger operations, and verify the audit log entries.

> **What's Happening:** Sub agents can modify code, not just read it. By giving each agent a scoped task ("add logging to payments" and "write tests"), they work efficiently within their context window. The instructions reference the compliance module as a concrete pattern to follow — this is more reliable than abstract instructions.

### Step 4: Cross-Module Verification

The payment methods are now logging, but you need to verify that the audit trail captures the full picture when an operation spans modules (e.g., an order refund that triggers a payment refund):

```
> Use a sub agent to trace the full refund flow from order initiation to payment execution. Verify that audit logs capture both the order-level action and the payment-level action. If there's a gap, fix it.
```

The sub agent traces the flow: `OrderService.refund()` calls `PaymentService.refund()`. The payment-level audit log exists (you just added it), but there's no order-level audit entry. The agent adds one in `OrderService.refund()` following the same pattern.

> **What's Happening:** This is the "specialist investigator" pattern for sub agents. You're delegating a specific verification task — tracing a cross-module flow and checking for gaps. The sub agent can read all the files in the flow without impacting your main context.

### Step 5: Review in Your Main Session

Back in your main session, you have a clean context with just the high-level plan and the sub agents' completion reports. You do a final review:

```
> Show me a summary of all files changed and the audit logging pattern we used. Then run the full test suite for the payment and order modules.
```

Claude lists the changes (15 files modified, 2 new test files), shows the pattern, and runs the tests. Everything passes.

```
> Commit these changes with the message "feat: add audit logging to all payment operations"
```

---

## Key Takeaways

- **Use sub agents for research in large codebases.** When understanding the code requires reading more files than a single context can hold, delegate research to parallel sub agents.
- **Raw data stays in sub agents; distilled knowledge comes back.** The key benefit isn't parallelism — it's that file contents consume sub agent context instead of yours.
- **Match sub agent scope to task boundaries.** "Research the payment module" and "research the logging system" are good scopes. "Understand the entire codebase" is too broad.
- **Reference concrete patterns.** "Follow how the compliance module does audit logging" gives sub agents a specific template to work from, producing more consistent results.
- **Verify cross-module interactions.** Sub agents are excellent at tracing flows across module boundaries — exactly the kind of investigation that would consume your entire context in a single session.
