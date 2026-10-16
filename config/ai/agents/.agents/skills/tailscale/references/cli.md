# Tailscale CLI

The `tailscale` command-line interface manages your device within your tailnet. Available on Linux, macOS, and Windows (no CLI on iOS/Android).

> **This reference exists so agents can drive the CLI directly.** Unlike the other references, the goal here isn't to describe Tailscale to a user — it's to give agents enough to *operate* the binary on the user's machine. Keep two fallbacks in mind, in this order:
>
> 1. **`tailscale help <subcommand>`** — always current, always available if `tailscale` is installed, no network round-trip. Use this when you need a flag or option not listed here, or when an example below fails with an unknown flag (the CLI evolves).
> 2. **https://tailscale.com/docs/reference/tailscale-cli** — the canonical CLI reference page. Fetch when `tailscale help` isn't available, like when explaining a command before installation or when documenting for a user on a different platform).
>
> Before suggesting an unfamiliar flag or subcommand from memory, verify it exists with `tailscale help <command>`.

## CLI location by platform

- **Linux**: `tailscale` is in your `$PATH` after installation
- **macOS (standalone)**: Install CLI integration from Tailscale client **Settings > CLI integration > Install Now** (macOS 13+). Installs to `/usr/local/bin/tailscale`.
- **macOS (App Store)**: CLI is bundled inside the app — run with `/Applications/Tailscale.app/Contents/MacOS/Tailscale <command>`. Set `TAILSCALE_BE_CLI=1` in scripts to force CLI mode.
- **Windows**: `tailscale` is available in Command Prompt / PowerShell after installation

## Connection & authentication

### `tailscale up`

Connect and authenticate your device. On first run, opens a browser for SSO login.

```bash
tailscale up                              # Interactive login
tailscale up --auth-key=tskey-auth-xxxxx  # Headless (servers, CI)
tailscale up --login-server=https://...   # Custom control server
```

Key flags:
- `--auth-key` — Auth key for unattended setup
- `--login-server` — Custom coordination server URL
- `--accept-routes` — Accept subnet routes advertised by others (Linux)
- `--accept-dns` — Accept DNS configuration from the tailnet (default true)
- `--hostname` — Override the machine name
- `--shields-up` — Block all incoming connections (outbound only)
- `--force-reauth` — Force re-authentication even if already logged in
- `--reset` — Reset unspecified settings to default values
- `--advertise-tags` — Request specific tags (must be pre-authorized)
- `--timeout` — Maximum wait time for login (default 0, wait forever)

### `tailscale down`

Disconnect from the tailnet without logging out. The device stays registered.

```bash
tailscale down
```

### `tailscale login` and `tailscale logout`

```bash
tailscale login               # Start login flow (alternative to `up`)
tailscale logout              # Deregister device from tailnet entirely
```

`logout` removes the device from the tailnet. Use `down` to temporarily disconnect.

### `tailscale switch`

Switch between multiple tailnet accounts (Fast User Switching):

```bash
tailscale switch              # List available profiles
tailscale switch <tailnet>    # Switch to a specific profile
```

Profiles are stored locally. You can set a nickname for each profile.

## Status & information

### `tailscale status`

Show all devices on your tailnet with their IPs, hostnames, and connection status:

```bash
tailscale status              # Human-readable table
tailscale status --json       # Full JSON output (for scripting)
tailscale status --peers=false  # Only show this device
```

The `--json` output includes device IDs, public keys, last seen times, and connection details.

### `tailscale ip`

```bash
tailscale ip                  # Show this device's Tailscale IPs (v4 and v6)
tailscale ip -4               # IPv4 only
tailscale ip -6               # IPv6 only
tailscale ip <hostname>       # Show IP of another device
```

### `tailscale whois`

Look up who owns a Tailscale IP address:

```bash
tailscale whois 100.64.1.2    # Shows device owner, hostname, tags
```

### `tailscale version`

```bash
tailscale version             # Client version
tailscale version --daemon    # Daemon version (may differ on some platforms)
```

### `tailscale netcheck`

Check NAT type, UDP connectivity, and DERP relay latency:

```bash
tailscale netcheck
```

Reports: NAT mapping type, port mapping (UPnP/NAT-PMP/PCP), preferred DERP region, and latency to all DERP servers. Useful for diagnosing connectivity issues behind firewalls.

