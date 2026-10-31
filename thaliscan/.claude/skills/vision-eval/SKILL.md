---
name: vision-eval
description: Measure ThaliScan's dish recognition and carb accuracy on the 36-photo eval set (Qwen3.6 vision via LiteLLM), compare with the baseline in docs/spike-results.md, and iterate. Use when changing the scan prompts, the shortlist/pick step, the model, or the food table — or when someone asks "is recognition better or worse?".
---

# Vision eval loop

Baseline (2026-10-16, hybrid pipeline): thali judged recall **70%**, judged precision **57%**, strict recall **33%**,
median carb error **28%** thali / **6%** single. Full table: `docs/spike-results.md`.

## Run
From the repo root (needs `.env` with `LITELLM_BASE_URL`, `LITELLM_API_KEY`, `LLM_MODEL`):
```bash
set -a; . ./.env; set +a
uv run python spike/eval.py free      # vision naming + fuzzy map  → spike/eval/results-free.jsonl
uv run python spike/judge.py free     # LLM judge: fair recall/precision, per-image misses
cd spike && uv run python remap.py    # hybrid pick-from-shortlist → strict recall + carb error
```
About 36 vision calls + 72 text calls; a few minutes. 429s are our own rate cap; the scripts back off.
Images come from `spike/data/commons/` (gitignored). If missing, rebuild from `spike/eval/photos.jsonl` URLs.

## Iterate
1. Change one thing (prompt wording, shortlist size, pick prompt, a food-table fix).
2. Re-run all three steps. Compare against the baseline above; read the per-image `missed=` / `extra=` lines from
   the judge to see *what* changed, not just the totals.
3. Keep the change only if judged recall or carb error improves without precision dropping more than ~3 points.
4. If the production pipeline (`backend/app/vision.py`) should follow, port the change there and update the baseline
   numbers in this file and in `docs/spike-results.md`.

Caveats: the labels were written by a Claude agent from the photos and captions and are not human-checked;
"carb error" is agreement with the labeller's portion guess, not weighed food. The judge is the same Qwen model.
