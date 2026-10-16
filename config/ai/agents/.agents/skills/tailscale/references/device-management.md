# Device Management & Enterprise Rollout

This reference covers device approval, **device posture** (compliance-based access), **MDM** deployment, and **SCIM** user/group provisioning. These are the controls used at organizational scale to decide who and what is allowed on the tailnet.

> Several of these areas have their own doc trees with per-vendor integration pages (MDM vendors, EDR/posture integrations, identity providers). The shapes below are stable; **WebFetch the matching page** for current attribute names, vendor configuration steps, and plan availability before applying configuration.

## Mental model

Four overlapping layers of control:

1. **Device approval** — gates new devices joining the tailnet. Either manual (admin clicks "approve") or automated (pre-approved auth keys, or a webhook-driven API approval flow).
2. **Device posture** — decides which devices can access which resources, based on attributes (OS, Tailscale version, geolocation, EDR signals). Wired into ACLs via `srcPosture` on a grant, or via a tailnet-wide `defaultSrcPosture`.
3. **MDM deployment** — silent installation + locked-down configuration of the client itself, across a managed fleet (macOS/Windows/iOS/Android).
4. **SCIM provisioning** — automated user/group lifecycle from your IdP (Okta, Entra, Google Workspace). When someone is deactivated upstream, their Tailscale access ends with it.

For programmatic device management at scale (bulk add/remove, listing devices, approving via API), use the REST API — refer to `references/api.md`.

## Canonical shapes

### Device posture — define and apply

```json
"postures": {
  "posture:compliantDevice": [
    "node:os IN ['macos', 'windows']",
    "node:tsVersion >= '1.60'",
    "node:tsAutoUpdate == true"
  ],
  "posture:geoRestricted": [
    "ip:country IN ['US', 'CA']"
  ]
},
"grants": [
  {
    "src": ["group:dev"],
    "dst": ["tag:production"],
    "ip": ["*"],
    "srcPosture": ["posture:compliantDevice", "posture:geoRestricted"]
  }
],
"defaultSrcPosture": ["posture:compliantDevice"]
```

- Multiple postures in `srcPosture` are **OR**'d — match any one.
- `defaultSrcPosture` applies to every grant that doesn't specify its own (explicit `srcPosture` **replaces** the default, not adds to it).
- Built-in attributes worth knowing by name: `node:os`, `node:osVersion`, `node:tsVersion`, `node:tsAutoUpdate`, `node:tsReleaseTrack`, `ip:country`. Verify the full current set against the posture docs page.
- Custom attributes (set via API or EDR integrations) are available on Premium/Enterprise.

### Enable SCIM provisioning

SCIM is enabled from the Tailscale side first: in the **admin console**, enable provisioning under **user management**, then copy the generated SCIM API key (case-sensitive) into your IdP's SCIM configuration (Okta, Entra, Google Workspace). Exact menu location and IdP-side fields change as the console and vendor UIs evolve, so **fetch the vendor-specific setup page** below rather than relying on a hard-coded path.

### SCIM-driven groups in the policy file

When SCIM is synced from an IdP, group names in the policy file match the IdP's group names (typically formatted as `group:<name>@<domain>`):

```json
"tagOwners": {
  "tag:logging": ["group:security-team@example.com"]
},
"grants": [{
  "src": ["group:security-team@example.com"],
  "dst": ["tag:logging"],
  "ip": ["*"]
}]
```

Role changes in the IdP propagate to access automatically. **Deactivate** users in the IdP rather than suspending — suspended users retain access until their device keys expire.

### Automated device approval via API

For approval logic that depends on external state (internal asset registry, EDR clean bill of health, others):

```bash
# Triggered by the nodeNeedsApproval webhook event
curl "https://api.tailscale.com/api/v2/device/$DEVICE_ID/authorized" \
  -u "tskey-api-xxxxx:" \
  --data-binary '{"authorized": true}'
```

For non-webhook automation, **pre-approved auth keys** (Settings > Keys > Pre-approved) bypass manual approval entirely — appropriate for MDM-provisioned devices where the MDM is the trust anchor.

### Enterprise rollout sequence

A rollout that has worked across many tailnets:

1. **Identity provider** — SSO (Okta / Entra / Google Workspace).
2. **SCIM provisioning** — automate user + group sync.
3. **Device approval** — turn on; require admin review for new devices.
4. **Tags + groups** — model access (groups = humans, tags = machines/services).
5. **Device posture** — define baseline postures, enforce via `srcPosture`.
6. **MDM** — push Tailscale to managed devices with pre-approved + tagged auth keys for silent enrollment.
7. **Session recording** (`references/session-recording.md`) for SSH audit trails.
8. **Tailnet lock** for cryptographic node signing in high-security environments.

