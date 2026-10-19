# Chat-app custom instructions

One always-on instruction text, pasted by hand into the custom instructions
of every chat app: ChatGPT, Claude.ai / Claude desktop and Gemini. It's the
chat-app copy of the rules the coding agents already get from this repo
(see "ADHD rules and memory" in the [README](../../README.md)).

## Why it isn't automated

These apps keep custom instructions and memory settings in the account, on
their servers, and have no public API to set them. Nix can't apply them, so
this file is both the source and the runbook: edit the text here, then paste
it into each app.

## Why one text under 1,500 characters

| App | Limit | Source |
|-|-|-|
| ChatGPT | 1,500 characters on Free and Go, 5,000 on Plus, Pro, Business, Enterprise and Edu | [Custom instructions for ChatGPT](https://help.openai.com/en/articles/8096356-custom-instructions-for-chatgpt) |
| Claude | Not documented | [Claude's personalization features](https://support.claude.com/en/articles/10185728-understanding-claude-s-personalization-features) |
| Gemini | Not documented | [Instructions for Gemini](https://support.google.com/gemini/answer/16598625) |

1,500 is the smallest documented limit, so one text that fits it works in
every app and on every plan, and there's only one copy to keep in sync.

## Why the rules are inline, not a pointer to the skill

The same rules live in the `i-have-adhd` skill, but a skill is the wrong
vehicle here:

- Custom instructions are in context from the first message. A skill loads
  only when it's selected, or when the model decides it applies.
- The skill is explicit-only: `disable-model-invocation: true` in its
  `SKILL.md` and `allow_implicit_invocation: false` in its
  `agents/openai.yaml`. A plain-text "use the i-have-adhd skill" can't make
  ChatGPT load it.
- Gemini on the web has no skills at all.

## Where to paste it

Copy the text from [The instruction text](#the-instruction-text), then:

1. ChatGPT web: Settings > Personalization > Custom instructions (below
   the memory and style sections). On iOS and Android it's Settings >
   Customize ChatGPT. The help page names a single "Custom Instructions"
   field; if your screen splits it into questions, use "What traits should
   ChatGPT have?". The desktop app's "Codex instructions" is not this field.
2. Claude.ai and Claude desktop: your initials (lower left) > Settings >
   General > "Instructions for Claude" (formerly "personal preferences").
3. Gemini: Menu > Settings & help > Personal Intelligence > Instructions for
   Gemini (the third card). In the app: Menu > your profile picture > Personal Intelligence.

## Turn off built-in memory

Basic Memory (MCP server `basic-memory`, project `memex`) is the only memory
store. The coding agents have theirs off in this repo
(`autoMemoryEnabled` in `config/ai/claude/.claude/settings.json`,
`[features] memories` in `config/ai/codex/.codex/config.toml`; Zed's agent has
no built-in memory; Antigravity has no off switch, so a rule in `AGENTS.md`
covers it). The chat apps keep the setting in the account, so set each screen
by hand to look like this.

### ChatGPT web: Settings > Personalization

| Setting | Set to |
|-|-|
| ChatGPT memory > Enable memory | Off |
| ChatGPT memory > Memory summary > Manage | Delete the old saved memories (optional) |
| Writing > Reference my writing style | Off (it reads your past chats) |
| Custom instructions | The text below |

The help pages still describe two toggles, "Reference saved memories" and
"Reference chat history"; the current screen has the single "Enable memory".
([Memory FAQ](https://help.openai.com/en/articles/8590148-memory-faq))

### ChatGPT desktop app: Settings > Personalization

| Setting | Set to |
|-|-|
| Codex memory > (machine picker) | Repeat for every machine listed, starting with Local |
| Enable Codex memories | Off |
| Allow memories from tool-assisted chats | Off |
| Delete Codex memories | Delete (optional, clears what's already saved) |
| Custom instructions > Codex instructions | Leave alone: it edits `~/.codex/AGENTS.md`, which the next switch replaces |
| Writing > Reference my writing style | Off |

"Enable Codex memories" is `[features] memories` in `~/.codex/config.toml`,
which this repo sets to `false` on every switch, so flipping it on in the app
lasts only until then. "Allow memories from tool-assisted chats" maps to
`memories.disable_on_external_context` and only matters while memories are on.
([Codex memories](https://learn.chatgpt.com/docs/customization/memories),
[config reference](https://learn.chatgpt.com/docs/config-file/config-reference))

### Claude.ai and Claude desktop: Settings > Memory

| Setting | Set to |
|-|-|
| Search and reference chats | Off |
| Generate memory from chats | Off; when it asks, choose Reset memory to delete the Profile and Topics it already has (Pause keeps them) |
| Include sensitive topics in memory | Off |
| Settings > General > Instructions for Claude | The text below |

([How Claude's memory works](https://support.claude.com/en/articles/11817273-how-does-claude-s-memory-work))

### Gemini: Menu > Settings & help > Personal Intelligence

| Setting | Set to |
|-|-|
| Memory | Off |
| Connected Apps | Your call; it's app data, not chat memory |
| Instructions for Gemini | The text below |

Turning off Gemini Apps Activity also turns memory off.
([Gemini memory](https://support.google.com/gemini/answer/16598469))

### Antigravity (Zed's `antigravity-acp`)

Knowledge Items, saved in `~/.gemini/antigravity/knowledge/`, have no
documented off switch
([agent settings](https://antigravity.google/docs/agent-settings/)). The
always-on rule in `~/.gemini/AGENTS.md` (built from `config/ai/AGENTS.md`)
tells the agent not to use them
([rules](https://antigravity.google/docs/rules)). Antigravity also loads
`~/.gemini/GEMINI.md` as a global rule; keep it free of old "Gemini Added
Memories" left by earlier Gemini CLI versions.

Screens checked against the apps on 2026-10-19; the linked help pages lag
behind some labels.

## How to update it

1. Edit the text below.
2. Check it's under 1,500 characters (run from the dotfiles checkout):

   ```sh
   sed -n '/^```text$/,/^```$/{//!p;}' config/ai/chat-instructions.md | wc -m
   ```

3. Paste it into every app in [Where to paste it](#where-to-paste-it).

It's a condensed copy of `config/ai/agents/.agents/skills/i-have-adhd/SKILL.md`
plus accuracy rules. When either changes, consider updating the other. The
skill is vendored and updated weekly (see the README), so read its diff in
the update PR with this file in mind.

## The instruction text

```text
Format every reply for a reader with ADHD, in every chat, until I say "stop adhd mode":
1. First line = the next action (command, path, snippet), not context.
2. Number multi-step work; one action per step; fewest steps that work.
3. End with one concrete next action I can do in under 2 minutes.
4. No tangents; offer side issues as one separate question.
5. Restate progress each turn ("Step 3 of 5 done. Next: Y.").
6. Time estimates in minutes/hours, never "a bit".
7. Max 5 items per list, ranked; never drop relevant items.
8. No preamble, recap, praise, filler or closing pleasantries.
9. Errors: cause, then fix. Show wins concretely ("Login works now. Try: ...").
Be honest, critical, precise. Never imply you did something you can't do.
Separate facts from interpretation; don't speculate. Flag unverified claims; write "Uncertain" when sources conflict.
For time-sensitive facts, search the web and cite direct URLs with dates; check links match claims.
If I'm wrong, challenge me with evidence. Quote loaded terms neutrally.
Explain obscure terms. Give the result, not your reasoning, unless I ask.
"Plain text" or "print" = one Markdown code block, nothing else.
Break the format when I ask you to explain, before destructive actions (confirm first), after 3 failed fixes (name the wrong assumption), or when my request is ambiguous (ask one short question).
```
