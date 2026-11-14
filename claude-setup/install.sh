#!/usr/bin/env bash
# Install the Claude Code side of the application workflow on a new machine:
# brain-* skills, global CLAUDE.md, and saved memories.
# Never overwrites a file that differs; pass --force to overwrite (old copy kept as .bak).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
force=0; [[ ${1:-} == --force ]] && force=1
claude="$HOME/.claude"
mem="$claude/projects/$(printf '%s' "$HOME" | tr '/' '-')/memory"

place() {  # place <src> <dest>
  mkdir -p "$(dirname "$2")"
  if [[ ! -e $2 ]]; then cp "$1" "$2"; echo "installed  $2"
  elif cmp -s "$1" "$2"; then echo "up to date $2"
  elif (( force )); then cp "$2" "$2.bak"; cp "$1" "$2"; echo "replaced   $2 (old: $2.bak)"
  else echo "DIFFERS    $2  (diff it, or rerun with --force)"; fi
}

for f in "$here"/skills/*/SKILL.md; do
  place "$f" "$claude/skills/$(basename "$(dirname "$f")")/SKILL.md"
done
place "$here/CLAUDE.md" "$claude/CLAUDE.md"
for f in "$here"/memory/*.md; do place "$f" "$mem/$(basename "$f")"; done

touch "$mem/MEMORY.md"
while IFS= read -r line; do
  grep -qxF -- "$line" "$mem/MEMORY.md" || { echo "$line" >> "$mem/MEMORY.md"; echo "indexed    $line"; }
done < "$here/memory/MEMORY.lines"

[[ -d $HOME/brain ]] || echo "warning: ~/brain missing; clone it: git clone git@github.com:daxhielp/brain.git ~/brain"
for t in latexmk pdflatex pdfinfo pdftotext iconv; do
  command -v $t >/dev/null || echo "missing tool: $t (Arch/CachyOS: pacman -S texlive-basic texlive-latexextra poppler)"
done