### `tailscale ping`

Test connectivity to a specific device:

```bash
tailscale ping <hostname>     # Ping via Tailscale (TSMP)
tailscale ping --tsmp <host>  # Explicit TSMP ping
tailscale ping --icmp <host>  # ICMP ping through WireGuard tunnel
tailscale ping --peerapi <host>  # HTTP request via peer API
```

Shows whether the connection is direct (peer-to-peer) or relayed through a DERP server.

## Configuration (`tailscale set`)

`tailscale set` modifies device configuration without reconnecting:

```bash
tailscale set --ssh                          # Enable Tailscale SSH server
tailscale set --advertise-exit-node          # Advertise as exit node
tailscale set --exit-node=<ip-or-hostname>   # Use a specific exit node
tailscale set --exit-node=                   # Stop using exit node
tailscale set --advertise-routes=10.0.0.0/24 # Advertise subnet routes
tailscale set --accept-routes                # Accept routes from others (Linux)
tailscale set --hostname=my-server           # Set device hostname
tailscale set --shields-up                   # Block all incoming connections
tailscale set --operator=$USER               # Allow non-root user to manage
tailscale set --auto-update                  # Enable auto-updates
tailscale set --webclient                    # Enable web client interface
tailscale set --advertise-connector          # Advertise as an app connector
tailscale set --exit-node-allow-lan-access   # Allow LAN access while using exit node
```

Most `up` flags are also accepted by `set` (no reconnect required). `tailscale help set` lists the full current set.

## Serve & Funnel

### `tailscale serve`

Expose a local service to your tailnet (private — only tailnet members can access):

```bash
# Proxy local port 3000 over HTTPS on port 443
tailscale serve https / http://localhost:3000

# Serve a local directory
tailscale serve https /docs /path/to/files

# Serve static text
tailscale serve https /health text:"OK"

# TCP forwarding (raw, not HTTPS)
tailscale serve tcp:5432 tcp://localhost:5432

# TLS-terminated TCP
tailscale serve tls-terminated-tcp:5432 tcp://localhost:5432

# Show current serve configuration
tailscale serve status

# Remove a handler
tailscale serve https /docs off

# Reset all serve config
tailscale serve reset
```

Tailscale automatically provisions a TLS certificate for your device's FQDN (`machine.tailnet-name.ts.net`).

### `tailscale funnel`

Like `serve`, but exposes the service to the **public internet** (not just your tailnet):

```bash
# Expose local port 3000 publicly
tailscale funnel https / http://localhost:3000

# Show funnel status
tailscale funnel status

# Turn off funnel
tailscale funnel reset
```

Key differences from serve:
- Funnel traffic routes through Tailscale's servers (not peer-to-peer)
- Available on ports 443, 8443, and 10000 only
- Requires enabling Funnel in the tailnet policy file (`nodeAttr` with `funnel` capability)
- Anyone on the internet can access the URL

## File transfer

### Taildrop (`tailscale file`)

Send and receive files directly between tailnet devices:

```bash
# Send files
tailscale file cp photo.jpg my-laptop:
tailscale file cp *.pdf my-server:

# Receive files (waits for incoming transfers)
tailscale file get /path/to/download/dir
```

### Taildrive (`tailscale drive`)

Share persistent directories between devices:

```bash
tailscale drive share docs /home/user/Documents  # Share a directory
tailscale drive share media /mnt/media            # Share another
tailscale drive list                               # List active shares
tailscale drive rename docs documents              # Rename a share
tailscale drive unshare docs                       # Stop sharing
```

Shared directories are accessible at `\\machine\tailscale\share-name` (Windows) or via WebDAV.

## Network diagnostics

Use these commands together to diagnose connectivity issues:

1. `tailscale status` — Is the device online? What IP does it have?
2. `tailscale ping <host>` — Can you reach it? Is it direct or relayed?
3. `tailscale netcheck` — What's your NAT type? Can you do UDP?
4. `tailscale status --json` — Full details for scripting/debugging

### `tailscale nc`

Netcat-like tool for testing TCP connections through Tailscale:

```bash
tailscale nc <hostname> <port>
```

### `tailscale dns`

Query Tailscale DNS:

```bash
tailscale dns status          # Show DNS configuration
tailscale dns query <name>    # Look up a name via Tailscale DNS
```

## Security

