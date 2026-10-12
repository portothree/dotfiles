#!/usr/bin/env bash
# SessionStart hook: print a one-line hint when the default Basic Memory
# project looks fragmented. Silent when it's healthy or can't be found.
set -u

config="$HOME/.basic-memory/config.json"
command -v jq >/dev/null && [ -f "$config" ] || exit 0
root=$(jq -r '.projects[.default_project].path // empty' "$config")
[ -d "$root" ] || exit 0
cd "$root" || exit 0

notes() { find . -name '*.md' -not -path './personal/*' "$@"; }

transcripts=$(notes -print0 | xargs -0 grep -lE '^\[(USER|ASSISTANT)\]' 2>/dev/null | wc -l | tr -d ' ')
folders=$(find . -mindepth 1 -maxdepth 1 -type d -not -name '.*' | wc -l | tr -d ' ')
# Ticket IDs in note titles with 8 or more notes, with the folder holding most of them
clusters=$(notes | awk -F/ '{
    n = split($NF, words, /[^A-Z0-9-]+/)
    for (i = 1; i <= n; i++) if (words[i] ~ /^[A-Z][A-Z]+-[0-9]+$/) { c[words[i]]++; d[words[i] SUBSEP $(NF-1)]++; break }
  } END {
    for (t in c) if (c[t] >= 8) {
      best = ""; max = 0
      for (k in d) { split(k, p, SUBSEP); if (p[1] == t && d[k] > max) { max = d[k]; best = p[2] } }
      printf "%s%s (%d notes, mostly in %s)", sep, t, c[t], best; sep = ", "
    }
  }')

issues=()
[ "$transcripts" -ge 5 ] && issues+=("$transcripts transcript-style notes")
[ -n "$clusters" ] && issues+=("tickets split across many notes: $clusters")
[ "$folders" -ge 35 ] && issues+=("$folders top-level folders")
[ ${#issues[@]} -eq 0 ] && exit 0

summary=$(printf '%s; ' "${issues[@]}")
echo "Basic Memory health: ${summary%; }. Tell the user in one line and suggest running the memory-curate skill on those folders; don't run it unprompted."
