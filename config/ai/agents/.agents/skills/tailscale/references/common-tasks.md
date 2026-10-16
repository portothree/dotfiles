# Common Tasks

## MagicDNS

MagicDNS automatically registers DNS names for every device on your tailnet. Enabled by default on tailnets created after October 20, 2022.

Once enabled, access devices by machine name:
```bash
ssh user@my-server
ping my-server
curl http://my-server:8080
```

### Fully qualified domain names

Every device gets an FQDN: `<machine-name>.<tailnet-name>.ts.net`

Example: `monitoring.yak-bebop.ts.net`

Short names (just `monitoring`) work within the same tailnet thanks to automatic search domain configuration.

### Enabling MagicDNS

If not already enabled, toggle it on in the admin console under **DNS**.

### Caveats

Some macOS tools (`host`, `nslookup`) bypass system DNS and won't resolve MagicDNS names. Use `ping` or `dig` instead.

Shared devices from other tailnets must be accessed by their full domain name.

---

## Tailscale SSH

Tailscale SSH replaces traditional SSH key management with identity-based authentication. Tailscale handles authentication using your tailnet identity and encrypts the connection with WireGuard.

### Setup

On the SSH server (Linux or macOS open-source variant only):
```bash
tailscale set --ssh
```

From any tailnet device:
```bash
ssh user@machine-name
```

Your existing SSH configuration and keys are not modified; non-Tailscale SSH connections continue to work.

### Access control

SSH access is controlled through the `ssh` section of the tailnet policy file:

```json
"ssh": [
  {
    "action": "accept",
    "src": ["group:engineering"],
    "dst": ["tag:server"],
    "users": ["autogroup:nonroot"]
  }
]
```

### Check mode

For high-risk connections (SSH as `root`), you can require re-authentication:

```json
{
  "action": "check",
  "src": ["group:ops"],
  "dst": ["tag:prod"],
  "users": ["root"],
  "checkPeriod": "8h"
}
```

The user must sign in with their identity provider before the connection is allowed. Default check period is 12 hours.

### SSH recording

Tailscale can record SSH sessions for audit and compliance. Configure in the admin console.

### Server platform support

- **Linux**: Full support
- **macOS**: Only with the open-source `tailscaled` CLI variant (not App Store or standalone GUI)

Clients can connect from any platform.

---

## Auth keys

For automated/headless device provisioning (CI runners, servers, containers):

1. Generate an auth key in the admin console under **Settings > Keys**
2. Use it to authenticate without a browser:
   ```bash
   sudo tailscale up --auth-key=tskey-auth-xxxxx
   ```

Auth keys can be:
- **Reusable** or **single-use**
- **Ephemeral** (device removed when it goes offline)
- **Pre-approved** (no admin approval needed)
- **Tagged** (device gets a tag identity instead of user identity)

---

## Key expiry

Device keys expire by default (180 days). When a key expires, the device must re-authenticate. To disable expiry:
- Go to the admin console and go to the Machines page > device menu > **Disable key expiry**
- Tagged devices have expiry disabled by default

For long-running servers, either disable key expiry or use tagged auth keys.
