# Resume Tailoring Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn `~/Professional/cc` into a local repo where pasting a job description produces a tailored, one-page, ATS-readable LaTeX resume PDF at `applications/<YYYY-MM-DD>_<Company>_<Role>/daxhielperugorria_resume.pdf`. Reusable results get promoted into `templates/`.

**Architecture:** The facts come from the brain vault (`~/brain/facts/timeline.yaml`, which is authoritative). This repo holds only *renderings* of those facts: one exhaustive `master/master_resume.tex` (the "everything" document) plus narrower templates. Two small bash scripts do the mechanical work: creating the folder, compiling, and checking the PDF. A project skill (`tailor-resume`) encodes the six-step workflow so any Claude Code session in this folder runs it the same way.

**Tech Stack:** TeX Live 2026 from the Arch `extra` repo (pdfLaTeX + latexmk), poppler (`pdfinfo`, `pdftotext`; already installed), bash, git, and a Claude Code project skill.

**Spec:** The user's request (6-step workflow) plus `~/brain/.temp/project-brief.md` (vault constraints: $0, works from Claude Code *and* OpenCode, existing tools over custom code, `timeline.yaml` wins, never invent).

## Global Constraints

- Every fact on any resume comes from `~/brain/facts/timeline.yaml` (dates, titles, metrics, contact details) or `~/brain/experience|projects/*.md` (narrative only — **numbers come from the YAML only**, per vault rule 1). Nothing is invented. If a fact is missing, stop and offer `/brain-interview`.
- Metrics with `confidence: recalled|estimated` are marked in the `.tex` with a `% FLAG: <confidence>` comment and listed to the user before the PDF is called done. FLAGs are re-derived from the YAML's `confidence` fields at audit time, never trusted from existing comments.
- A PDF under `applications/` that is committed to git counts as **sent** and is immutable; `build-resume` refuses to overwrite it.
- The repo stays local or uses a private remote only. It contains contact details and PDFs.
- Output filename is exactly `daxhielperugorria_resume.pdf`.
- Application folder name: `<YYYY-MM-DD>_<Company>_<Role>` (ASCII, words joined with `-`, e.g. `2026-10-03_Acme-Corp_Data-Analyst`), so `ls` sorts chronologically.
- Paper size: US Letter.
- Pipeline runs from Claude Code only; no OpenCode wiring (vault content must not reach logged free-tier providers).
- Tailored resumes are one page (the build script enforces this). The master resume has no page limit.
- Scripts start with `#!/usr/bin/env bash`, because the login shell is fish.
- $0 cost: only Arch repo packages and the MIT-licensed template.
- The vault is never written from this repo. New facts go in through `brain-interview` or `brain-ingest` only.

## Review Focus

1. **Company or role names with `&`, `/`, `.`, or accents** (e.g. "AT&T", "R&D / ML Engineer", "Société Générale"). The folder name must still be a clean slug. The same characters inside the `.tex` must be escaped (`\&`). Tests are in Task 3, and the escaping rule is in the Task 5 skill.
2. **Second application to the same company+role on the same day.** It must not overwrite the first folder; it gets a `-2` suffix. Tested in Task 3.
3. **Tailored resume spills to 2 pages.** The build must fail loudly and must not produce a PDF that looks fine. Tested in Task 4.
4. **Failed LaTeX compile after a previous success.** A stale PDF from the previous build must not stay in the folder looking current. The build deletes the old PDF first. Tested in Task 4.
5. **Unverified metric reaches a sent resume.** The build prints every `% FLAG:` line, and the skill requires user confirmation. Tested in Task 4. Separately, the skill's audit step (Task 5, step 5) re-derives flags from the YAML, so a dropped comment can't hide a non-`verified` metric.
6. **Rebuilding an already-sent application** must not destroy the PDF that was sent. Tested in Task 4.

---

## Final layout

