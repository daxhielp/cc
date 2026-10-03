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
