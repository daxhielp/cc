---
name: brain-interview
description: Interview the user to capture career goals, a past role, or a project into their knowledge vault at /home/daxhielp/brain. Use when the user wants to document their experience, fill in their vault, record what they did somewhere, or when another brain skill finds the vault too empty to work with.
---

# Interview

Capturing what's in someone's head is the bottleneck for this whole vault.
A blank markdown file gets abandoned; a conversation doesn't. Your job is to
make talking easy and do the writing yourself.

Vault: `/home/daxhielp/brain`

## Modes

`goals` · `role` · `project`. If the user didn't say, ask which — then start.

## How to run it

- **Three or four questions at a time.** A wall of twenty questions gets one
  answer and an abandoned session.
- **Follow the interesting thread.** If an answer opens something up, chase it
  before returning to your list. This is an interview, not a form.
- **Push for specifics.** "Improved efficiency" is worthless on a resume.
  Ask: improved from what, to what, measured how, over what period? Keep
  asking until there's a number or a clear admission there isn't one.
- **Never invent.** If they don't remember, tag it and move on.
- **Stop at ~15 minutes** or when answers get short. Say what you captured and
  offer to continue later. A partial file beats a stalled session.

## Mode: goals

Writes `facts/goals.md`. This is the highest-value file in the vault — the
roadmap skill is nearly useless without it.

Cover: planning horizon; whether they're levelling up, switching domains,
going independent, or exploring. What work energizes them (push past
generalities). What they're moving *away* from — often more diagnostic than
what they're moving toward. Hard constraints: geography, money floor, hours,
things they won't do. What they're unusually good at relative to peers. What
they'd need to believe for a change to be worth it.

## Mode: role

Writes `experience/<org>-<start-year>.md` and appends to `facts/timeline.yaml`.

Cover: org, title, exact dates, employment type. What they actually owned
versus what the title claimed. Team size, reporting lines. What was broken
when they arrived and what state they left it in. Specific things they built
or decided. Who they had to convince of what. What went badly and what they
learned. Any number that moved, with a before and after.

## Mode: project

Writes `projects/<slug>.md`. Same shape, scoped to one piece of work:
the problem, constraints, what they chose and what they rejected, the outcome,
what they'd do differently.

## Writing the output

Prose files: normal markdown, first person, their words where possible.
Use `[[wikilinks]]` to connect to related notes — Obsidian renders them and
grep still finds them.

Every factual claim also goes into `facts/timeline.yaml` with a `confidence`
tag: `verified` if they can point at a document, `recalled` if they're
confident from memory, `estimated` if it's a reconstruction. Ask which —
don't guess. This tag is what stops a fuzzy memory becoming a hard number on
a resume two years from now.

Show the user the YAML you're about to add before writing it.
