# Connectivity: Peer Relay, DERP, and Tailnet Lock

This reference covers how Tailscale connections are established (direct vs relayed), the DERP network, peer relays (user-operated relays), and Tailnet Lock (cryptographic node signing).

> The Tailscale connection model is stable, but the specifics — peer-relay flags, DERP regions list, Tailnet Lock CLI subcommands — evolve. The shapes below are oriented toward the **why** and the **what to configure**; **WebFetch the matching page** for current flag names, region IDs, and step-by-step Tailnet Lock setup.

## Mental model

Tailscale tries three connection paths in order, all WireGuard-encrypted end-to-end:

1. **Direct peer-to-peer** — preferred. NAT traversal (STUN, port mapping) establishes a direct tunnel. Lowest latency, full throughput.
2. **Peer relay** — fallback through a user-operated relay device on the tailnet. Lower latency than DERP because the relay sits on your infrastructure.
3. **DERP relay** — final fallback through Tailscale's global relay network. Always works.

All relays forward **encrypted** packets blindly — relays (peer or DERP) cannot decrypt traffic. The choice of path is per-peer-pair, not tailnet-wide.

**NAT type matrix:**

| Peer A | Peer B | Result |
|---|---|---|
| No NAT | Any NAT type | Direct |
| Easy NAT | Easy NAT | Direct |
| Easy NAT | Hard NAT | Relayed (peer relay or DERP) |
| Hard NAT | Hard NAT | Relayed (peer relay or DERP) |

The rule: a connection is relayed if both sides are Hard NAT, or if one side is Hard NAT and the other is Easy NAT. Everything else is direct. "Easy NAT" = UPnP / NAT-PMP / PCP support, full-cone NAT, consistent port mapping (IPv6 is treated as Easy NAT). "Hard NAT" = symmetric NAT, CGNAT, or strict firewalls.

DERP also serves a second role: **connection negotiation**. Even direct connections use DERP briefly to exchange discovery (DISCO) packets before switching to direct.

## Canonical shapes

### Configure a peer relay

On the device that will relay (Linux/macOS/Windows — not iOS/Android):

```bash
tailscale set --relay-server-port=<port>
```

The port must be reachable from devices that will use this relay (public IP, or port-forwarded).

Then in the tailnet policy file, grant relay capability:

```json
"grants": [{
  "src": ["autogroup:member"],
  "dst": ["tag:relay"],
  "app": {
    "tailscale.com/cap/relay": [] // the relay capability takes no parameters
  }
}]
```

Tag your relay devices with `tag:relay` (or whatever tag you used in the grant).

### Customize the DERP map

In the tailnet policy file, you can add custom DERP regions or omit defaults:

```json
"derpMap": {
  "OmitDefaultRegions": false,
  "Regions": {
    "900": {
      "RegionID": 900,
      "RegionCode": "myderp",
      "RegionName": "My Custom DERP",
      "Nodes": [{
        "Name": "myderp1",
        "RegionID": 900,
        "HostName": "derp.example.com"
      }]
    }
  }
}
```

The official DERP map (with current region IDs) is at `https://controlplane.tailscale.com/derpmap/default`. **Running your own DERP** is generally not recommended; peer relays solve the latency problem with less complexity and don't lose access to device sharing or cross-tailnet features.

### Tailnet Lock — initialize and operate

Tailnet Lock prevents unauthorized nodes from joining the tailnet even if the coordination server were compromised. Every new node must be signed by an existing trusted device.

Conceptual pieces:
- **Tailnet Lock Key (TLK)** — Ed25519 key pair on a signing node; admins designate which are trusted.
- **Tailnet Key Authority (TKA)** — local signed chain (think git) tracking trusted TLKs and signed node keys.
- **Authority Update Message (AUM)** — signed message that modifies trusted-key state.
- **Disablement secrets** — `tailscale lock init` generates and displays ten; any single one is enough to disable Tailnet Lock. They are the **only** way to disable it if needed. **Store them in a safe / password manager.** Losing them means the tailnet cannot be recovered without Tailscale support.

Core CLI flow (full setup is admin-console-driven):

