---
name: analyze-run
description: Diagnose a finished eval run in runs/<name> - failure categories, where the wall clock went, and the next prompt/config lever. Use after /experiment finishes or when asked why a run or task did badly.
argument-hint: <run-name> [parent-run]
---

1. Delegate the trace reading to the `trace-analyst` subagent with `$ARGUMENTS`. Do not read
   traces yourself: one run is more than 150k tokens.
2. Check its claims against `runs/<name>/task_results.jsonl` (resolved, duration, error) and
   the relevant ledger rows in `EXPERIMENTS.md`.
3. Write `runs/<name>/ANALYSIS.md`: the subagent's table, the top 3 levers, and one line naming
   the lever you pick next and why. Skip any lever that `EXPERIMENTS.md` already shows was
   tried and did not help.
