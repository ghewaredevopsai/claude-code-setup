# Plan document template

Copy this structure into `todo/<feature>.md` (or `PLAN.md`). Keep section order — it
encodes the workflow: problem → who needs it → how → in what order → how you'll prove it
→ what could go wrong → what's still unknown → what actually happened.

Delete sections that genuinely don't apply to a small change; keep the spine (use cases,
phased plan, test plan, progress log) for anything non-trivial.

---

```markdown
# <Feature> — <one-line what-and-where>

**Status:** NOT STARTED  <!-- → PHASE 0 IN PROGRESS → … → SHIPPED <date> -->
**Priority:** P? — <the real reason, not a passing incident that will be stale by ship>
**Owner repos/paths:** <where the code lives>
**Related:** <links to memories, gotchas, prior art>

---

## How to update progress (READ FIRST)
1. Flip checkboxes (`- [ ]` → `- [x]`) as tasks land. Never delete a task; drop = `- [~]` + reason.
2. Update **Status:** each working session.
3. Append a dated **Progress Log** entry every session (what landed, blockers, decisions, commit SHAs).
4. Record spike answers in **Open Questions** as resolved — later phases depend on them.
5. A phase is "done" only when its **test cases** pass and are checked off.
6. **Work test-first (TDD):** write the failing test before the code; red → green → refactor.

## Why this exists (problem)
<The problem in plain terms. What's broken or missing, and the cost of leaving it.>
### Non-goals
<What this explicitly does NOT do — bounds scope, prevents gold-plating.>

## Use cases
**Personas:** <who actually uses this>
1. **<name> (read/write).** <scenario, frequency, latency expectation>
2. …
N. **<Headline acceptance scenario>.** <the one round-trip that proves the whole feature.>

## Architecture & Design
### Topology / current state (confirmed)
<What exists today, verified — not assumed.>
### The key decision(s)
<Chosen approach + the alternatives rejected and why. State load-bearing ASSUMPTIONS
explicitly here — they are Step 2's verification targets.>
### Components / surface
<APIs, modules, tables, files this touches.>

## Security considerations
<Auth, blast radius, injection surface, tenant isolation, secrets handling.>

## Implementation Plan (progress markers)
### Phase 0 — Spike & de-risk  <!-- only if the core approach is unproven -->
- [ ] <verify the riskiest unknown BEFORE committing to it; record finding in Open Questions>
### Phase 1 — <minimal working slice>
- [ ] **TESTS FIRST (red):** write failing unit tests for this phase before the code below.
- [ ] <implementation task>
- [ ] <deploy/verify task>
### Phase 2 — <robustness & UX>
- [ ] **TESTS FIRST (red):** …
- [ ] …
### Phase 3 — <templatize / scale / docs>
- [ ] …

## Test Plan
**Harness:** <the existing suite, runner config, fixtures, mocking conventions — extend it.>
### Unit (TDD-drivable — write FIRST, red before green)
- [ ] <auth required>
- [ ] <injection/abuse inert>
- [ ] <core happy path with external dispatch mocked>
- [ ] <tenant isolation / error path>
### Integration (verification-after — live)
- [ ] <end-to-end against the real service>
### Manual / acceptance
- [ ] **Headline scenario** from Use Cases, exercised for real.

## Deploy & verify
<Exact build/deploy steps; pre-deploy gate (tests + build green); post-deploy smoke check.>

## Risks & mitigations
- **<top risk>.** → <mitigation>
- …

## Open Questions / Spike Findings (fill during Phase 0)
- <question>: _TBD_

## Progress Log
- **<date>** — <what happened, decisions, commit SHAs, blockers>
```

---

## Worked note — why "verify before trust" earns its own step

A real example of the loop catching itself: a plan proposed reusing an existing control
path, described as "in-process, no new network path," driving a turn via a CLI command
`tool --message --expect-final`. A Step-2 verification pass against the code found three
things the plan asserted but the code contradicted:

1. The "in-process" path was actually an **HTTP call to a separate service with a
   hardcoded 60s timeout** — fatal for a multi-minute operation.
2. The CLI command `--expect-final` **appeared nowhere in the codebase**; the proven
   primitives did something different.
3. The capture helper returned **merged stdout+stderr**, so "capture the reply" wasn't clean.

None of this was visible from the plan alone. Catching it cost one verification pass and a
plan edit. Catching it after three phases of code would have cost a rewrite. That asymmetry
is why Step 2 is a gate, not a nicety: **a claim in a plan is a hypothesis until you've seen
it in the code.**
