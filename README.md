# Archer Exchange docs

Source for [docs.archer.exchange](https://docs.archer.exchange), built with
[Mintlify](https://mintlify.com). Mintlify deploys on every push to `main`.

## The API reference is generated. Do not write endpoint pages by hand

The **API Reference** tab is generated from `openapi.json` in this repo:

```json
{ "tab": "API Reference", "openapi": "openapi.json" }
```

`openapi.json` is a copy of the spec the production API serves at
`https://api.archer.exchange/v1/docs/openapi.json`. To change how an endpoint is
documented, edit its summary, description or schema in
`archer-backend/crates/rest-api/static/openapi.json`. That repo's CI checks the
spec against the router, so an endpoint cannot ship undocumented.

After a backend deploy that changed the spec:

```bash
./sync-spec.sh        # fetch from production, validate, replace openapi.json
git add openapi.json && git commit -m "Sync API spec" && git push
```

## If the site stops updating

Mintlify refuses to build with an invalid `openapi.json`, keeps serving the
previous version of the whole site, and says only "Failed to fetch OpenAPI file"
on the commit's check run. That message is misleading: it also means "fetched
it, and it failed validation". Check before pushing:

```bash
npx mint validate     # the same build check Mintlify runs
```

Deployment status for a commit is on its GitHub check run, "Mintlify
Deployment".

## What is written by hand

Everything OpenAPI cannot express:

| Section | Contents |
|---|---|
| `overview/`, `architecture/` | What Archer is, MakerBooks, the matching engine, fees, maker registries |
| `getting-started/` | Starter template, best practices |
| Trading API pages (repo root) | The WebSocket API, tutorials and client examples. OpenAPI cannot describe WebSockets, so this is the only place it is documented |

## Local preview

```bash
npm i -g mint
mint dev              # http://localhost:3000
```
