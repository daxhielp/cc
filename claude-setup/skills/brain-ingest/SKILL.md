---
name: brain-ingest
description: Process documents dropped in /home/daxhielp/brain/raw — convert to markdown, add frontmatter, classify, and stage for review before merging into the knowledge vault. Use when the user says they've added files to raw, asks to ingest or process documents, or wants old resumes and PDFs pulled into their vault.
---

# Ingest

Vault: `/home/daxhielp/brain`

Pipeline: `raw/` → convert → `staging/` → user approves → vault + `archive/originals/`

**Never skip the staging step.** A date misread from a 2019 PDF becomes a
wrong date on every resume generated from this vault from now on, and nothing
will ever surface the error. Staging is the only place it gets caught.

## 1. Survey

List `raw/` (ignore `README.md`). Nothing there — say so and stop.

## 2. Convert — with tools, not with yourself

Run the conversion in bash. Do not read a PDF into context and retype it:
it's slow, it burns usage, and it introduces transcription errors that
`pdftotext` does not make.

| Input              | Command                                          |
|--------------------|--------------------------------------------------|
| `.docx .odt .rtf .html` | `pandoc -t markdown_strict --wrap=none -o out.md in` |
| `.pdf` (text layer) | `pdftotext -layout in.pdf out.txt`               |
| `.pdf` (scanned)    | Fall back to reading it yourself — see below     |
| `.md .txt`          | copy as-is                                       |

If a tool is missing, say which and how to install it (`apt install pandoc
poppler-utils`), then handle that file manually.

Detect a scanned PDF by near-empty `pdftotext` output. Only then read the PDF
directly and transcribe. Note `extraction: ocr` in the frontmatter so a human
knows the text is less trustworthy.

## 3. Frontmatter

Body stays **verbatim** — do not summarize, reformat, or fix the prose. All
your judgment goes into the frontmatter:

```yaml
---
title: ""
date: YYYY-MM        # from the content, not the file mtime; null if unknown
doc_type: resume | job-description | writing | performance-review | reference | other
source: archive/originals/<filename>
extraction: pandoc | pdftotext | ocr | verbatim
summary: ""          # 2-3 sentences: what this is, why it matters
entities: []         # orgs, projects, people named
tags: []
---
```

`summary` is load-bearing. It's how future agents decide whether to open a
twenty-page file, so write it for that reader.

## 4. Stage and report

Write to `staging/<slug>.md`. Then report, per document:

- proposed destination (`experience/`, `projects/`, `writing/`, `archive/`)
- the summary line
- **any facts that contradict `facts/timeline.yaml`** — flag loudly, never
  auto-resolve
- proposed `timeline.yaml` additions, shown as YAML. Tag `confidence: verified`
  when `extraction` was `pandoc`/`pdftotext`/`verbatim`. Tag
  `confidence: estimated` when `extraction: ocr` — a transcribed scan is a
  reconstruction, not a document you can point at — and say so explicitly.

Old resumes are the highest-value and highest-risk input: dense with dates and
numbers, and often already wrong. Treat every claim in them as a proposal.

## 5. Merge — only after the user says go

Move staged file to destination. Move the original to `archive/originals/`
(move, never delete — the original is the evidence). Apply the timeline patch.
Commit: `ingest: <n> documents`.

If the user only approves some, merge those and leave the rest staged.