## Where to find current information

### Device approval & management

| User is asking about… | Fetch |
|---|---|
| Device management overview | https://tailscale.com/docs/features/access-control/device-management |
| Device approval (concept + admin flow) | https://tailscale.com/docs/features/access-control/device-management/device-approval |
| Set up device approval | https://tailscale.com/docs/features/access-control/device-management/how-to/set-up |
| QR-code enrollment | https://tailscale.com/docs/features/access-control/device-management/how-to/set-up-qr-code |
| Remove devices at scale | https://tailscale.com/docs/features/access-control/device-management/how-to/remove |
| Filter the device list | https://tailscale.com/docs/features/access-control/device-management/how-to/filter |
| Export the device list | https://tailscale.com/docs/features/access-control/device-management/how-to/export-list |
| Manage device identity / re-auth | https://tailscale.com/docs/features/access-control/device-management/how-to/manage-identity |

### Device posture & EDR integrations

| User is asking about… | Fetch |
|---|---|
| Device posture — full attribute list, syntax | https://tailscale.com/docs/features/device-posture |
| CrowdStrike Falcon (ZTA) integration | https://tailscale.com/docs/integrations/crowdstrike-zta |
| SentinelOne integration | https://tailscale.com/docs/integrations/sentinelone |
| Kolide / 1Password XAM integration | https://tailscale.com/docs/integrations/kolide |
| Fleet (`osquery`) integration | https://tailscale.com/docs/integrations/fleet |
| Jamf Pro (posture + MDM) | https://tailscale.com/docs/integrations/jamf-pro |

### MDM deployment

| User is asking about… | Fetch |
|---|---|
| MDM overview | https://tailscale.com/docs/mdm |
| Partner MDM index | https://tailscale.com/docs/integrations/partners/mdm |
| macOS MDM | https://tailscale.com/docs/integrations/mdm/mac |
| iOS MDM | https://tailscale.com/docs/integrations/mdm/ios |
| Android MDM | https://tailscale.com/docs/integrations/mdm/android |
| Jamf | https://tailscale.com/docs/integrations/mdm/jamf |
| Microsoft Intune | https://tailscale.com/docs/integrations/mdm/microsoft-intune |
| Intune (alternate page) | https://tailscale.com/docs/integrations/mdm/intune |
| JumpCloud | https://tailscale.com/docs/integrations/mdm/jumpcloud |
| Iru / Kandji | https://tailscale.com/docs/integrations/mdm/iru |
| SimpleMDM | https://tailscale.com/docs/integrations/mdm/simplemdm |
| TinyMDM | https://tailscale.com/docs/integrations/mdm/tinymdm |
| Google Workspace (Android management) | https://tailscale.com/docs/integrations/mdm/google-workspace |

### User & group provisioning (SCIM)

| User is asking about… | Fetch |
|---|---|
| User management overview | https://tailscale.com/docs/manage-users |
| SCIM / user-group provisioning | https://tailscale.com/docs/features/user-group-provisioning |
| Okta SCIM setup | https://tailscale.com/docs/integrations/identity/okta/okta-scim |
| Microsoft Entra ID SCIM setup | https://tailscale.com/docs/integrations/identity/entra/entra-id-scim |

## Worked examples

| If the user wants to… | Fetch |
|---|---|
| Automatically give and revoke access as people join or leave the company | https://tailscale.com/docs/use-cases/vpn-replacement/employee-onboarding-offboarding |
| Only let compliant or healthy devices connect (posture checks) | https://tailscale.com/docs/use-cases/regulated-environment/enforce-device-compliance |
| Keep an unencrypted or non-compliant laptop from reaching a production database | https://tailscale.com/docs/solutions/protect-postgresql-unencrypted-macbooks |
| Give remote or work-from-home staff secure access to internal systems | https://tailscale.com/docs/use-cases/vpn-replacement/remote-workers |

## Answering pattern

For **posture** questions, the inline attribute names (`node:os`, `node:tsAutoUpdate`, `ip:country`, `srcPosture`, `defaultSrcPosture`) are usually enough to draft a working `postures` block. Fetch the posture page when a user needs a specific attribute (custom claims, EDR-derived attributes, full operator list).

For **MDM / EDR / SCIM** vendor questions, **always fetch the vendor-specific page** — these are step-by-step setup guides with screenshots and exact field names that change as vendor user interfaces evolve. Don't paraphrase the inline mental model; quote the fetched page.

For **bulk device operations** (list, delete, approve at scale), point the user at `references/api.md` for current REST endpoints — the shapes in the API drift more than ACL syntax does.
