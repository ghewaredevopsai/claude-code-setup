# Verify-before-trust checklist (Step 2)

A plan is a set of claims. This gate converts the load-bearing ones from "asserted" to
"seen in the code" before any code is built on them. Run it after the plan is drafted and
before Phase 1 implementation.

## What counts as "load-bearing"

A claim is load-bearing if the design *breaks* when it's false. Verify those; skip the rest.

- A specific **command / API / function exists** and has the signature/spelling assumed.
- A **helper you'll reuse** returns what you think (shape, clean vs. merged output, sync vs. async).
- A **timeout / limit / quota** is what the doc says (the difference between "works" and
  "times out at 60s").
- A **permission / auth / RBAC** boundary actually allows (or blocks) what the design needs.
- A **path / table / config key / port / Service name** is real and current.
- A stated **"X is already wired / already does Y"** is true now, not "was true once."
- An **external/runtime constraint** (rate limit, streaming off, single-runtime
  serialization) holds as assumed.

## How to verify

1. For each load-bearing claim, get a **file:line** (or a real probe result) that confirms
   or refutes it. "The memory/gotcha says so" is not verification — entries go stale.
2. When verification spans many files or naming conventions, spawn **`Explore` agents** in
   parallel and keep the conclusions, not the file dumps. Give each a tight, factual brief
   ("does function X exist, what does it return, is it called anywhere — file:line or 'not found'").
3. Reconcile contradictions. If two sources disagree, the running code wins.

## When a claim is false

- **Correct the plan first.** Edit the design/sequence/risks to match reality.
- **Re-plan the affected phase** — the fix may change the chosen approach (e.g. "exec path"
  → "the exec path has a fatal timeout, switch transports").
- **Record it in the Progress Log**: what you verified, what was false, what changed. This
  stops the same wrong assumption from reappearing next session.

## Output of this step

The deliverable is a **corrected, verified plan** — not a green light to code. The plan is
ready for Phase 1 only when every load-bearing claim is either confirmed against the code or
explicitly demoted to a Phase 0 spike task to resolve first.

## Smell tests that something needs verifying

- The plan reuses "existing plumbing" but nobody has pointed at the line that does it.
- A central command/flag is named but never grepped.
- A latency/timeout/cost number is asserted without a measurement or a config line.
- "Already authenticated / already polls / already has access" with no citation.
- The design's safety rests on a gate ("it's approval-gated") that's only proven for one
  path, not the path this feature opens.
