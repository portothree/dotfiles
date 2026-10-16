# Tailscale API

The Tailscale REST API automates device management, DNS, access control, logging, and user lifecycle. The full endpoint reference lives at one canonical doc page (linked below) — **WebFetch it for the current shape of any endpoint** before scripting against it.

> The API surface is large and adds/changes endpoints over time. Treat the inline examples as orientation. For exact request/response shapes, query parameters, and field names, fetch the reference page.

## Mental model

- **Base URL**: `https://api.tailscale.com/api/v2`
- **Tailnet path**: every tailnet-scoped endpoint takes a `{tailnet}` parameter; use `-` to refer to the caller's default tailnet (`/tailnet/-/devices`).
- **Auth**: three options.
  - **API access tokens** (`tskey-api-...`) — user-scoped, generated in the admin console, expire in 1–90 days.
  - **OAuth client credentials** (`tskey-client-...`) — machine-scoped, scope-restricted (`devices:read`, `devices:write`, `dns:read`, others), exchanged for short-lived access tokens.
  - **Trust credentials** — delegated fine-grained access with attribute-based limits. Use when you need API access tied to specific key/value claims rather than full admin rights.
- **Request style**: standard JSON for most endpoints; HuJSON (JSON with comments + trailing commas) for the ACL endpoint.
- **No pagination** today — list endpoints return everything in one response. Plan accordingly for large tailnets.
- **No published rate limits** — but expect throttling on hot loops; back off on 429s.

## Canonical shapes

### Authenticate

```bash
# Basic auth (token as username, empty password) — works with any token
curl -u "$TOKEN:" https://api.tailscale.com/api/v2/tailnet/-/devices

# Bearer
curl -H "Authorization: Bearer $TOKEN" https://api.tailscale.com/api/v2/tailnet/-/devices

# OAuth client credentials → access token
curl -X POST https://api.tailscale.com/api/v2/oauth/token \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "grant_type=client_credentials"
```

### Core device endpoints

```bash
# List devices in the tailnet
curl -u "$TOKEN:" https://api.tailscale.com/api/v2/tailnet/-/devices

# Get one device
curl -u "$TOKEN:" https://api.tailscale.com/api/v2/device/$DEVICE_ID

# Delete a device
curl -X DELETE -u "$TOKEN:" https://api.tailscale.com/api/v2/device/$DEVICE_ID

# Authorize / deauthorize a device (used by the auto-approval webhook pattern)
curl -X POST -u "$TOKEN:" -H "Content-Type: application/json" \
  -d '{"authorized": true}' \
  https://api.tailscale.com/api/v2/device/$DEVICE_ID/authorized

# Force re-auth (expire the device key)
curl -X POST -u "$TOKEN:" https://api.tailscale.com/api/v2/device/$DEVICE_ID/expire

# Replace device tags
curl -X POST -u "$TOKEN:" -H "Content-Type: application/json" \
  -d '{"tags": ["tag:server","tag:prod"]}' \
  https://api.tailscale.com/api/v2/device/$DEVICE_ID/tags
```

The list-devices response includes per-device fields like `id`, `hostname`, `addresses`, `tags`, `os`, and `lastSeen` (an ISO timestamp — the standard field for "is this device still active?" filtering).

### Create an auth key

```bash
curl -X POST -u "$TOKEN:" -H "Content-Type: application/json" \
  -d '{
    "capabilities": {
      "devices": {
        "create": {
          "reusable": true,
          "ephemeral": true,
          "preauthorized": true,
          "tags": ["tag:ci"]
        }
      }
    },
    "expirySeconds": 86400,
    "description": "CI runner key"
  }' \
  https://api.tailscale.com/api/v2/tailnet/-/keys
```

The key value is returned **only once** in the response.

### Update the policy file (ACL)

```bash
# GET returns HuJSON + an ETag for optimistic concurrency control
curl -u "$TOKEN:" https://api.tailscale.com/api/v2/tailnet/-/acl

# POST with If-Match: <etag> to prevent races
curl -X POST -u "$TOKEN:" -H "Content-Type: application/json" \
  -H "If-Match: \"$ETAG\"" \
  -d @policy.json \
  https://api.tailscale.com/api/v2/tailnet/-/acl

# Preview / validate before applying
curl -X POST -u "$TOKEN:" -H "Content-Type: application/json" \
  -d '{"src":"alice@example.com","dst":"tag:server"}' \
  https://api.tailscale.com/api/v2/tailnet/-/acl/preview
```

## Common automation patterns

- **Bulk delete stale devices**: list `/tailnet/-/devices`, filter by `lastSeen` against a threshold, `DELETE /device/{id}` for each. Throttle to avoid 429s.
- **Get a device ID** quickly: `tailscale status --json` is faster than an API round-trip and works locally.
- **Atomic policy updates**: always pass `If-Match` with the GET-returned `ETag`. Without it, a concurrent edit will silently overwrite yours.
- **Programmatic device approval**: webhook on `nodeNeedsApproval` → check your external state → POST to `/device/{id}/authorized`. Refer to `references/device-management.md`.

## Where to find current information

| User is asking about… | Fetch |
|---|---|
| Full REST API reference (endpoints, fields, query parameters) | https://tailscale.com/docs/reference/tailscale-api |
| OAuth clients — scopes, secret handling, ephemeral flag | https://tailscale.com/docs/features/oauth-clients |
| Trust credentials (delegated/fine-grained API access) | https://tailscale.com/docs/reference/trust-credentials |
| Webhooks — overview, events, payload shapes | https://tailscale.com/docs/features/webhooks |
| Rotate a webhook signing secret | https://tailscale.com/docs/features/webhooks/how-to/rotate-webhook-secret |
| Logging overview | https://tailscale.com/docs/features/logging |
| Configuration audit logs | https://tailscale.com/docs/features/logging/audit-logging |
| Network flow logs | https://tailscale.com/docs/features/logging/network-flow-logs |
| Log streaming (SIEM, S3) | https://tailscale.com/docs/features/logging/log-streaming |
| Logging streaming event schema | https://tailscale.com/docs/reference/logging-streaming-events |
| `tsnet` (embed a Tailscale node in a Go program) | https://tailscale.com/docs/reference/tsnet-server-api |

## Answering pattern

For **endpoint specifics** (request body, response shape, exact field names, query parameters), always fetch the API reference page — don't reconstruct from memory. The inline examples here are orientation; the source of truth is the reference.

For **OAuth scope names** — they evolve as new resources are added — fetch the OAuth clients page.

For **webhook event payloads** (`nodeNeedsApproval`, `nodeApproved`, others) and signature verification, fetch the webhooks page; the inline pattern only outlines the approval flow.

For **logging fields and event types**, fetch the logging-streaming-events page; the field set is large and changes as Tailscale adds telemetry.
