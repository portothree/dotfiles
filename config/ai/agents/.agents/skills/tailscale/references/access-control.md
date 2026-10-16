# Access Control

Tailscale uses a deny-by-default model — all connections between devices are blocked unless explicitly allowed. Access rules are defined in the **tailnet policy file**, which you edit in the admin console under **Access Controls**.

## Use grants, not ACLs

**When generating or editing policy files for a user, default to grants.** ACLs still work and are documented below so you can read existing policies and help users migrate, but every new rule you write should be a grant. Grants are Tailscale's recommended access-control primitive: they unify network-layer access (what ACLs do) with application-layer capabilities (Kubernetes API server proxy, Aperture LLM routing, tsrecorder session recording, Taildrive shares) in one syntax. ACLs cannot express application-layer rules at all — if a user wants network access today but might want capability-based access tomorrow, starting with grants saves them a rewrite.

The grant-vs-ACL choice only applies to **access rules**. Several other policy-file sections have their own dedicated syntax and aren't expressed as grants: `"ssh"` (SSH access rules), `"autoApprovers"` (auto-approving advertised routes and exit nodes), `"nodeAttrs"` (node-level attributes like Funnel), `"postures"` (device posture definitions, referenced from grants via `srcPosture`), and the `"groups"`/`"tagOwners"` definitions.

**Canonical reference:** https://tailscale.com/docs/reference/grants-vs-acls — WebFetch this when you need the current side-by-side comparison, migration guidance, or the most up-to-date list of capability schemas. The summary here is enough to write a basic grant; reach for the live doc when the user needs the full conversion table or a capability you haven't seen before.

### ACL → grant conversion

The same network access, written both ways:

```json
// ACL (legacy — for reading existing policies)
"acls": [
  {
    "action": "accept",
    "src": ["group:engineering"],
    "dst": ["tag:server:*"]
  }
]

// Grant (use this for new policies)
"grants": [
  {
    "src": ["group:engineering"],
    "dst": ["tag:server"],
    "ip": ["*"]
  }
]
```

Grants drop the `"action"` field (deny-by-default means every grant is implicitly "accept") and split the destination's port spec out of the `dst` string into a separate `"ip"` field. `"ip": ["*"]` means all ports; use `["tcp:22", "tcp:443"]` to restrict.

## Tailnet policy file structure

The policy file is JSON and can contain these sections:

```json
{
  "groups": { },
  "tagOwners": { },
  "grants": [ ],
  "acls": [ ],
  "ssh": [ ],
  "autoApprovers": { }
}
```

### Groups

Define named groups of users:
```json
"groups": {
  "group:engineering": ["alice@example.com", "bob@example.com"],
  "group:ops": ["carol@example.com"]
}
```

### Tags

Tags provide service-account identity for non-user devices (servers, CI runners, IoT). A tagged device is owned by the tag rather than a user.

```json
"tagOwners": {
  "tag:server": ["group:ops"],
  "tag:ci": ["group:engineering"]
}
```

Apply tags when registering a device (via auth key) or from the admin console. Tagged devices have key expiry disabled by default.

Naming conventions: `tag:prod-app`, `tag:staging-db`, `tag:prod-emea-web`.

### Grants

Each grant specifies source, destination, and allowed capabilities:

```json
"grants": [
  {
    "src": ["group:engineering"],
    "dst": ["tag:server"],
    "ip": ["*:*"]
  },
  {
    "src": ["group:engineering"],
    "dst": ["tag:nas"],
    "app": {
      "tailscale.com/cap/drive": [{
        "shares": ["docs", "media"]
      }]
    }
  }
]
```

Note: SSH access is **not** controlled via grants capabilities. SSH rules are defined in the separate top-level `"ssh"` section of the policy file.

When a grant doesn't behave as expected (access denied that should be allowed, or the reverse), WebFetch the grants troubleshooting page: https://tailscale.com/docs/reference/troubleshooting/grants

### ACLs (legacy — read-only)

Documented so you can read existing policy files and help users migrate. Do not write new ACLs — write the equivalent grant instead (refer to ACL → grant conversion above).

```json
"acls": [
  {
    "action": "accept",
    "src": ["group:engineering"],
    "dst": ["tag:server:*"]
  }
]
```

### SSH rules

Control Tailscale SSH access:

```json
"ssh": [
  {
    "action": "check",
    "src": ["group:ops"],
    "dst": ["tag:server"],
    "users": ["root"]
  },
  {
    "action": "accept",
    "src": ["autogroup:member"],
    "dst": ["autogroup:self"],
    "users": ["autogroup:nonroot"]
  }
]
```

Actions: `accept` (allow), `check` (require re-authentication), `deny`.

### Auto-approvers

Automatically approve routes and exit nodes for specific users or tags:

```json
"autoApprovers": {
  "routes": {
    "10.0.0.0/8": ["tag:infra"]
  },
  "exitNode": ["tag:exit"]
}
```

## Targets and selectors

You can use these as sources or destinations in grants/ACLs:

- **Users**: `alice@example.com`
- **Groups**: `group:engineering`
- **Tags**: `tag:server`
- **Autogroups**: `autogroup:member` (all users), `autogroup:self` (same device), `autogroup:internet` (exit node traffic), `autogroup:nonroot` (non-root SSH users)
- **IP addresses/CIDRs**: `192.168.1.0/24`

## Default policy

New tailnets start with an "allow all" policy. This is convenient for getting started but should be tightened for production use. The default lets all members to access all devices on all ports, and lets SSH to all devices as non-root users.

## Just-in-time and least-privilege access

The least-privilege model is: grant narrow, standing access with tags and groups, and layer time-bound elevation on top rather than handing out broad admin rights. Tailscale supports several mechanisms:

- **Accessbot** provides just-in-time (JIT), on-demand access through a request-and-approve workflow in Slack. A user requests elevated access, an approver grants it, and the access is time-bound so it expires automatically. This is the primary JIT tool for "elevated access only when needed."
- **Device posture attributes** are key-value pairs attached to devices that grants can gate on, so access depends on the device's current state, not just identity.
- **Check mode** on SSH rules (`"action": "check"`) forces re-authentication for high-risk sessions (for example SSH as `root`), with a `checkPeriod` controlling how often. This is the SSH-level piece of JIT.

Combine these with grants and groups to keep standing privilege minimal and require an explicit, auditable step for elevation. Fetch the pages below for the current Accessbot setup and posture-attribute syntax before writing configuration.

### Where to find current information

| If the user wants to… | Fetch |
|---|---|
| Stop handing out standing admin access and grant elevated access only when needed | https://tailscale.com/docs/features/access-control/just-in-time-access |
| Add an approval step (for example in Slack) before someone gets elevated access | https://tailscale.com/docs/features/tailscale-accessbot-jit |
| Lock down production access to least-privilege for a compliance audit | https://tailscale.com/docs/use-cases/infrastructure-access/manage-least-priviledged-and-jit-access |
