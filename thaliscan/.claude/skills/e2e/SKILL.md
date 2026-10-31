---
name: e2e
description: Run ThaliScan's user flows in a real headless browser against the real API — the scan flow (sign in → onboarding → scan a meal photo with the real vision model → confirm → save → Today) and the clinic flow (create clinic → invite → client consents → dietitian comments → client revokes) — and inspect the screenshots. Use after any change to the frontend, the scan pipeline, or the meal/auth API, before calling the work done.
---

# End-to-end check

1. **Backend up?** `curl -s localhost:8000/api/health`. If not:
   `docker compose up -d db`, then from `backend/` run the API in the background with its log captured:
   `uv run uvicorn app.main:app --port 8000 > <scratchpad>/api.log 2>&1`. It must run with `ENV=dev` (the default)
   so sign-in codes are logged. Restart it if you re-seeded foods (the index is built at startup).
2. **Frontend up?** From `frontend/`: `npx vite --port 5180 --strictPort` in the background (5173 may be taken).
3. **Photo:** any meal photo. Eval photos live in `spike/data/commons/` (fetch with `spike/commons_fetch.py` if
   missing); prefer a thali, e.g. `c020.jpg` or `c160.jpg`.
4. **Run** from `frontend/`:
   `API_LOG=<api.log> IMG=<photo> BASE=http://localhost:5180 OUT=<scratchpad>/e2e CHROME=/usr/bin/google-chrome-stable npm run e2e`
   (drop `CHROME` if Playwright's own Chromium is installed).
   Clinic flow (two browsers, dietitian in dark mode, no photo or model needed):
   `API_LOG=<api.log> BASE=http://localhost:5180 OUT=<scratchpad>/e2e-clinic CHROME=/usr/bin/google-chrome-stable npm run e2e:clinic`.
   Billing flow (upgrade → pay → Pro; clinic pays a month): `npm run e2e:billing`. Against the mock server
   (`VITE_MOCK=1 npx vite --port 5181`, `BASE=http://localhost:5181`) it completes the payment; against the real API
   it stops at Cashfree's page (sandbox keys in `.env`) or at "not switched on" (no keys).
   Run the API with `APP_URL=http://localhost:5180` so invite links point at the dev frontend.
5. **Look at every screenshot** in `OUT` (Read the PNGs). Check: numbers are plausible (a thali is roughly
   500–1,000 kcal and 60–150 g carbs; anything wildly off means a data or maths bug), nothing overflows at 390 px,
   the rating chip has text and not only colour.
6. Report pass/fail with the screenshots you looked at. On failure, `OUT/failure.png` shows where it stopped.

Notes: free accounts get 3 scans a day; the script signs up a fresh `e2e…@example.com` user each run. Model output
varies between runs, so judge recognition quality with `/vision-eval`, not with one e2e run.
