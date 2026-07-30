#!/usr/bin/env bash
# Notify IndexNow (Bing, Yandex, Seznam, Naver) that pages changed.
#
# IndexNow is an open protocol -- it needs no account and no Bing Webmaster
# signup. Verification works by hosting <key>.txt at the site root containing
# exactly the key. That file MUST already be deployed before pinging, or the
# submission is rejected.
#
# Usage:  ./indexnow.sh                 # ping every URL in sitemap.xml
#         ./indexnow.sh https://…/x     # ping specific URLs
set -euo pipefail

HOST="gampang-ingat.com"
KEY="ccad0bac50f10f5e9ef3c861b13a9e5f"
KEY_LOCATION="https://${HOST}/${KEY}.txt"

# Confirm the key file is actually live, otherwise the ping silently fails.
if ! curl -fsS "$KEY_LOCATION" | grep -qx "$KEY"; then
  echo "ERROR: $KEY_LOCATION is not serving the key yet." >&2
  echo "Push and let Cloudflare deploy first, then re-run." >&2
  exit 1
fi

if [ $# -gt 0 ]; then
  URLS=("$@")
else
  mapfile -t URLS < <(grep -o '<loc>[^<]*</loc>' "$(dirname "$0")/sitemap.xml" \
                      | sed 's|</\?loc>||g')
fi

echo "Submitting ${#URLS[@]} URL(s) to IndexNow…"
printf '  %s\n' "${URLS[@]}"

payload=$(printf '{"host":"%s","key":"%s","keyLocation":"%s","urlList":[%s]}' \
  "$HOST" "$KEY" "$KEY_LOCATION" \
  "$(printf '"%s",' "${URLS[@]}" | sed 's/,$//')")

code=$(curl -sS -o /tmp/indexnow-resp.txt -w '%{http_code}' \
  -X POST 'https://api.indexnow.org/indexnow' \
  -H 'Content-Type: application/json; charset=utf-8' \
  --data "$payload")

echo "HTTP $code"
case "$code" in
  200) echo "OK - key VERIFIED and URLs submitted. This is the success signal." ;;
  202) echo "Accepted, but key validation is still PENDING - this is NOT yet proof of success."
       echo "(A deliberately invalid key also returns 202, verified 2026-07-30.)"
       echo "Re-run in a few minutes; a 200 means the key was actually verified." ;;
  400) echo "Bad request - check the JSON payload." >&2; cat /tmp/indexnow-resp.txt >&2 ;;
  403) echo "Key not valid for this host - is ${KEY_LOCATION} live?" >&2 ;;
  422) echo "URLs do not match the host, or key mismatch." >&2 ;;
  429) echo "Rate limited - too many submissions." >&2 ;;
  *)   cat /tmp/indexnow-resp.txt >&2 ;;
esac