```
~/Professional/cc/
  AGENTS.md                      router + rules for agents (CLAUDE.md symlinks here)
  CLAUDE.md -> AGENTS.md
  .gitignore
  latex/resume.cls               shared style (derived from Jake's Resume, MIT)
  master/master_resume.tex       EVERY role/project/skill from the vault
  master/master_resume.pdf       built, for eyeballing
  templates/INDEX.md             one row per template: branch, target roles, keywords
  templates/<branch>/resume.tex  narrowed starting points (e.g. data-analyst/)
  applications/<date>_<Company>_<Role>/
      job_description.md         the pasted JD, verbatim
      resume.tex                 tailored source
      daxhielperugorria_resume.pdf
      notes.md                   what was chosen/changed and why, flags confirmed
  scripts/new-application        creates the folder, seeds resume.tex
  scripts/build-resume           compile + page/ATS/flag checks → PDF
  tests/run.sh, tests/fixtures/  script tests
  .claude/skills/tailor-resume/SKILL.md
```

How step 2 ("search for branches/areas") works: `templates/INDEX.md` maps each template to a branch, target roles, and keywords. The master is short enough (1–3 pages) for the model to read in full and pick sections from. Per-bullet tag comments were considered and cut, because they add upkeep on every vault update and gain little at this size.

---

### Task 0 (Steps 1–2 block Task 2, Step 3; all steps block Task 6): Populate the vault

The vault is empty today: `person` is blank and `roles: []`. No resume content can be written until it has facts.

- [ ] **Step 1 (approved vault edits):**
  - In `~/brain/AGENTS.md`, extend the `artifacts/` row to read: `Generated output — roadmaps, dated. Tailored job-application resumes live in ~/Professional/cc/applications.`
  - In `~/brain/facts/timeline.yaml`, add `email: ""`, `phone: ""`, `linkedin: ""`, and `github: ""` under `person`.
  - Commit both in the vault repo: `git -C ~/brain commit -am "schema: contact fields; point resumes at ~/Professional/cc"`.
- [ ] **Step 2:** Copy the user's **current resume** (PDF, plus the `.tex` source if one exists), any older resumes, the LinkedIn PDF export, and transcripts into `~/brain/raw/`, then run `/brain-ingest`. Keep a second copy of the current resume at `~/Professional/cc/reference/current_resume.<ext>`; Task 2 derives the visual style from it.
- [ ] **Step 3:** Run `/brain-interview role` once per role not covered by Step 1, and `/brain-interview project` for notable projects. Fill in `person.name`, `location`, `headline`, and `education`, plus contact fields (`email`, `phone`, `linkedin`, `github`).
- [ ] **Step 4:** Verify: `grep -cE '^\s*-\s*id:' ~/brain/facts/timeline.yaml` returns ≥ 1. This pattern skips the commented-out example. Also check that `person.name` is non-empty.

### Task 1: Install the LaTeX toolchain

**Files:** none (system packages)

- [ ] **Step 1: Install** (user runs this; it needs sudo):
  ```bash
  sudo pacman -S --needed texlive-basic texlive-latex texlive-latexextra texlive-fontsrecommended texlive-binextra
  ```
  This is about 430 MB. What each package provides for Jake's preamble:
  - `texlive-latex`: `fancyhdr`, `babel-english`, `hyperref`, `tools`
  - `texlive-fontsrecommended`: `marvosym`
  - `texlive-latexextra`: `titlesec`, `enumitem`, `fullpage` (from preprint). It also pulls in `latexrecommended`.
  - `texlive-binextra`: `latexmk`

  The full `texlive` group (several GB) is not needed. **Rejected alternative:** Tectonic. It caches packages, so offline use after the first build is fine. The real problem is that it is XeTeX-based, where `\pdfgentounicode` is undefined, so Jake's template fails to compile unless it is edited. pdfLaTeX runs the template unmodified.
