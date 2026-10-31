---
name: experiment
description: Run one full iteration of the Kaggle agent-improvement loop on the Kaggle-faithful L4 box - pick one change, commit it, evaluate it on hard20, record it, then keep or revert it. Use for "run the next experiment", "/experiment", or on every /loop tick of the improvement loop.
argument-hint: "[optional: the change to test; otherwise pick one from the latest ANALYSIS.md]"
---

Follow CLAUDE.md "Experiment loop" and "Where evals run". Test exactly **one** change per run; otherwise the
ledger cannot say which change did what. Renting or resuming a GPU costs money: the user must have approved this
session's spend (see CLAUDE.md "Status").

## 0. Should the loop continue?
Read `EXPERIMENTS.md`, CLAUDE.md "Status" and "Stop criteria". If a stop condition is met: pause the L4 box
(`jl pause`), send a PushNotification with the result, and end the loop. If a run is already in flight
(`runs/<name>.pid` alive on Spark and no `DONE`), skip to step 4.

## 1. Pick the change
Use `$ARGUMENTS` if given. Otherwise take the chosen lever from the newest `runs/*/ANALYSIS.md`,
or the next untried item in CLAUDE.md "Idea backlog". Name the run `eNNN-<slug>`, with NNN = the
ledger row count + 1, zero-padded.

## 2. Edit and commit
Edit `agent/` only. The PostToolUse hook validates it; fix anything it rejects. Then run
`git add -A agent && git commit -m "eNNN: <change>"` and note the hash (you'll revert by hash).

## 3. Launch on the L4 box
- `export JL_API_KEY=$(sed -n 's/^JARVIS_API_KEY=//p' .env)`; `jl list`. If the box is paused, `jl resume <id> --yes --json`
  (the id and IP change). If L4 capacity is gone, retry every 2–5 min in a background loop.
- `scripts/l4box.sh serve <IP>` → `scripts/l4box.sh tunnel <IP> 8201`.
- Screen: `scripts/l4box.sh launch eNNN-<slug> 8201 eval/hard20.txt` (conc 1, 5-min cap, about 1.3 h).
- Confirm (only when step 6 promotes a screen): run `eval/shards/winnable-00/01/02.txt` as `eNNN-<slug>-full-s0/1/2`,
  one after another (or on a second box via `l4box.sh clone`), then merge the three `task_results.jsonl` into `runs/eNNN-<slug>-full/`.

## 4. Wait (do not poll with sleeps)
Run `scripts/exp.sh wait <run>` with Bash `run_in_background: true`. You are re-invoked when it
exits. If a /loop is active, schedule a 3600s fallback wakeup. If the wait reports DIED, read the log,
fix the cause, and relaunch under a new name.

## 5. Record
Run `scripts/exp.sh fetch <run>`, then `uv run python scripts/ledger.py <run> "<change>"`, then
`/analyze-run <run> <parent-run>`. Remember that ADK traces hide Gemma's thinking tokens (CLAUDE.md "Gotchas").

## 6. Decide
- **Keep** the change if hard20 resolved is at least the best hard20 so far. A gain of 1–2 tasks is noise:
  promote it to a confirm run before calling it a win.
- **Revert** otherwise, with `git revert --no-edit <eNNN commit hash>` (not HEAD). The ledger row stays.
- A **confirm** that beats "Current best" replaces it and becomes the next Kaggle submission candidate: `/submit` (1 per day, needs the user's yes).
- Commit and push: `git add EXPERIMENTS.md runs && git commit -m "eNNN results" && git push`.

## 7. Hand-off
If another experiment follows right away, keep the box running. Otherwise `l4box.sh untunnel 8201` and
**`jl pause <id> --yes`** immediately. Report in 3 lines: the change, the score against the best so far, and the next lever.