```bash
tailscale lock init                                # On a chosen signing node
tailscale lock sign nodekey:<key> tlpub:<key>      # Sign a new device's join
tailscale lock add tlpub:<key>                     # Add a trusted signing key
tailscale lock remove tlpub:<key>                  # Remove one
tailscale lock revoke-keys tlpub:<key>             # Revoke compromised key (needs co-signing)
tailscale lock status                              # Inspect TKA state
tailscale lock log                                 # Recent AUMs
tailscale lock disable <secret>                    # Disable using a recovery secret
tailscale lock local-disable                       # Emergency: ignore TL on this node only
```

**Constraints to remember:**
- Up to 20 signing nodes.
- Rotate TLKs at most once per year (TKA growth bound).
- **Mutually exclusive with Device Approval** — pick one.
- Android devices can receive signatures but cannot sign.
- Initial trust is "trust on first use" from the coordination server — verify `tailscale lock status` on multiple nodes after init.

## Remote desktop over the tailnet (RDP, VNC, RustDesk)

Reaching a desktop remotely is just a TCP connection over the tailnet. There is no port forwarding and no exposing the machine to the public internet. The remote device joins the tailnet, and you point your desktop client at its **MagicDNS hostname** or **100.x Tailscale IP**.

**RDP (Windows).** Install Tailscale on the Windows PC (Pro, Enterprise, Education, or Server edition, with RDP enabled). From any tailnet device, open an RDP client. Options include the built-in **Remote Desktop Connection**, the **Windows App** on macOS, iOS, and Android, or **Remmina** and **GNOME Connections** on Linux. Enter the PC's Tailscale IP or MagicDNS name in the computer or PC-name field. Port `3389` is never exposed publicly, because the connection rides the encrypted tailnet. Disable key expiry on always-on target machines so they stay reachable.

**RustDesk.** RustDesk normally needs a relay or ID server in the middle to broker connections. Over Tailscale that is unnecessary: devices connect directly, peer-to-peer, with no RustDesk server to run or rely on. In RustDesk, enable **Direct IP access** under Security (set a permanent password for headless machines), then connect to the target's Tailscale IP or MagicDNS name.

**VNC** works the same way. Run the VNC server on the target, then connect the viewer to its Tailscale IP or MagicDNS name.

Restrict who can reach these with tailnet policy. For example, allow only specific users or groups to reach `tcp:3389` on the target tag.

## Where to find current information

### Connection types & how Tailscale connects

| User is asking about… | Fetch |
|---|---|
| Direct vs relayed connection — full taxonomy | https://tailscale.com/docs/reference/connection-types |
| Device connectivity overview | https://tailscale.com/docs/reference/device-connectivity |
| How traffic routes through Tailscale | https://tailscale.com/docs/concepts/traffic-routing-through-tailscale |
| WireGuard background | https://tailscale.com/docs/concepts/wireguard |
| Encryption model | https://tailscale.com/docs/concepts/tailscale-encryption |
| STUN, port mapping, NAT traversal mechanics | https://tailscale.com/docs/reference/stun-protocol |
| WireGuard with dynamic IPs | https://tailscale.com/docs/reference/wireguard-dynamic-ip |

### DERP

| Topic | Fetch |
|---|---|
| DERP servers — purpose, regions, custom DERP | https://tailscale.com/docs/reference/derp-servers |
| Troubleshooting DERP routing | https://tailscale.com/docs/reference/troubleshooting/network-configuration/derp-routing |
| Client message: no DERP connection | https://tailscale.com/docs/reference/messages/client/no-derp-connection |
| Client message: no DERP home | https://tailscale.com/docs/reference/messages/client/no-derp-home |
| Coordination server down | https://tailscale.com/docs/reference/coordination-server-down |
| Coordination-server-issue client message | https://tailscale.com/docs/reference/messages/client/coordination-server-issue |

### Peer relay

| Topic | Fetch |
|---|---|
| Peer relay overview, setup, platform support | https://tailscale.com/docs/features/peer-relay |

### Tailnet Lock

