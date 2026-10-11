## Context Efficiency

### Subagent Discipline

**Context-aware delegation:**
 - Under ~50k context: prefer inline work for tasks under ~5 tool calls.
 - Over ~50k context: prefer subagents for self-contained tasks, even simple ones — the per-call token tax on large contexts adds up fast.

When using subagents, include output rules: "Final response under 2000 characters. List outcomes, not process."
Never call TaskOutput twice for the same subagent. If it times out, increase the timeout — don't re-read.

### File Reading
Read files with purpose. Before reading a file, know what you're looking for.
Use Grep to locate relevant sections before reading entire large files.
Never re-read a file you've already read in this session.
For files over 500 lines, use offset/limit to read only the relevant section.

### Responses
Don't echo back file contents you just read — the user can see them.
Don't narrate tool calls ("Let me read the file..." / "Now I'll edit..."). Just do it.
Keep explanations proportional to complexity. Simple changes need one sentence, not three paragraphs.

**Tables — STRICT RULES (apply everywhere, always):**
- Markdown tables: use minimum separator (`|-|-|`). Never pad with repeated hyphens (`|---|---|`).
- NEVER use box-drawing / ASCII-art tables with characters like `┌`, `┬`, `─`, `│`, `└`, `┘`, `├`, `┤`, `┼`. These are completely banned.
- No exceptions. Not for "clarity", not for alignment, not for terminal output.

## Committing — STRICT RULE (all projects, all branches)

**Never run `git commit` automatically.** The user reviews diffs and commits manually. After making code changes:
- Run gates (type-check, lint, tests, build) to validate
- Stage files if helpful (`git add`)
- Report what changed and stop

The only exception: the user explicitly says "commit it" / "ship it" / "go ahead and commit" in the same turn or as a standing override for the task.

This applies to all repos. If a per-repo CLAUDE.md or skill says to commit, treat that as a default that the user's standing rule overrides.

## Basic Memory skills

Use these skills on your own, without waiting to be asked, when the situation fits:

- Starting a session, or "continue", "back to", "where were we": `memory-continue`
- Before writing or editing any note: `memory-notes`
- A note would read better as a chart, table, checklist, kanban or live dashboard: `memory-comark`
- Decisions or insights worth keeping mid-thread or at the end: `memory-capture`
- Transcripts, logs or pasted documents to file away: `memory-ingest`
- Researching a company, person, technology or topic: `memory-research`
- Finding notes by frontmatter fields (status, priority, dates): `memory-metadata-search`
- Tracking tasks that must survive context compaction: `memory-tasks`
- Archiving or moving notes between status folders: `memory-lifecycle`
- Notes that share a type (Task, Person, Meeting) and need consistent fields: `memory-schema`
- The knowledge base needs linking, deduplication or hub notes: `memory-curate`
- Memory files are bloated or duplicated: `memory-defrag`
- Asked to reflect on recent activity: `memory-reflect`
- New to a project or setting up structure: `memory-onboarding`
- Only when asked: `memory-literary-analysis` (a whole book) and `memory-ci-capture` (CI only)

## Output for ADHD

Always apply this skill, every session, until I say "stop adhd mode":

@~/.claude/skills/i-have-adhd/SKILL.md
