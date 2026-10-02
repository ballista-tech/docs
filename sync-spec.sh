#!/usr/bin/env bash
# Refresh openapi.json from the deployed API.
#
# The API Reference tab is generated from this file. Run this after any backend
# deploy that changed the spec, then commit and push; Mintlify deploys on push.
#
# The new spec is validated before it replaces the old one. Mintlify refuses to
# build with an invalid spec and keeps serving the previous version of the whole
# site, reporting only "Failed to fetch OpenAPI file" on the commit's check. So
# an invalid spec must be caught here, not found out later from stale docs.
#
# Fetch from the DEPLOYED API, never from archer-backend's static file: the
# server reorders `servers` so the host it was fetched from is first. The
# static file lists Staging first, which would point the docs playground at
# staging.
set -euo pipefail
cd "$(dirname "$0")"
URL="${1:-https://api.archer.exchange/v1/docs/openapi.json}"
NEW="openapi.new.json"
trap 'rm -f "$NEW"' EXIT

curl -fsS --max-time 30 "$URL" -o "$NEW"
python3 -c "
import json; d=json.load(open('$NEW'))
s=d['servers'][0]
assert s['description']=='Production', f\"expected Production first, got {s['description']}\"
print(f\"fetched: {len(d['paths'])} paths, playground default {s['url']}\")
"
# Same validator Mintlify's build runs.
if ! npx -y mint@latest openapi-check "$NEW"; then
  echo "The deployed spec is invalid; openapi.json was left unchanged." >&2
  echo "Fix it in archer-backend (crates/rest-api/static/openapi.json), deploy, and rerun." >&2
  exit 1
fi
mv "$NEW" openapi.json
trap - EXIT
echo "openapi.json updated. Review the diff, then commit and push."
