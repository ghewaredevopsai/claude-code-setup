---
name: submit
description: Submit the committed agent/ to the Kaggle gemma-4-developer-agent competition and record the leaderboard score. Use when /experiment promotes a new confirmed best, or when the user says "submit".
argument-hint: "[message]"
---

Kaggle allows **1 submission per day**. Every submission needs the user's explicit yes: if you
are running inside a /loop, send a PushNotification asking for it and carry on with other work.

1. **Gate.** Only ask for a submission if all of these hold:
   - `agent/` is committed and is the current "best full" in CLAUDE.md, or the user asked for this submission.
   - `agent/eval_config.yaml` has `max_time_minutes` ≤ 5. At about 120 serial tasks, anything
     higher can exceed Kaggle's 12 h limit, and then the **whole submission errors**.
   - No submission has been made today: check `research/SUBMISSIONS.md` and
     `kaggle competitions submissions gemma-4-developer-agent`.
2. **Build and push.** Run `uv run python scripts/build_submit_notebook.py && kaggle kernels push -p notebooks/submit`.
   Poll `kaggle kernels status rajeshgheware/gemma4-agent-submit` until it is complete (about 1 min).
   Note the version number that `push` prints.
3. **Submit** (after the yes): run `kaggle competitions submit gemma-4-developer-agent -k rajeshgheware/gemma4-agent-submit -v <version> -f submission.zip -m "<commit> <run> $ARGUMENTS"`.
4. **Record** a row in `research/SUBMISSIONS.md`: date, commit, run, message, status pending, and commit + push.
   Scoring takes about 18 h (the daily quota resets 00:00 UTC = 05:30 IST). Watch with a background loop on
   `kaggle competitions submissions gemma-4-developer-agent` (every 15 min), and when the score arrives, fill in the row
   and add a row to CLAUDE.md "Calibration": the full-run resolved/84, its harness (L4 or Spark), and the LB score (1 task = 0.017).
   First-time API submits returned 403 until the account passed Kaggle's Persona ID check (done 2026-09-28).
