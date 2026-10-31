---
name: feature-engineering
description: >-
  Drive a non-trivial feature or change through a disciplined engineering loop —
  a use-case-first written plan, design, a critical review that VERIFIES claims
  against the actual code, test-first (TDD) implementation, code review, and a
  feedback/progress log. Use this whenever the work is more than a one-line fix:
  when the user says "plan this feature", "spec this out", "design and build X",
  "do this properly / production-ready", "use TDD", "write a plan first", or
  describes a multi-step change touching several files or systems. Prefer this
  over diving straight into edits for anything that warrants a plan, even if the
  user doesn't say the word "plan".
metadata:
  author: rajesh
  version: "1.0"
---

# Feature Engineering

A repeatable loop for taking a feature or substantial change from idea to shipped,
without the two failure modes that dominate LLM-assisted engineering: **building on
an unverified assumption**, and **claiming done without proof**.

The loop is a living **plan document** plus four disciplines applied around it. The
plan is the source of truth and the progress tracker; the disciplines keep it honest.

```
   ┌─────────────────────────────────────────────────────────┐
   │  PLAN.md  (use cases → design → phases → tests → log)    │
   └─────────────────────────────────────────────────────────┘
        │            ▲              │            ▲
     (1) plan   (2) verify-     (3) TDD     (4) review +
                 before-trust   implement    feedback loop
```

Use the loop at the **altitude the task deserves**. A focused two-file change needs a
short plan and a couple of tests — not a 200-line spec. A cross-system feature needs
the full treatment. Scale the ceremony to the risk; don't perform process.

---

## When to run which step

You will rarely do all of this in one turn. Figure out **where the user is** and jump in:

- No plan yet, fuzzy idea → start at **Step 1 (Plan)**.
- Plan exists, untested assumptions → **Step 2 (Verify)** before writing any code.
- Plan verified, ready to build → **Step 3 (TDD implement)**, phase by phase.
- Code written → **Step 4 (Review + feedback)**.

Always update the plan's **Progress Log** and checkboxes as you go — the plan is how
the next session (or the next engineer) knows what happened and why.

---

## Step 1 — Plan (use-case-first)

Write a plan document before non-trivial code. Scaffold it with the bundled script,
then fill it in:

```bash
bash <skill-dir>/scripts/new-plan.sh "<feature name>" [target-dir]
```

The structure lives in **`references/plan-template.md`** — read it and follow its
section order. The non-negotiable sections, and why each earns its place:

- **Use cases (personas + the headline acceptance scenario).** Start here, not with
  architecture. If you can't name who needs this and the one scenario that proves it
  works, the design has nothing to satisfy. Surfacing use cases first is what stops
  you from building the wrong thing elegantly.
- **Design / architecture** — the key decision(s) and the alternatives rejected.
  State load-bearing assumptions explicitly; they become Step 2's verification targets.
- **Phased implementation plan with checkboxes** — each phase independently shippable,
  ordered so the riskiest unknown is de-risked first (a Phase 0 spike when the core
  approach is unproven). Mark progress in place; never delete a task (`- [~]` + reason
  if dropped).
- **Test plan** — the cases that will prove each phase, split into TDD-drivable unit
  tests vs. verification-after integration/manual checks (see Step 3).
- **Risks, Open Questions, Progress Log** — risks with mitigations; open questions that
  later phases depend on (filled as spikes resolve); a dated log entry every session.

For the planning itself you may delegate to the **Plan** agent or use plan mode; the
output still lands in this document in this structure.