- [ ] **Step 2: Verify** (fish syntax; in fish single quotes, a lone `\` is literal, so `%s` keeps printf from interpreting escapes):
  ```fish
  cd (mktemp -d); printf '%s\n' '\documentclass{article}\usepackage{titlesec,enumitem,fancyhdr,marvosym}\input{glyphtounicode}\pdfgentounicode=1\begin{document}Hello Perugorria\end{document}' > t.tex; latexmk -pdf -interaction=nonstopmode t.tex >/dev/null; and pdftotext t.pdf - | grep Perugorria
  ```
  Expected: `Hello Perugorria`. If CachyOS reports missing dependencies for `texlive-binextra` (this has been reported on discuss.cachyos.org), run `sudo pacman -Syu` first.

### Task 2: Repo scaffold, git, router, shared class

**Files:**
- Create: `AGENTS.md`, `CLAUDE.md` (symlink), `.gitignore`, `latex/resume.cls`, `templates/INDEX.md`, `applications/.gitkeep`
- Uses: `reference/current_resume.*` (from Task 0, Step 2)

- [ ] **Step 1:** `git init` in `~/Professional/cc`.
- [ ] **Step 2: `.gitignore`:**
  ```
  *.aux
  *.log
  *.out
  *.fls
  *.fdb_latexmk
  *.synctex.gz
  ```
  PDFs *are* committed. They are the record of what was sent where, and committing one marks it as sent (see `build-resume`). Keep the repo local, or push only to a private remote.
- [ ] **Step 3: `latex/resume.cls`, matching the user's current resume** (`reference/current_resume.*` from Task 0, Step 2):
  - **If a `.tex` source exists:** move its preamble into the class (rewrite `\usepackage` as `\RequirePackage`).
  - **If it is only a PDF/DOCX:** recreate its look (fonts, section-heading style, spacing, header layout) in LaTeX, starting from Jake's Resume (`https://github.com/jakegut/resume`, MIT; keep its notice) as the scaffold. Show the user a side-by-side build of the old resume and the new class, and iterate until they approve it.
  - **Either way**, the class must:
    - begin `\NeedsTeXFormat{LaTeX2e}` and `\ProvidesClass{resume}`, then `\LoadClass[letterpaper,11pt]{article}`;
    - include exactly one `\input{glyphtounicode}` and one `\pdfgentounicode=1`, so ATS text extraction works;
    - stay single-column, with no text inside images or tables used for layout;
    - expose this **stable macro interface**, which fixtures, templates, and the skill rely on whatever the visuals are: `\resumeSubHeadingListStart`/`End`, `\resumeSubheading{org}{dates}{title}{location}`, `\resumeItemListStart`/`End`, `\resumeItem{text}`, `\resumeProjectHeading{name}{dates}`.
  - If the design needs packages beyond Task 1's list, `pacman -S` the matching `texlive-*` package and note it in Task 1.
  - Add `reference/` to the commit; it is the style reference.
- [ ] **Step 4: `AGENTS.md`** (keep it under 60 lines; it's a router, matching the vault's convention):
  ```markdown
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
  ```
  Then `ln -s AGENTS.md CLAUDE.md`.
- [ ] **Step 5: `templates/INDEX.md`:**
  ```markdown
  # Templates

  | Template | Branch | Target roles | Keywords | Created from |
  |---|---|---|---|---|
  | master/master_resume.tex | all | fallback | — | vault |
  ```
- [ ] **Step 6:** Commit: `git add -A && git commit -m "chore: scaffold resume repo"`

### Task 3: `scripts/new-application`

**Files:**
- Create: `scripts/new-application`, `tests/run.sh`

**Interfaces:**
- Produces: `scripts/new-application <company> <role> [source.tex]` prints the absolute path of the new folder on stdout and copies `source.tex` (default `master/master_resume.tex`) to `<dir>/resume.tex`. The env var `RESUME_DATE` overrides today's date (tests only). Exit 2 means usage error, exit 1 means a missing source.

- [ ] **Step 1: Write failing tests (`tests/run.sh`):**
  ```bash
  #!/usr/bin/env bash
  set -uo pipefail
  root="$(cd "$(dirname "$0")/.." && pwd)"
  fail=0
  check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }

  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  mkdir -p "$tmp/applications" "$tmp/master" "$tmp/scripts"
  cp "$root"/scripts/* "$tmp/scripts/"
  echo '% master' > "$tmp/master/master_resume.tex"
  na() { RESUME_DATE=2026-10-03 "$tmp/scripts/new-application" "$@"; }

  d=$(na "AT&T" "R&D / ML Engineer")
  check "slug ampersand+slash" '[[ $(basename "$d") == "2026-10-03_ATandT_RandD-ML-Engineer" ]]'
  check "seeds resume.tex"     '[[ -f "$d/resume.tex" ]]'
  d2=$(na "AT&T" "R&D / ML Engineer")
  check "no overwrite same day" '[[ $(basename "$d2") == "2026-10-03_ATandT_RandD-ML-Engineer-2" ]]'
  d3=$(na "Société Générale" "Analyst")
  check "accents transliterated" '[[ $(basename "$d3") == "2026-10-03_Societe-Generale_Analyst" ]]'
  na "!!!" "Analyst" >/dev/null 2>&1; rc=$?; check "empty slug rejected" '[[ $rc -eq 2 ]]'
  na "Acme" "Analyst" "$tmp/nope.tex" >/dev/null 2>&1; rc=$?; check "missing source" '[[ $rc -eq 1 ]]'

  # build-resume tests are appended in Task 4
  exit $fail
  ```
- [ ] **Step 2:** `chmod +x tests/run.sh && tests/run.sh`. Expected: FAIL lines (the script doesn't exist yet).
- [ ] **Step 3: Implement `scripts/new-application`:**
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  usage() { echo "usage: new-application <company> <role> [source.tex]" >&2; exit 2; }
  [[ $# -ge 2 && $# -le 3 ]] || usage
  root="$(cd "$(dirname "$0")/.." && pwd)"
  slug() {
    printf '%s' "$1" | LC_ALL=C.UTF-8 iconv -f utf-8 -t ascii//TRANSLIT \
      | sed -E 's/&/and/g; s/[^A-Za-z0-9]+/-/g; s/^-+|-+$//g'
  }
  company=$(slug "$1") && role=$(slug "$2") || { echo "company/role must be valid UTF-8" >&2; exit 2; }
  [[ -n $company && -n $role ]] || { echo "company and role need letters or digits" >&2; exit 2; }
  src="${3:-$root/master/master_resume.tex}"
  [[ -f $src ]] || { echo "source not found: $src" >&2; exit 1; }
  base="$root/applications/${RESUME_DATE:-$(date +%F)}_${company}_${role}"
  dir=$base; n=2
  while [[ -e $dir ]]; do dir="$base-$n"; n=$((n + 1)); done
  mkdir -p "$dir"
  cp "$src" "$dir/resume.tex"
  printf '%s\n' "$dir"
  ```
  `LC_ALL=C.UTF-8` is set unconditionally. Under the C locale, iconv turns "é" into `?`, and the slug silently becomes `Soci-t-G-n-rale`.
- [ ] **Step 4:** `chmod +x scripts/new-application && tests/run.sh`. Expected: every line `ok`.
- [ ] **Step 5:** Commit: `feat: add new-application script`

### Task 4: `scripts/build-resume`

**Files:**
- Create: `scripts/build-resume`, `tests/fixtures/ok.tex`, `tests/fixtures/long.tex`, `tests/fixtures/broken.tex`, `tests/fixtures/flagged.tex`
- Modify: `tests/run.sh` (append before `exit $fail`)

**Interfaces:**
- Consumes: `latex/resume.cls` from Task 2.
- Produces: `scripts/build-resume <file.tex> [out.pdf]` compiles the file. `out.pdf` defaults to `<dir of file>/daxhielperugorria_resume.pdf`. The script prints the output path. It exits 1 on a compile error, too many pages, an unextractable PDF, or when the output is an already-committed PDF under `applications/`. `RESUME_MAX_PAGES` (default 1) raises the page limit. The master build is `RESUME_MAX_PAGES=99 scripts/build-resume master/master_resume.tex master/master_resume.pdf`.

- [ ] **Step 1: Fixtures.**

  `ok.tex`:
  ```latex
  \documentclass{resume}
  \begin{document}
  \begin{center}\textbf{\Huge Test Perugorria}\end{center}
  \section{Experience}
  \resumeSubHeadingListStart
  \resumeSubheading{Example Org}{2024 -- Present}{Analyst}{Remote}
  \resumeItemListStart
  \resumeItem{Built a reporting pipeline used by the finance team every week.}
  \resumeItemListEnd
  \resumeSubHeadingListEnd
  \end{document}
  ```
  `long.tex` is the same as `ok.tex` with the `\resumeItem` line pasted 80 times so it is certainly more than one page.
  `broken.tex` is `ok.tex` with `\end{document}` replaced by `\undefinedmacro\end{document}`.
  `flagged.tex` is `ok.tex` with `% FLAG: recalled` appended to the `\resumeItem` line.
  (These use the stable macro interface defined in Task 2, Step 3.)
- [ ] **Step 2: Append tests to `tests/run.sh`:**
  ```bash
  cp -r "$root/latex" "$tmp/latex"
  b() { mkdir -p "$tmp/b/$1"; cp "$root/tests/fixtures/$1.tex" "$tmp/b/$1/resume.tex"; "$tmp/scripts/build-resume" "$tmp/b/$1/resume.tex"; }
  b ok >/dev/null 2>&1;     check "ok builds"            '[[ -f $tmp/b/ok/daxhielperugorria_resume.pdf ]]'
  check "pdf text extractable" 'pdftotext "$tmp/b/ok/daxhielperugorria_resume.pdf" - | grep -q Perugorria'
  b long >/dev/null 2>&1; rc=$?;   check "2 pages rejected"     '[[ $rc -eq 1 && ! -f $tmp/b/long/daxhielperugorria_resume.pdf ]]'
  mkdir -p "$tmp/b/broken"; touch "$tmp/b/broken/daxhielperugorria_resume.pdf"
  b broken >/dev/null 2>&1; rc=$?; check "stale pdf removed on failure" '[[ $rc -eq 1 && ! -f $tmp/b/broken/daxhielperugorria_resume.pdf ]]'
  out=$(b flagged 2>&1);    check "flags reported"       'grep -q "FLAG: recalled" <<<"$out"'
  cp "$tmp/b/ok/resume.tex" "$tmp/master/m.tex"
  RESUME_MAX_PAGES=99 "$tmp/scripts/build-resume" "$tmp/master/m.tex" "$tmp/master/m.pdf" >/dev/null 2>&1
  check "custom tex + output path" '[[ -f $tmp/master/m.pdf ]]'
  # sent = committed under applications/
  s="$tmp/applications/2026-10-03_Sent_Role"; mkdir -p "$s"; cp "$tmp/b/ok/resume.tex" "$s/"
  "$tmp/scripts/build-resume" "$s/resume.tex" >/dev/null 2>&1
  git -C "$tmp" init -q && git -C "$tmp" add applications && git -C "$tmp" -c user.name=t -c user.email=t@t commit -qm sent
  before=$(md5sum <"$s/daxhielperugorria_resume.pdf")
  "$tmp/scripts/build-resume" "$s/resume.tex" >/dev/null 2>&1; rc=$?
  check "sent pdf protected" '[[ $rc -eq 1 && $(md5sum <"$s/daxhielperugorria_resume.pdf") == "$before" ]]'
  ```
- [ ] **Step 3:** Run `tests/run.sh`. Expected: the new lines FAIL.
- [ ] **Step 4: Implement `scripts/build-resume`:**
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  [[ $# -ge 1 && $# -le 2 ]] || { echo "usage: build-resume <file.tex> [out.pdf]" >&2; exit 2; }
  root="$(cd "$(dirname "$0")/.." && pwd)"
  [[ -f $1 ]] || { echo "not found: $1" >&2; exit 1; }
  tex="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  name=$(basename "$tex" .tex)
  out="${2:-$(dirname "$tex")/daxhielperugorria_resume.pdf}"
  out="$(cd "$(dirname "$out")" && pwd)/$(basename "$out")"
  case $out in
    "$root"/applications/*)
      if git -C "$root" ls-files --error-unmatch "$out" >/dev/null 2>&1; then
        echo "refusing: $out is committed (already sent). Tailor into a new folder." >&2; exit 1
      fi ;;
  esac
  rm -f "$out"
  build=$(mktemp -d); trap 'rm -rf "$build"' EXIT
  if ! TEXINPUTS="$root/latex//:" latexmk -cd -pdf -interaction=nonstopmode -halt-on-error \
        -outdir="$build" "$tex" >"$build/latexmk.out" 2>&1; then
    grep -A3 '^!' "$build/$name.log" >&2 || tail -20 "$build/latexmk.out" >&2
    exit 1
  fi
  pdf="$build/$name.pdf"
  pages=$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')
  max=${RESUME_MAX_PAGES:-1}
  if (( pages > max )); then echo "resume is $pages pages (max $max)" >&2; exit 1; fi
  words=$(pdftotext "$pdf" - | wc -w)
  if (( words < 10 )); then echo "PDF text not extractable ($words words); ATS will see nothing" >&2; exit 1; fi
  if grep -q 'Overfull \\hbox' "$build/$name.log"; then echo "warning: overfull hbox, text runs into margin" >&2; fi
  if grep -n '% FLAG:' "$tex" >&2; then echo "warning: unverified claims above; confirm with user before sending" >&2; fi
  mv "$pdf" "$out"
  printf '%s\n' "$out"
  ```
  latexmk names its output after the `.tex` basename, hence `$name`. With `-cd`, it runs from the file's own directory, so templates can `\input` sibling files.
- [ ] **Step 5:** `chmod +x scripts/build-resume && tests/run.sh`. Expected: all `ok`.
- [ ] **Step 6:** Commit: `feat: add build-resume with page, ATS, and flag checks`

### Task 5: `tailor-resume` project skill

**Files:**
- Create: `.claude/skills/tailor-resume/SKILL.md`

- [ ] **Step 1: Write the skill:**
  ```markdown
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
  ```
- [ ] **Step 2: Verify triggering:** start a fresh `claude` session in `~/Professional/cc`, paste a short fake JD ("We're hiring a Data Analyst at Acme…"), and confirm the skill loads without being named. Repeat with an unrelated prompt ("what's in this folder?") and confirm it does *not* load.
- [ ] **Step 3:** Commit: `feat: add tailor-resume skill`

(OpenCode wiring is intentionally **not** done, per Decision 6.)

### Task 6 (needs Task 0): Master resume

**Files:**
- Create: `master/master_resume.tex`, `master/master_resume.pdf` (built)

- [ ] **Step 1:** Generate `master/master_resume.tex` using `\documentclass{resume}`:
  - The header comes from `timeline.yaml: person`.
  - Include **every** role, education entry, certification, and project in the vault, in reverse-chronological order, with dates and titles copied exactly from the YAML.
  - Write several bullets per role, drawing on `experience/<id>.md` for narrative. Every number comes from the YAML `metrics`. Non-`verified` metrics get `% FLAG: <confidence>`.
  - Contact details come only from YAML `person` fields. If they are absent, leave them out and tell the user. Never pull them from session context.
  - At the top, add the line `% GENERATED FROM ~/brain on <YYYY-MM-DD>. Edit the vault, then regenerate; don't hand-edit facts here.`
- [ ] **Step 2:** Build: `RESUME_MAX_PAGES=99 scripts/build-resume master/master_resume.tex master/master_resume.pdf`. Expected: `master/master_resume.pdf` is created.
- [ ] **Step 3: Fact audit:** Check every date, title, org, and number in the `.tex` against `~/brain/facts/timeline.yaml`; prose doesn't count for numbers. Any miss is a bug; remove it. Re-derive FLAGs from the YAML `confidence` values. Show the user the PDF and the FLAG list.
- [ ] **Step 4:** Commit: `feat: master resume from vault`

### Task 7: End-to-end dry run

- [ ] **Step 1:** The user pastes a real job description. The `tailor-resume` skill runs all of steps 1–9.
- [ ] **Step 2:** Verify:
  - `ls applications/*/daxhielperugorria_resume.pdf` shows the new file.
  - `pdfinfo` reports `Pages: 1`.
  - `pdftotext` output reads top-to-bottom in a sensible order.
  - The user reads the PDF and confirms every claim is true.
- [ ] **Step 3:** Optionally, paste the `pdftotext` output into a free ATS checker to sanity-check parsing.

---

## Decisions (resolved 2026-10-03)

1. **Vault rule 5:** approved. The vault's `AGENTS.md` points tailored resumes to `~/Professional/cc/applications` (Task 0, Step 1).
2. **Folder name:** `<YYYY-MM-DD>_<Company>_<Role>`.
3. **Visual style:** match the user's current resume (Task 2, Step 3). Jake's Resume is only the scaffold if no `.tex` source exists.
4. **Contact fields:** approved. `email`, `phone`, `linkedin`, and `github` are added to `person` (Task 0, Step 1) and filled through `/brain-interview`.
5. **Paper:** US Letter.
6. **OpenCode:** not wired. The pipeline is Claude Code only.

## Out of scope (YAGNI for now)

Cover letters, auto-scraping job URLs, application-status tracking, and generating LaTeX from YAML with a templating engine. The model writes the `.tex` directly, and the vault YAML stays the authority.
