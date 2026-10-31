# ThaliScan — how work flows (excerpt from AGENTS.md)

ThaliScan (https://thaliscan.glucoray.com) is built by Claude Code sessions. This is the section of its AGENTS.md that every session reads. The product repo is private; this excerpt is unedited.

## How work flows (spec issue → PR → review → merge)
Several agents and people work on this repo at once, so nobody edits `main` directly.
1. **Spec = GitHub issue** (form "Spec", title `NNN — short name`, next free number after `docs/specs/`): problem,
   testable acceptance criteria, out of scope, API/data/UI/invariant changes. It starts `spec:draft`. **A human sets
   `spec:approved`; no code before that.** After approval the body is frozen: changes go in a comment starting
   "Spec change:", the issue gets `spec:changed`, and work waits for a fresh `spec:approved`. One-line fixes skip
   the issue; small changes may skip the review agent.
2. **Claim it** (assign the issue to yourself, so two sessions never take the same one), then branch + worktree:
   `git worktree add .claude/worktrees/NNN-short-name -b feat/NNN-short-name` and work only there. Backend needs its
   own `uv sync` in the worktree; the Postgres container on :5434 is shared: run tests with
   `TEST_DB=thaliscan_test_NNN` so two worktrees don't wipe each other's test database.
3. **Build** against the ACs: tests first where practical, then the code; keep `docs/API.md`, `src/api.ts` and
   `src/mock.ts` in step. If the spec turns out wrong, stop and comment on the issue; don't build something else.
4. **PR** to `main` with the template: `Implements #<issue>` (never a closing keyword such as "Closes", in the PR
   or in commit messages: GitHub would close the issue on merge, before its production check), the approved AC list
   with evidence for each (test name, command output, screenshot), and `docs/specs/NNN-short-name.md` as the as-built
   record (`Status: built`, link to the issue). **`scripts/check.sh` must pass** (backend tests, exactly one Alembic head,
   migrations apply to an empty DB, frontend typecheck and build): paste its last lines, with the commit, into the PR.
   GitHub Actions is off for this repo (`ci.yml` is kept only as a record of the steps); Claude sessions are the CI.
   Issues are built by Claude sessions (cloud, or a local worktree), one session per issue.
5. **Review loop.** The `spec-reviewer` agent gets the PR number only (not the author's summary), re-runs the
   evidence and returns APPROVE or blocking findings; the author fixes and asks again. At most 3 rounds, then a human
   decides. Non-blocking notes become new issues, never extra rounds.
6. **Approve, merge, deploy.** The orchestrating agent approves once every AC is met and proved and the reviewer said
   APPROVE. A human merges and deploys from `main` (`deploy/deploy.sh <tag>`) for anything touching user data,
   billing or production. The issue closes only after its "production check" is done.

