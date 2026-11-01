# Dark factory: four Claude Code seats, one human message

**2nd place, pocketful track, WeAreDevelopers × BAND "Dark Factory" hackathon (lablab.ai, October 2026). Prize: $1,000.**

The challenge: build a software factory in BAND Desktop, where a band of coding agents plans the work, implements it,
hands off evidence and checks its own results. Hand-written product code scored nothing. Our factory was four headless
Claude Code sessions in one BAND room. It built a wallet and payments service ("money must never be created,
destroyed or spent twice, under concurrent transfers, retries and rounding") through four stages, from one human
message.

| | |
|---|---|
| Human messages in the room | **1** (the dispatch) |
| Wall clock | 8 h 46 min, all four stages |
| Cost | **$74.88** list-price equivalent, measured per seat from the transcripts |
| Real defects caught before acceptance | 5 (3 by the modeler before review began, 2 by reviewer rejections) |
| Planted faults caught | **36 / 36** |
| Official harness, fresh clone, offline container | stages 1–4 each claim their own stage |

Full write-up, room export and code: **[ghewaredevopsai/pocketful-dark-factory-v2](https://github.com/ghewaredevopsai/pocketful-dark-factory-v2)**
([FACTORY.md](https://github.com/ghewaredevopsai/pocketful-dark-factory-v2/blob/main/FACTORY.md)) ·
[video](https://youtu.be/Uoi_bmq9ttM) · [LinkedIn write-up](https://www.linkedin.com/feed/update/urn:li:activity:7517120009123319808/)

## What is here

The four seat mandates, copied unedited from the submission repo. Each one is the `--instructions-file` of a Claude
Code seat.

| Seat | Model | Owns | Never does |
|---|---|---|---|
| [`coordinator`](mandates/coordinator.md) | Sonnet | plan, parallel dispatch, ledger audit, routing each finding to its owner, acceptance, opening the next stage | write code, tests or models |
| [`implementer`](mandates/implementer.md) | Opus | `LEDGER.md` (one line per requirement), product code, its own tests | accept its own work |
| [`modeler`](mandates/modeler.md) | Opus | an executable reference model of the spec and a seeded differential driver | read, import or run product code |
| [`reviewer`](mandates/reviewer.md) | Opus | fresh-checkout offline build, ledger audit, differential runs, fault injection, `GAPS.md`, the verdict | fix the code or the model |

## The patterns that won it

- **Generic mandates.** The rules disqualified any mandate that named a track detail, so the mandates describe roles,
  evidence and gates, never endpoints or fields. The same four files built the practice track first.
- **Two independent readings of the spec.** The modeler never sees product code. It writes a small, obviously correct
  model and fires seeded random operation sequences at both. Each divergence is either a product bug or a written
  ruling. The shipped checks covered 9–79% of each stage's graded suite; the second reading found what no check asked.
- **The reviewer must break things before it accepts.** It plants at least five plausible faults per stage in a
  scratch copy. A plant nobody catches is a finding against the checks.
- **No human in the loop after the dispatch.** The coordinator opens each next stage itself, and never asks the human
  anything. Every handoff is self-contained, because a seat sees only messages addressed to it.
- **Evidence over assertion.** Every count is quoted with the command that produced it, every time comes from
  `date -Is`, and every seat commits under its own Git identity.

## Seat setup

```sh
band agent create --session seat-<name> --name <name> \
  --transport claude-code-cli --runtime-auth subscription --runtime-model <model> \
  --claude-context-mode local_config --claude-strict-mcp-config \
  --cwd <absolute result repo> --instructions-file mandates/<name>.md
```

`--claude-strict-mcp-config` keeps each seat off the personal MCP servers on the host machine.
