---
name: tailor-resume
description: Tailor Dax's resume to a job description and save the PDF. Use when the user pastes a job posting or JD, says they're applying somewhere, or asks for a resume for a specific company or role.
---

# Tailor resume

Input: a job description (pasted text, file, or URL; if URL, fetch it and
confirm the text with the user). Repo root: ~/Professional/cc.

1. **Read the JD.** Pull out: company, exact role title, must-have skills,
   nice-to-haves, seniority, and the 10–15 keywords an ATS would match.
   If company or role is ambiguous, ask.
2. **Pick a starting point.** First check freshness: compare the master's
   `% GENERATED FROM ~/brain on <date>` line with
   `git -C ~/brain log -1 --format=%cs -- facts experience projects`.
   If the vault is newer, tell the user and offer to regenerate the master
   before continuing. Then read templates/INDEX.md and the master. Choose
   the template whose branch and keywords overlap the JD most; if none
   fits, use the master. Say which and why in one line.
3. **Create the folder:** `scripts/new-application "<Company>" "<Role>" <chosen.tex>`.
   Save the JD verbatim to `<dir>/job_description.md`.
4. **Tailor `<dir>/resume.tex`:**
   - Select and order roles/bullets by relevance to the JD; drop the rest.
   - Rephrase bullets to use the JD's vocabulary **only where the vault
     supports the claim**. Every fact traces to ~/brain/facts/timeline.yaml
     (dates/titles/metrics win) or ~/brain/experience|projects.
   - Never add a skill, tool, metric, or responsibility not in the vault.
     If the JD wants something the vault lacks, list it to the user as a
     gap; offer /brain-interview if they have the experience.
   - Escape LaTeX specials in any copied text: & % $ # _ { } ~ ^ \.
5. **Fact audit.** Diff `<dir>/resume.tex` against the seed it was copied
   from. For every changed or added line:
   - Each date, title, org, and number must match a field in
     ~/brain/facts/timeline.yaml. Numbers in experience/ prose don't count.
   - Each skill or tool must appear in the vault.
   - Any metric whose YAML `confidence` is not `verified` gets
     `% FLAG: <confidence>`. Derive this from the YAML; don't trust
     existing comments.

   Remove anything that fails.
6. **Build:** `scripts/build-resume <dir>/resume.tex`. On "N pages", cut
   the least relevant bullets and rebuild; do not shrink fonts or margins
   below the class defaults. Read the PDF back with `pdftotext` and check
   it reads in order.
7. **Report** in chat: the PDF path, what was emphasized/cut, JD keywords
   covered vs. missing, and every FLAG line. **Wait for the user to confirm
   flagged claims.** Write the report into `<dir>/notes.md`.
8. **Template promotion.** If this resume targets a role family not in
   templates/INDEX.md, propose saving it as `templates/<branch>/resume.tex`
   (remove company-specific phrasing first) and ask. On yes, copy it and add
   an INDEX.md row.
9. **Commit once:** `git add <dir> templates && git commit -m "apply: <Company> <Role>"`.
   Committing marks the application as sent. After this, `build-resume`
   refuses to overwrite its PDF.

Never edit an existing applications/* folder; tailor again into a new one.
