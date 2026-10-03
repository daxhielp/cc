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
git -C "$tmp" init -q && git -C "$tmp" add applications && git -C "$tmp" -c user.name=t -c user.email=t@t -c commit.gpgsign=false commit -qm sent
before=$(md5sum <"$s/daxhielperugorria_resume.pdf")
"$tmp/scripts/build-resume" "$s/resume.tex" >/dev/null 2>&1; rc=$?
check "sent pdf protected" '[[ $rc -eq 1 && $(md5sum <"$s/daxhielperugorria_resume.pdf") == "$before" ]]'
err=$("$tmp/scripts/build-resume" "$tmp/b/ok/resume.tex" "$tmp/nodir/x.pdf" 2>&1 >/dev/null); rc=$?
check "missing out dir rejected" '[[ $rc -eq 1 && $err == *"no such directory"* ]]'
exit $fail