| Topic | Fetch |
|---|---|
| Tailnet Lock — full setup + concepts | https://tailscale.com/docs/features/tailnet-lock |
| Whitepaper (cryptographic design) | https://tailscale.com/docs/concepts/tailnet-lock-whitepaper |

### Connectivity troubleshooting

The troubleshooting docs are organized as a hub with per-platform and per-topic sections. Start at the section that matches the user's symptom, or the hub if unsure, then WebFetch the specific page.

| If the user is troubleshooting… | Fetch |
|---|---|
| Anything, not sure where to start (troubleshooting hub) | https://tailscale.com/docs/reference/troubleshooting |
| First steps for any network problem | https://tailscale.com/docs/reference/troubleshooting/basic-network-troubleshooting |
| Devices can't connect to each other, the internet, or the LAN | https://tailscale.com/docs/reference/troubleshooting/connectivity |
| NAT, routing, DNS, subnet, or IP-conflict issues | https://tailscale.com/docs/reference/troubleshooting/network-configuration |
| Slow throughput to internet destinations | https://tailscale.com/docs/reference/troubleshooting/poor-performance-internet |
| Slow throughput between tailnet devices | https://tailscale.com/docs/reference/troubleshooting/poor-performance-tailnet |
| Can't resolve domain names (MagicDNS/DNS) | https://tailscale.com/docs/reference/troubleshooting/resolve-domain-names-failure |
| A macOS, iOS, or Apple TV problem | https://tailscale.com/docs/reference/troubleshooting/apple |
| A Windows problem | https://tailscale.com/docs/reference/troubleshooting/windows |
| A Linux problem | https://tailscale.com/docs/reference/troubleshooting/linux |
| A mobile (battery, app routing) problem | https://tailscale.com/docs/reference/troubleshooting/mobile |
| A cloud environment problem (AWS/GCP routes, Oracle, subnets) | https://tailscale.com/docs/reference/troubleshooting/cloud |
| A specific hard-NAT problem | https://tailscale.com/docs/reference/troubleshooting/network-configuration/hard-nat-issues |
| CGNAT conflicts (with 100.64/10 ranges) | https://tailscale.com/docs/reference/troubleshooting/network-configuration/cgnat-conflicts |

### Remote desktop

| If the user wants to… | Fetch |
|---|---|
| Remote into a Windows PC (RDP) from elsewhere without exposing it to the internet | https://tailscale.com/docs/solutions/access-remote-desktops-using-windows-rdp |
| Use RustDesk to reach another desktop, without running or paying for a relay server | https://tailscale.com/docs/solutions/access-remote-desktops-with-rustdesk |

### At-home access (client on each device, reach by MagicDNS or 100.x)

These recipes put the Tailscale client on the devices and reach a home service by its MagicDNS name or `100.x` IP, with no ports exposed. (For a device that can't run Tailscale, use a subnet router instead: refer to `references/subnet-routers.md`.)

| If the user wants to… | Fetch |
|---|---|
| Reach their home NAS, Plex/JellyFin, or file shares from anywhere | https://tailscale.com/docs/use-cases/personal-or-at-home-use/access-nas-media-file-servers |
| Block ads across all their devices, even when away from home | https://tailscale.com/docs/solutions/block-ads-all-devices-anywhere-using-raspberry-pi |
| Check a home camera from their phone while out | https://tailscale.com/docs/solutions/set-up-dogcam |

## Answering pattern

For **"why is my connection slow / relayed"** questions, the mental model + NAT matrix + `tailscale ping`/`netcheck` output (refer to `references/cli.md`) is usually enough to diagnose. Fetch the connection-types or troubleshooting pages only when you need exact criteria (for example "what counts as Easy NAT for a specific carrier").

For **peer-relay setup** questions, the inline shape (flag + grant) is enough to start. Fetch the peer-relay page for platform-specific notes and edge cases.

For **Tailnet Lock**, the inline concepts (TLK, TKA, AUM, disablement secrets) are stable. **Always fetch** when the user is about to enable it for real — initial setup has admin-console steps and irreversibility risk (lost disablement secrets) that justify reading the live page.

For **DERP custom deployment**, recommend against it by default; fetch the DERP-servers page if the user has a strong reason and needs the build/operate steps.
