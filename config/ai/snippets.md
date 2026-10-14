# Agent prompt snippets

Prompts pasted into a new agent session. They live as Raycast snippets
(synced by Raycast Cloud Sync); this is the readable copy. `{clipboard}` is
Raycast's placeholder for the clipboard; without Raycast, paste the value in
its place.

They assume the Zed MCP servers from `config/editors/zed/.config/zed/settings.json`:
`aperture`, `basic-memory`, `jamie` and `slack-ocos`.

## Review a colleague's PR

Copy the PR URL first.

```
/ocos:review {clipboard}


- Use the basic-memory MCP to fetch and write context about this PR and its linked resources.
- Use the Jamie MCP to fetch transcripts, notes, and summaries related to this task and any related items.
- Use the Slack-OCOS MCP to fetch messages, threads, and other context related to this PR.


Save the review and comments as a draft. I want to review each comment in the GitHub UI and make any necessary updates before submitting.
```

## Cross-review between agents

One agent builds, another reviews, and they trade findings through one Basic
Memory note. Both read each other's sessions through Aperture (see the
Aperture section of the README).

1. Build in one agent, e.g. Claude in Zed.
2. Copy that session's ID from `http://localhost:8787/sessions`
   (`ancc_…` Claude, `ocdx_…` Codex).
3. Open the other agent, e.g. Codex in Zed, and paste **Cross-review**.
4. Back in the builder, paste **Address review**.
5. Repeat until the reviewer says it's ready for colleagues.

Replace `<repo> <branch>` in both so they find the same note.

### Cross-review (paste in the reviewer)

```
Review the work on the current branch. Another AI agent built it; you're the independent reviewer. Don't edit files, commit, push or post anything to GitHub.

Builder session in Aperture: {clipboard}
(If that isn't an Aperture session ID like ancc_… or ocdx_…, call aperture_list_sessions and pick the most recent session from the other agent that worked on this repo and branch. Tell me which one you picked and why.)

1. Context. What was asked and decided:
   - aperture_get_session for the summary and request list. Then aperture_get_session_request for the requests that carry my prompts and the agent's final answers. Claude Code requests only carry new messages, so skip tool round-trips unless a decision is unclear.
   - basic-memory: search for notes on this branch, ticket or PR.
   - Jamie: transcripts and summaries of meetings about this task.
   - slack-ocos: threads about this task or PR.
2. Code. What actually changed:
   - Run `git fetch`. Then run `git diff $(git merge-base origin/HEAD HEAD)...HEAD` plus `git diff HEAD` for uncommitted work.
   - Read the changed files in full where the diff alone isn't enough.
3. Review the code against what was asked: correctness, missed requirements, edge cases, tests that wouldn't fail if the code broke, security, and simpler alternatives. Check every claim the builder made in its session ("tests pass", "handled X") against the code. If the /ocos:review skill is available, use its rubric.
4. Hand-off. Write findings to the basic-memory note "Review: <repo> <branch>". Create it, or update it if it exists, adding a new "Round N" section. For each finding give:
   - id (R1, R2…), severity (blocker / should-fix / nit)
   - file:line, what's wrong, a concrete suggested fix
   - how to verify the fix
   Also list what you checked and found fine, and any open questions for me.
5. Reply with the note title, a ranked summary, and your verdict: ready for colleague review, or not yet.
```

### Address review (paste back in the builder)

```
An independent reviewer (another AI agent) reviewed this branch. Read the "Round N" findings in the basic-memory note "Review: <repo> <branch>", using the latest round. To see how the reviewer reached them, aperture_list_sessions shows its session.

For each finding:
1. Decide: accept, reject or needs-me. Base the decision on the code, not on agreeing.
2. Accept: fix it, then run the gates (type-check, lint, tests, build).
3. Reject: give a one-line reason backed by the code.

Under that round in the same note, add an "Addressed" section: finding id → decision → what changed, with file:line. Don't commit.
Reply with that table and anything that needs my decision. If you made non-trivial changes, I'll start another review round.
```
