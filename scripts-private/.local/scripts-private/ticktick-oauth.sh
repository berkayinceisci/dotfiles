#!/usr/bin/env bash
# One-time OAuth setup for TickTick.
#
# Walks through the authorization-code flow and writes
# TICKTICK_ACCESS_TOKEN to ~/dotfiles/ticktick.secrets.
#
# Prereqs (done manually once):
#   1. Sign in at https://developer.ticktick.com/manage
#   2. Create an app with Redirect URI: http://localhost:8080/callback
#   3. Put the Client ID / Secret into ~/dotfiles/ticktick.secrets
#      (the script will create a stub on first run).
#
# After running successfully, re-encrypt the secrets file with:
#   age -p -o ~/dotfiles/ticktick.secrets.age ~/dotfiles/ticktick.secrets

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SECRETS="$DOTFILES_DIR/ticktick.secrets"
REDIRECT_URI="http://localhost:8080/callback"
SCOPE="tasks:write"

if [[ ! -f "$SECRETS" ]]; then
	cat >"$SECRETS" <<'EOF'
TICKTICK_CLIENT_ID=
TICKTICK_CLIENT_SECRET=
TICKTICK_ACCESS_TOKEN=
EOF
	chmod 600 "$SECRETS"
	echo "Created $SECRETS — fill TICKTICK_CLIENT_ID and TICKTICK_CLIENT_SECRET from"
	echo "https://developer.ticktick.com/manage, then re-run this script."
	exit 1
fi

# shellcheck disable=SC1090
set -a
. "$SECRETS"
set +a

if [[ -z "${TICKTICK_CLIENT_ID:-}" || -z "${TICKTICK_CLIENT_SECRET:-}" ]]; then
	echo "ERROR: TICKTICK_CLIENT_ID or TICKTICK_CLIENT_SECRET empty in $SECRETS" >&2
	exit 1
fi

urlencode() { jq -rn --arg v "$1" '$v|@uri'; }

STATE="$(head -c 16 /dev/urandom | xxd -p)"
# Note: scope is intentionally NOT URL-encoded — TickTick's /oauth/authorize
# returns "unknown_exception" if the colon in `tasks:write` is percent-encoded.
AUTH_URL="https://ticktick.com/oauth/authorize?client_id=${TICKTICK_CLIENT_ID}&scope=${SCOPE// /+}&state=${STATE}&redirect_uri=$(urlencode "$REDIRECT_URI")&response_type=code"

echo "Opening browser to authorize..."
echo
echo "  $AUTH_URL"
echo
xdg-open "$AUTH_URL" >/dev/null 2>&1 &

echo "Listening on $REDIRECT_URI ..."

# Tiny one-shot HTTP listener. Captures ?code=... and ?state=..., responds 200,
# then exits. python3 is used because openbsd-nc on Manjaro is awkward for this.
RESPONSE_JSON="$(python3 - "$STATE" <<'PY'
import http.server, socketserver, sys, urllib.parse, json, threading

expected_state = sys.argv[1]
result = {}

class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a, **k): pass
    def do_GET(self):
        q = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        result["code"] = q.get("code", [""])[0]
        result["state"] = q.get("state", [""])[0]
        body = b"<html><body style='font-family:sans-serif'><h2>Authorized. You can close this tab.</h2></body></html>"
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
        threading.Thread(target=self.server.shutdown, daemon=True).start()

with socketserver.TCPServer(("127.0.0.1", 8080), H) as srv:
    srv.serve_forever()

if result.get("state") != expected_state:
    print(json.dumps({"error": "state mismatch"}))
else:
    print(json.dumps({"code": result.get("code", "")}))
PY
)"

CODE="$(printf '%s' "$RESPONSE_JSON" | jq -r '.code // empty')"
ERR="$(printf '%s' "$RESPONSE_JSON" | jq -r '.error // empty')"

if [[ -n "$ERR" ]]; then
	echo "ERROR: $ERR" >&2
	exit 1
fi
if [[ -z "$CODE" ]]; then
	echo "ERROR: no authorization code received" >&2
	exit 1
fi

echo "Exchanging authorization code for access token..."

TOKEN_RESP="$(curl -sS -u "${TICKTICK_CLIENT_ID}:${TICKTICK_CLIENT_SECRET}" \
	-X POST https://ticktick.com/oauth/token \
	-d "code=${CODE}" \
	-d "grant_type=authorization_code" \
	-d "scope=${SCOPE}" \
	-d "redirect_uri=${REDIRECT_URI}")"

ACCESS_TOKEN="$(printf '%s' "$TOKEN_RESP" | jq -r '.access_token // empty')"

if [[ -z "$ACCESS_TOKEN" ]]; then
	echo "ERROR: failed to obtain access token." >&2
	echo "Response: $TOKEN_RESP" >&2
	exit 1
fi

# Update only the TICKTICK_ACCESS_TOKEN line; preserve everything else.
if grep -q '^TICKTICK_ACCESS_TOKEN=' "$SECRETS"; then
	sed -i "s|^TICKTICK_ACCESS_TOKEN=.*|TICKTICK_ACCESS_TOKEN=${ACCESS_TOKEN}|" "$SECRETS"
else
	echo "TICKTICK_ACCESS_TOKEN=${ACCESS_TOKEN}" >>"$SECRETS"
fi
chmod 600 "$SECRETS"

echo
echo "✓ Access token saved to $SECRETS"
echo
echo "Next: re-encrypt the secrets file for git:"
echo "  age -p -o $SECRETS.age $SECRETS"
