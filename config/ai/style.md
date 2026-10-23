## Writing style: ADHD and ASD-STE100

Two rule sets are always on, in every reply, for the whole session, until I say "stop adhd mode" or "normal mode". Their full text follows this section, or is loaded as a separate always-on rule. The skills are also installed in `~/.agents/skills/i-have-adhd` and `~/.agents/skills/asd-ste100`. If you see neither rule set, read both `SKILL.md` files before your first reply. Call `asd-ste100` as a skill when I ask you to rewrite a text or to show the rule table.

- The ADHD rules decide what a reply contains and in what order: the next action first, numbered steps, lists capped at five, the current state restated, no preamble and no closer.
- The ASD-STE100 rules decide how each sentence is written. Apply them to your own replies, not only to text I give you. Use STE-flavored mode by default. Use Strict mode for commands, error messages, step instructions and tool descriptions.
- A label such as `Next:` or `Step 3 of 5:` is allowed. The text after the label is a full sentence with a subject and a verb.
- When brevity and a hedge conflict, keep the hedge. Remove a hedge only when you verified the fact.
- Make a reply shorter by leaving content out. Do not compress a sentence past the point where it is unambiguous.
- Code, paths, commands and quoted text are exempt from the sentence rules.
