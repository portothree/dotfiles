# Instructions for every coding agent

Shared by Claude Code, Zed's agent, Codex and OpenCode. The source is
`config/ai/AGENTS.md` in the dotfiles repo; edit it there.

## Responses
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

## Basic Memory

My notes live in Basic Memory (MCP server `basic-memory`, project `memex`). Its skills are in `~/.agents/skills`.

- Start of a thread: load context with the `memory-continue` skill. Without skills, call `recent_activity` and `search_notes` for the current project.
- Write only what's worth keeping: decisions, root causes, lessons, open items, status. Never write `[USER]`/`[ASSISTANT]` transcripts or a log of every exchange.
- Search before creating a note; if one already covers the ticket, PR or topic, update it instead of adding another.

Use these skills on your own when the situation fits:

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
- The knowledge base needs linking, deduplication or hub notes: `memory-curate`. Don't run it unprompted: when loaded or searched notes show several notes for one ticket, the same topic in different folders, or `[USER]`/`[ASSISTANT]` transcripts, say so in one line and suggest running `memory-curate` on that project folder
- Memory files are bloated or duplicated: `memory-defrag`
- Asked to reflect on recent activity: `memory-reflect`
- New to a project or setting up structure: `memory-onboarding`
- Only when asked: `memory-literary-analysis` (a whole book) and `memory-ci-capture` (CI only)

## Output for ADHD

Follow the rules in `~/.agents/skills/i-have-adhd/SKILL.md` in every reply, for the whole session, until I say "stop adhd mode". Read that file at the start of each session if it isn't already in your instructions.
