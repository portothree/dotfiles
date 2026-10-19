# Instructions for every coding agent

Shared by Claude Code, Zed's agent, Codex and Antigravity. The source is
`config/ai/AGENTS.md` in the dotfiles repo (https://github.com/portothree/dotfiles,
checked out at `~/www/portothree/dotfiles`); edit it there. Every
`~/*/AGENTS.md` is a generated copy with the ADHD rules appended, so edits
reach them after a rebuild.

## Formatting

- Don't paste back file contents you just read.
- Markdown tables use the minimum separator (`|-|-|`), never padded (`|---|---|`).
- Never use box-drawing or ASCII-art tables (`┌`, `─`, `│`, `┼` and the like), not even in terminal output.

## Committing — STRICT RULE (all projects, all branches)

**Never run `git commit` automatically.** The user reviews diffs and commits manually. After making code changes:
- Run gates (type-check, lint, tests, build) to validate
- Stage files if helpful (`git add`)
- Report what changed and stop

The only exception: the user explicitly says "commit it" / "ship it" / "go ahead and commit" in the same turn or as a standing override for the task.

This applies to all repos. If a per-repo CLAUDE.md or skill says to commit, treat that as a default that the user's standing rule overrides.

## Third-party code

When you copy code, config or docs from another project into a repo, record
its license. If the repo has a `REUSE.toml`, add an annotation for the copied
path (upstream URL as a comment, its copyright and SPDX license) and run
`reuse download <SPDX-ID>`; otherwise add a notice the way that repo does. If
the source has no clear license, don't copy it; say so.

## Basic Memory

My notes live in Basic Memory (MCP server `basic-memory`, project `memex`). Its skills are in `~/.agents/skills`.

- Start of a thread: load context with the `memory-continue` skill. Without skills, call `recent_activity` and `search_notes` for the current project.
- Write only what's worth keeping: decisions, root causes, lessons, open items, status. Never write `[USER]`/`[ASSISTANT]` transcripts or a log of every exchange.
- Search before creating a note; if one already covers the ticket, PR or topic, update it instead of adding another.
- Don't use any built-in memory feature (Claude Code auto memory, Codex memories, Antigravity Knowledge Items, ChatGPT, Claude or Gemini memory), even when your harness offers one: don't save to it and don't rely on what it recalls. Save only to Basic Memory.

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

## Notion issue tracker

My work items, for every client, live in one Notion issue tracker database.
Reach it through the Notion MCP (`notion`). Each entry has an ID:

- The client's own ticket ID when they have a tracker, such as a Jira key.
- Otherwise one I assign: a client prefix and the next free number, such as `ABC-012`. Find the highest existing number for that prefix before picking the next.

Rules:

- When work maps to an entry (an ID in the task, branch, PR, linked issue or notes), fetch the entry before starting: search Notion for the ID.
- Never change an entry's Status yourself. When the work reaches a point where it might move (started, PR open, merged, issue closed), tell me the status you'd suggest and why; I decide, since some work stays in QA after a merge.
- Create an entry for new work I ask you to track, or for a follow-up I agree to. Link the source ticket or issue. Show me the ID, title and fields first.
- If the Notion MCP isn't available or authorized, say so in one line and give me the change to make by hand.

## Output for ADHD

Follow the ADHD output rules in every reply, for the whole session, until I say "stop adhd mode". They come from the `i-have-adhd` skill (`~/.agents/skills/i-have-adhd/SKILL.md`) and are already in your context: they are appended below, and Claude Code also loads them as its "ADHD" output style. If you see neither, read that file before your first reply.