### `tailscale lock`

Manage Tailnet Lock (requires devices to be signed by trusted keys):

```bash
tailscale lock init                 # Initialize tailnet lock
tailscale lock status               # Check lock status
tailscale lock add <node-key>       # Add a trusted signing key
tailscale lock remove <node-key>    # Remove a signing key
tailscale lock sign <node-key>      # Sign a node's key
tailscale lock disable <secret>     # Disable tailnet lock (emergency)
tailscale lock revoke-keys          # Revoke compromised keys
tailscale lock log                  # View lock audit log
tailscale lock local-disable        # Disable locally (this node only)
```

### `tailscale cert`

Provision TLS certificates for your device's Tailscale FQDN:

```bash
tailscale cert machine.tailnet-name.ts.net
```

Creates `.crt` and `.key` files. Certificates are automatically renewed. Useful for services that need HTTPS (web servers, databases).

## Administration

### `tailscale update`

```bash
tailscale update              # Check for and apply updates
tailscale update --check      # Check only, don't install
tailscale update --yes        # Auto-confirm update
tailscale update --track=stable  # Switch release track (stable/unstable)
```

### `tailscale bugreport`

Generate a diagnostic report for Tailscale support:

```bash
tailscale bugreport           # Prints a bug report ID
```

### `tailscale configure`

Platform-specific configuration helpers:

```bash
tailscale configure kubeconfig <hostname>   # Set up kubectl via Tailscale
tailscale configure synology                # Configure Synology NAS
```

### `tailscale metrics`

```bash
tailscale metrics             # Prometheus-format metrics
tailscale metrics print       # Human-readable metrics
```

### `tailscale syspolicy`

View managed system policies (MDM-set values):

```bash
tailscale syspolicy list      # Show all managed policies
tailscale syspolicy reload    # Reload policies from MDM
```

## Tab completion

```bash
tailscale completion bash     # Bash completions
tailscale completion zsh      # Zsh completions
tailscale completion fish     # Fish completions
tailscale completion powershell  # PowerShell completions
```

Install tab completion permanently:

```bash
# Bash (Linux)
tailscale completion bash > /etc/bash_completion.d/tailscale

# Zsh
tailscale completion zsh > "${fpath[1]}/_tailscale"

# Fish
tailscale completion fish > ~/.config/fish/completions/tailscale.fish
```

## Operating the CLI

When driving `tailscale` on the user's machine, prefer these patterns:

**Verify before guessing.** If an example below fails with an unknown flag, the CLI version may differ from this reference. Run `tailscale help <subcommand>` to review the current flag set rather than retrying the same flag.

**Prefer machine-readable output.** For any decision logic (selecting a device, checking online status, finding a peer's IP), use `tailscale status --json | jq ...` rather than parsing the human-readable table. The JSON shape is stable; the table format isn't guaranteed to be.

**Resolve hostnames instead of hard-coding IPs.** `tailscale ip <hostname>` returns the current Tailscale IP for a peer — use it instead of pasting `100.x.y.z` from earlier output. Hostnames are stable; IPs can change on re-auth.

**Confirm before destructive actions.** `tailscale logout` unregisters the device (different from `down`); `tailscale lock disable` requires the recovery secret and weakens the tailnet's security; `tailscale set --reset` reverts unspecified flags to defaults. Check the user's intent before running these.

**Diagnostics flow** (eval-tested pattern for connectivity questions):

```bash
tailscale status              # Is the device online and which peers are visible?
tailscale ping <hostname>     # Is the path direct (p2p) or relayed via DERP?
tailscale netcheck            # NAT type, UDP reachability, DERP latencies
tailscale status --json       # Full machine-readable state for deeper analysis
```

A DERP-relayed connection in `ping` output usually means UDP is blocked end-to-end or one side is behind a strict NAT — `netcheck` confirms which.

**Privilege considerations.** Most `tailscale set` and `tailscale up` invocations need root on Linux (or membership in the `tailscale` operator group set via `tailscale set --operator=$USER`). On macOS/Windows, the GUI client typically owns the daemon; CLI changes may require elevated permission depending on platform.

**When the CLI isn't installed.** If `tailscale` isn't on `$PATH`, don't fabricate output — tell the user, and either fetch `/docs/reference/tailscale-cli` for documentation purposes or point them at `references/installation.md` for setup.
