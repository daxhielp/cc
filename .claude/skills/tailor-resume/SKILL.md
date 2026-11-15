---
name: tailor-resume
description: Tailor Dax's resume to a job description and save the PDF. Use when the user pastes a job posting or JD, says they're applying somewhere, or asks for a resume for a specific company or role.
---

# Tailor resume

Input: a job description (pasted text, file, or URL; if URL, fetch it and
confirm the text with the user). Repo root: ~/Professional/cc.

**First:** cd ~/Professional/cc. All paths in this skill (scripts/, templates/, applications/) are relative to that root.

1. **Read the JD.** Pull out: company, exact role title, must-have skills,
   nice-to-haves, seniority, and the 10–15 keywords an ATS would match.
   If company or role is ambiguous, ask.
2. **Pick a starting point.** First check freshness: compare the master's
   `% GENERATED FROM ~/brain on <YYYY-MM-DDTHH:MM:SS±HH:MM>` line (a full
   ISO-8601 timestamp) with
   `git -C ~/brain log -1 --format=%cI -- facts experience projects`.
   If the vault is newer, tell the user and offer to regenerate the master
   before continuing. Then read templates/INDEX.md and the master. Choose
   the template whose branch and keywords overlap the JD most; if none
   fits, use the master. Say which and why in one line.
3. **Create the folder:** `scripts/new-application "<Company>" "<Role>" <chosen.tex>`.
   Capture the folder path that the script prints as `<dir>`. Save the JD
   verbatim to `<dir>/job_description.md`.
4. **Tailor `<dir>/resume.tex`:**
   - Sources, in order of authority: (1) ~/brain/facts/timeline.yaml
     (dates/titles/metrics win); (2) ~/brain/experience|projects; (3) the
     reference resume (`reference/current_resume.pdf`, same text as
     ~/brain/archive/2026-current-resume.md) for skills, coursework,
     locations, and bullet content. Where they conflict, the higher source
     wins. Never reuse reference claims the vault has retracted (86 tests /
     90% coverage, "zero-dependency", "open-source", "reverse-engineered",
     "architected" the Transformer, "2 models", "200+ attendees"); read the
     `resume wording rules` comments in timeline.yaml first.
   - **Density:** the result must be at least as full as the reference
     resume, filling the one page. Do not drop real content just to look
     minimal; cut only what is irrelevant to the JD, and fill the freed space
     with more JD-relevant detail (education coursework, skills, fuller
     bullets, relevant roles from the reference).
   - **Focus:** reorder and reword so the JD's skills lead: skills section
     first-class and ordered by JD priority, JD-relevant coursework listed,
     most relevant projects/roles first. Use the JD's exact terms where true.
   - **ATS:** one column, standard headings (Education, Technical Skills,
     Experience, Projects), plain text, no tables/icons/colors, dates with
     month and year, every JD keyword the user genuinely has appears
     verbatim at least once.
   - **Style** (user rules, 2026-11-15; these override template wording):
     - Write for a stranger. Someone who has never seen these projects must
       understand each bullet. Describe what the project is and does in
       plain engineering terms; don't copy vault prose verbatim.
     - Drop project-internal terminology and detail irrelevant to the job:
       class/module names, internal codenames, file and fixture names.
     - Prefer the acronym and never spell it out: "REST", not "REST
       (Representational State Transfer)".
     - No parenthetical asides in bullets. Fold the content into the
       sentence or cut it. The tech stack in a project heading is fine.
     - Never say "MIDI-over-TCP"; say the mixer's network control protocol,
       or whatever generic description fits the JD.
     - Never say work was written or generated with AI tools. Stay truthful
       the other way too: for VibeDungeon say "designed"; never claim the
       user wrote all the code.
   - Never add a skill, tool, metric, or responsibility not in any source
     above. If the JD wants something none of them has, list it as a gap;
     offer /brain-interview if they have the experience.
   - Escape LaTeX specials in any copied text: & % $ # _ { } ~ ^ \.
5. **Fact audit.** Audit EVERY line of the final `<dir>/resume.tex`
   (one page), including content carried in from a template. For every date,
   title, org, number, and skill:
   - Each date, title, org, and number must match timeline.yaml where it has
     the field; numbers found only in the reference must also not be on the
     retracted list above. Numbers in experience/ prose don't count.
   - Each skill or tool must appear in the vault or the reference resume.
   - Any fact whose YAML entry's `confidence` is not `verified` gets
     `% FLAG: <confidence>`. Facts sourced only from the reference (not in
     the YAML) get `% FLAG: reference-only` and are listed to the user.
     Re-derive every FLAG; don't trust existing comments.

   Remove anything that fails.
6. **Build:** `scripts/build-resume <dir>/resume.tex` to produce
   `daxhielperugorria_resume.pdf` next to the .tex. On "resume is N pages
   (max 1)", cut the least relevant bullets and rebuild; do not shrink fonts
   or margins below the class defaults. Note: `% FLAG:` warnings from
   build-resume are expected. Read the PDF back with `pdftotext` and check
   it reads in order.
7. **Blind review loop.** Spawn the `resume-reviewer` subagent
   (`.claude/agents/resume-reviewer.md`; it has no file, shell, web, or MCP
   tools). It must never see the vault or anything about the user. Its
   prompt contains only:
   - the JD text, and
   - the `pdftotext -layout` output of the built PDF with the header
     removed: no name, phone, email, or links.

   Pass nothing else: no vault excerpts, notes, FLAG comments, or context
   about the user. It returns `SCORE: n/100` and a numbered fix list. For
   each fix, apply it if the sources in step 4 support it. If it asks for
   something the sources lack, don't add it; record it as a gap. Then re-run
   the fact audit (step 5) and the build (step 6), and spawn a **fresh**
   reviewer on the new draft. Repeat until a round scores >= 90/100.
   **Do not come to the user before that.** The one exception: if three
   rounds in a row stay under 90 only because of fixes you can't make
   truthfully, stop and report the score and the blocking fixes in step 8.
   Keep each round's score and fixes for notes.md.
8. **Report** in chat: the PDF path, what was emphasized/cut, JD keywords
   covered vs. missing, every FLAG line, the reviewer score for each round,
   and any reviewer fixes you declined, with the reason. **Wait for the user
   to confirm flagged claims.** If the user rejects or edits any claim, go
   back to step 4, tailor again, re-run the fact audit, build, and review
   loop, then report again. Once the user confirms all claims, write the
   report into `<dir>/notes.md`.
9. **Template promotion.** If this resume targets a role family not in
   templates/INDEX.md, propose saving it as `templates/<branch>/resume.tex`
   (remove company-specific phrasing first) and ask. On yes, copy it and add
   an INDEX.md row.
10. **User confirmation before commit:** Ask the user explicitly: is the resume
   final and ready to commit and send? Explain that committing marks the
   application as sent and makes the PDF immutable—build-resume will refuse to
   overwrite it afterwards. Proceed to step 11 only on a yes.
11. **Commit once:** `git add <dir>` (and `templates` only if the user agreed to
   template promotion in step 9), then `git commit -m "apply: <Company> <Role>"`.
   After this, `build-resume` refuses to overwrite the PDF.

Never edit an existing applications/* folder; tailor again into a new one.
