# Professional development repo

Tailored resumes built from the brain vault. Facts live in ~/brain
(read ~/brain/AGENTS.md first); this repo only renders them.

| Path | Contains |
|---|---|
| master/master_resume.tex | Every role/project/skill, generated from the vault |
| templates/INDEX.md | Which template targets which roles |
| applications/ | One folder per application. Never edit after sending. |
| scripts/ | new-application, build-resume |

## Rules
1. To tailor a resume to a job description, use the `tailor-resume` skill.
2. Never put a fact on a resume that isn't in ~/brain/facts/timeline.yaml
   or ~/brain/experience|projects. Missing → say so, offer /brain-interview.
3. Non-`verified` metrics get `% FLAG: <confidence>` and are listed to the user.
4. Never modify an existing applications/* folder; it is a sent record.
5. Escape LaTeX specials (& % $ # _ { } ~ ^ \) in any text from a JD.
6. Vault content is used from Claude Code only (see ~/brain/.temp/project-brief.md §6).
