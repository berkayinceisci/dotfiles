#!/usr/bin/env bash
# Quick-add a TickTick task via rofi.
# Bound to Mod1+t in i3 config.

set -euo pipefail

SECRETS="$HOME/dotfiles/ticktick.secrets"
ROFI_THEME="$HOME/.config/rofi/config.rasi"

notify() { notify-send -a TickTick "$@"; }

if [[ ! -f "$SECRETS" ]]; then
	notify "TickTick" "No ${SECRETS/#$HOME/\~}. Run scripts/ticktick-oauth.sh."
	exit 1
fi

# shellcheck disable=SC1090
set -a
. "$SECRETS"
set +a

if [[ -z "${TICKTICK_ACCESS_TOKEN:-}" ]]; then
	notify "TickTick" "TICKTICK_ACCESS_TOKEN missing. Run scripts/ticktick-oauth.sh."
	exit 1
fi

TITLE="$(rofi -dmenu -p "Task" -lines 0 -theme "$ROFI_THEME" </dev/null || true)"
# Strip leading/trailing whitespace.
TITLE="${TITLE#"${TITLE%%[![:space:]]*}"}"
TITLE="${TITLE%"${TITLE##*[![:space:]]}"}"

if [[ -z "$TITLE" ]]; then
	exit 0
fi

BODY="$(jq -n --arg title "$TITLE" '{title: $title}')"

HTTP_OUT="$(mktemp)"
trap 'rm -f "$HTTP_OUT"' EXIT

STATUS="$(curl -sS -o "$HTTP_OUT" -w '%{http_code}' \
	-X POST https://api.ticktick.com/open/v1/task \
	-H "Authorization: Bearer ${TICKTICK_ACCESS_TOKEN}" \
	-H "Content-Type: application/json" \
	-d "$BODY")"

if [[ "$STATUS" =~ ^2 ]]; then
	notify "Task added" "$TITLE"
else
	ERR_MSG="$(jq -r '.error_description // .errorMessage // .message // .' <"$HTTP_OUT" 2>/dev/null || cat "$HTTP_OUT")"
	notify -u critical "TickTick failed (HTTP $STATUS)" "$ERR_MSG"
	exit 1
fi
