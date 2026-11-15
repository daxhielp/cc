---
name: resume-style-rules
description: User's resume wording rules (2026-11-15) — generic, outsider-readable bullets; no MIDI-over-TCP, no "written with AI tools", acronyms not spelled out, no parentheticals
metadata:
  type: feedback
---

Rules for every tailored resume (user, 2026-11-15):
- Never use the term "MIDI-over-TCP".
- Never say work was "mostly written with AI tools" or similar.
- Prefer acronyms; don't spell them out.
- No project-specific terminology or detail irrelevant to the job.
- Avoid parentheses in bullet text.
- Bullets must be understandable by someone who has never seen the project; describe what it is about rather than copying vault wording verbatim.
- Before showing the user a draft, it must score >= 90/100 from the blind `resume-reviewer` subagent, which gets no vault or personal info.

**Why:** user wants generic, readable resumes, and wants quality checked by an unbiased reader before they review anything.

**How to apply:** encoded in the tailor-resume skill steps 4 and 7 in ~/Professional/cc. Applies alongside [[no-eclair-on-resumes]].
