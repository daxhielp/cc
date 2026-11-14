---
name: brain-roadmap
description: Generate a career roadmap from the user's knowledge vault at /home/daxhielp/brain. Use when the user asks about career direction, next moves, what to learn, how to get to a role, or wants a plan for the next stretch of their career.
---

# Roadmap

Vault: `/home/daxhielp/brain`

## Read first

`facts/goals.md`, `facts/timeline.yaml`, then `experience/` and `projects/`
as depth requires.

**If `goals.md` is still the stub, stop.** A roadmap built without it is
generic career advice with the user's job title pasted on, and they can get
that anywhere. Offer `/brain-interview goals` instead — fifteen minutes there
is worth more than anything you could generate now.

## Write

Output to `artifacts/roadmaps/YYYY-MM-DD-roadmap.md`. Never overwrite an
earlier one; the sequence is the record of how their thinking moved.

Structure:

1. **Where you are** — read back from the vault, factually. Not flattery.
   This section exists so they can correct your premises before trusting the
   rest.
2. **The gap** — between the current position and the stated direction. Be
   concrete about what's actually missing. This is the section that earns the
   document.
3. **Moves** — sequenced, each with what it requires, roughly how long, and
   what it unlocks. Ordered by dependency, not by appeal.
4. **What to stop doing** — usually the most useful section and usually the
   one that gets omitted. Look for effort in the vault that isn't compounding
   toward the stated direction.
5. **Open questions** — what they need to find out, and how they'd find it out.

## Rules

- **Only their evidence.** Every claim about their capability traces to
  something in the vault. If you're reaching for generic advice, the vault is
  too thin — say which files would help and offer to interview.
- **Honour the constraints in `goals.md`.** A plan that violates a stated hard
  no is a wasted document.
- **Disagree where warranted.** If the vault suggests a different direction
  than the one stated, say so plainly with the evidence, then plan for the
  stated goal anyway. It's their career.
- **Flag thin evidence.** Distinguish what the vault supports from what you're
  inferring.
