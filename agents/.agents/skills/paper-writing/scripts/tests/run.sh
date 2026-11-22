#!/bin/bash
#
# run.sh: check prose-lint.sh against fixture.tex and the recorded output.
#
# Usage: run.sh [-v] [-u]
#   -v  print the commands and the diff on failure (to stderr)
#   -u  rewrite expected.txt from the current output; read the diff first
#
# fixture.tex holds at least one target per category. Two recorded hits are
# known false positives of older matchers: "be read-only" (passive) and
# "The first clause" (hype).

set -euo pipefail

verbose=0
update=0
while getopts "vu" opt; do
  case "$opt" in
    v) verbose=1 ;;
    u) update=1 ;;
    *) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
  esac
done

log() { if [[ $verbose -eq 1 ]]; then echo "[tests] $*" >&2; fi; }

here="$(cd "$(dirname "$0")" && pwd)"
cd "$here"
log "cwd=$here command=../prose-lint.sh fixture.tex"

actual="$(../prose-lint.sh fixture.tex)"

if [[ $update -eq 1 ]]; then
  printf '%s\n' "$actual" > expected.txt
  echo "expected.txt rewritten"
  exit 0
fi

# diff exits 1 when the outputs differ; that is the test result
if diff -u expected.txt <(printf '%s\n' "$actual") > /dev/null; then
  echo "prose-lint fixture: ok"
else
  echo "prose-lint fixture: output differs from expected.txt" >&2
  if [[ $verbose -eq 1 ]]; then
    diff -u expected.txt <(printf '%s\n' "$actual") >&2 || true
  fi
  exit 1
fi
