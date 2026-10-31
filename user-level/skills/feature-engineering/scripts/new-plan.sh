#!/usr/bin/env bash
# Scaffold a feature-engineering plan document from the template.
# Usage: new-plan.sh "<feature name>" [target-dir]
#   target-dir defaults to ./todo
set -euo pipefail

name="${1:-}"
if [[ -z "$name" ]]; then
  echo "usage: new-plan.sh \"<feature name>\" [target-dir]" >&2
  exit 2
fi
target_dir="${2:-todo}"

# kebab-case the slug from the feature name
slug="$(printf '%s' "$name" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
[[ -n "$slug" ]] || { echo "could not derive a slug from: $name" >&2; exit 2; }

mkdir -p "$target_dir"
out="$target_dir/$slug.md"
if [[ -e "$out" ]]; then
  echo "refusing to overwrite existing $out" >&2
  exit 1
fi

# Resolve the template shipped alongside this script.
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template="$here/../references/plan-template.md"

today="$(date +%F)"

if [[ -f "$template" ]]; then
  # Extract the fenced ```markdown block from the template (the copy-paste skeleton).
  body="$(awk '/^```markdown$/{f=1;next} /^```$/{if(f)exit} f' "$template")"
else
  body=""
fi

if [[ -z "$body" ]]; then
  # Minimal fallback skeleton if the template is unavailable.
  body=$'# '"$name"$' — <one-line what-and-where>\n\n**Status:** NOT STARTED\n**Priority:** P? — <why>\n\n## Use cases\n## Architecture & Design\n## Implementation Plan (progress markers)\n## Test Plan\n## Risks & mitigations\n## Open Questions / Spike Findings\n## Progress Log'
fi

# Fill the title line and seed an initial progress-log entry.
printf '%s\n' "$body" \
  | sed -E "1s/^# .*/# ${name//\//\\/} — <one-line what-and-where>/" \
  | sed -E "s/^\*\*Status:\*\* NOT STARTED.*/\*\*Status:\*\* NOT STARTED/" \
  > "$out"

# Append a seed progress-log line if a Progress Log heading exists.
if grep -q '^## Progress Log' "$out"; then
  printf -- '- **%s** — Plan scaffolded (NOT STARTED). Next: fill use cases, then verify load-bearing claims before coding.\n' "$today" >> "$out"
fi

echo "created $out"
echo "next: fill the Use cases section first, then run the verify-before-trust gate (references/review-gate.md)."
