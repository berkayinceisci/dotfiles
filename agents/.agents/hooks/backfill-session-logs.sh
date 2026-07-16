#!/usr/bin/env bash
# One-time (idempotent) backfill: render every existing Claude Code transcript
# into the per-session markdown layout that the `Stop` hook now maintains, for
# both profiles (~/.claude and ~/.claude-moatlab).
#
# This re-renders from the raw .jsonl transcripts (the source of truth) — it does
# NOT parse or touch the old per-project cc-project-<slug>.md blobs. Archive those
# separately once you're satisfied with the split output.
#
#   --dry-run   list what WOULD be rendered (count per profile), render nothing
#   -v          verbose (per-file paths from the renderer)
#
# Safe to re-run any time: the renderer overwrites each <slug>/<id>.md in place.
set -uo pipefail

DRY=0
VERBOSE=0
for a in "$@"; do
    case "$a" in
        --dry-run) DRY=1 ;;
        -v|--verbose) VERBOSE=1 ;;
        *) echo "unknown arg: $a" >&2; exit 2 ;;
    esac
done

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENDERER="${HERE}/log-session.py"

profiles=("$HOME/.claude" "$HOME/.claude-moatlab")
grand_total=0
grand_rendered=0

for cfg in "${profiles[@]}"; do
    proj="${cfg}/projects"
    if [[ ! -d "$proj" ]]; then
        echo "== ${cfg}: no projects/ dir, skipping"
        continue
    fi

    # Real sessions live at projects/<slug>/<id>.jsonl (exactly depth 2). Deeper
    # .jsonl (subagent sidecars, workflow journals) are not standalone sessions.
    mapfile -d '' -t files < <(find "$proj" -mindepth 2 -maxdepth 2 -type f -name '*.jsonl' ! -name 'agent-*' -print0)
    n=${#files[@]}
    grand_total=$((grand_total + n))
    echo "== ${cfg}: ${n} transcripts"

    if [[ $DRY -eq 1 ]]; then
        for f in "${files[@]}"; do echo "   would render: $f"; done
        continue
    fi

    for f in "${files[@]}"; do
        if [[ $VERBOSE -eq 1 ]]; then
            python3 "$RENDERER" --transcript "$f" --no-symlink -v && grand_rendered=$((grand_rendered + 1))
        else
            python3 "$RENDERER" --transcript "$f" --no-symlink && grand_rendered=$((grand_rendered + 1))
        fi
    done
done

echo "----"
echo "transcripts found: ${grand_total}; rendered: ${grand_rendered}; dry-run: ${DRY}"
