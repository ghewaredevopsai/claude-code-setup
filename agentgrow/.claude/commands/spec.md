---
description: Start or update a spec for a feature (docs/specs workflow)
argument-hint: <feature-slug> [one-line description]
---

Spec-first work on: $ARGUMENTS

Follow `docs/specs/README.md`. In short:

1. If `docs/specs/<slug>.md` exists, this is a change to a shipped feature: read it, edit the affected ACs, and change their tests in the same commit.
2. Otherwise copy `docs/specs/_TEMPLATE.md` to `todo/<slug>.md`. Write the use case, then numbered ACs (`- **ACn** — <observable behaviour>`), non-goals, contract (routes, request/response, status codes) and data (tables, columns, units). Name code by file and symbol, never by line number. Stop and show me the ACs before writing code.
3. For each AC, write a failing test that cites it as `docs/specs/<slug>.md#ACn` (cite the final path from the start). Prefer TestClient + the real-Postgres `pg_db` fixture; do not add tests that grep source text or match SQL strings.
4. Implement until `.venv/bin/python -m pytest tests/ -q` passes, including `tests/test_specs.py`.
5. On ship: `git mv todo/<slug>.md docs/specs/<slug>.md`, set `Status: shipped <date>`, and add the spec to the table in `docs/specs/README.md`.