**Before finalizing a plan, surface load-bearing assumptions.** If one is genuinely
ambiguous (you don't know which way the user wants it, and it changes the design), ask
*one* focused question. Don't ask to feel safe; ask when the answer changes what you build.

## Step 2 — Verify before trust (the highest-value step)

A plan is a set of claims. Before building on them, **check the load-bearing ones against
the actual code** — the central command exists and has the spelling you assumed, the
helper you'll reuse really returns what you think, the timeout/permission/path is what the
doc says. This single step catches the assumption errors that are cheap now and expensive
after the diff is large.

- For each load-bearing claim, find the file:line that confirms or refutes it. Spawn
  **`Explore`** agents to sweep in parallel when verification spans many files — you keep
  the conclusion, not the file dumps.
- When a claim is wrong, **correct the plan first**, then re-plan the affected phase. A
  corrected plan is the deliverable of this step, not a green light to start coding.
- Record what you verified (and what turned out false) in the plan's Progress Log, so
  nobody re-litigates it.

Treat "the spike/the doc says X" as a hypothesis until you've seen X in the code. The
full worked example in `references/plan-template.md`'s notes shows how a single
verification pass turned a "reuse existing plumbing, no new path" plan into "that path
has a 60s timeout and the command doesn't exist" — before a line was written.

## Step 3 — TDD implement (red → green → refactor)

Implement phase by phase, **test-first**:

1. **Find the real test harness first.** Locate the existing suite, its runner config,
   fixtures, and mocking conventions (e.g. is the DB mocked? is there an auth fixture?).
   Extend it — don't invent a parallel one. Note whether the runner stops on first failure.
2. **Write the failing test (red).** For each backend behaviour, write its unit test
   before the implementation and run it to confirm it fails *for the right reason*. To
   keep unit tests off the live world, factor external dispatch (network, exec, LLM call)
   behind a seam the test can patch.
3. **Minimum code to green.** Write only enough to pass. Resist speculative features,
   config knobs, and abstractions introduced before the second use case exists.
4. **Refactor under green.** Clean up with the tests as a safety net.
5. **Keep changes surgical.** Touch only what the task needs; match surrounding style; no
   drive-by refactors folded into a feature change. One concern per commit.

Mark each phase's tests as **TDD-drivable** (mocked, no cluster/service — these drive the
red→green loop and run in the pre-merge gate) vs. **verification-after** (integration /
manual / live — they confirm, they can't drive). A phase is done only when its tests pass
and are checked off in the plan.

You may delegate the actual run/verify to the project's **`verify`** or **`run`** skills.

## Step 4 — Review and feedback loop

- Run a code review on the diff — prefer the project's **`code-review`** skill over an
  ad-hoc read; it knows the project's checklists. Feed real findings back into the code.
- **Verify the success criterion you stated** — actually run the tests/build/endpoint,
  don't assert "should work". If you couldn't run it, say so plainly.
- Close the loop in the plan: tick checkboxes, resolve Open Questions with the spike
  answer, append a dated **Progress Log** entry (what landed, decisions, commit SHAs,
  blockers). Update **Status** (`NOT STARTED → PHASE N → SHIPPED <date>`).
- Commit per logical theme (one concern per commit), and only when the user asks.

---

## What this skill deliberately reuses (don't reimplement)

This is an *orchestration* skill. Lean on what already exists:

- **`Plan` agent / plan mode** — for the planning step's heavy thinking.
- **`Explore` agent** — for Step 2's parallel verification sweeps.
- **`code-review` skill** — for Step 4's review.
- **`verify` / `run` skills** — for goal-driven "does it actually work" checks.

The skill's own contribution is the **plan document structure**, the **verify-before-trust
gate**, and the **phase/progress-log discipline** that ties them into one loop.

## Bundled resources

- `references/plan-template.md` — the full plan-document structure to copy, with each
  section's purpose and a short worked note. Read this when starting Step 1.
- `references/review-gate.md` — the verify-before-trust checklist for Step 2.
- `scripts/new-plan.sh` — scaffolds a `PLAN.md` / `todo/<feature>.md` from the template.

## Anti-patterns (why plans rot)

- **Architecture-first, use-cases-never** → an elegant solution to the wrong problem.
- **Trusting the plan's own claims** → building three phases on a command that doesn't
  exist. Verify load-bearing claims (Step 2) before they become load-bearing code.
- **Test-after-as-gate masquerading as TDD** → tests written to confirm what you already
  built drift toward what the code does, not what it should do. Red first.
- **Done-by-assertion** → "this should work" with nothing run. State the criterion, meet it.
- **Process for its own sake** → a 200-line plan for a 20-line change. Match altitude to risk.
