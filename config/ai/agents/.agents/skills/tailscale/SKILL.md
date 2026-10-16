---
name: tailscale
description: >-
  Guide for installing, configuring, and managing Tailscale, headscale, and the
  Tailscale product family. Covers core mesh VPN (exit nodes, subnet routers,
  access controls, SSH, MagicDNS), Docker and Kubernetes integration, CI/CD
  pipelines, ephemeral nodes, infrastructure access, site-to-site networking,
  app connectors, Aperture (AI/LLM gateway for governance, cost control, usage
  visibility), device posture, MDM, SCIM provisioning, SSH and kubectl session
  recording, tsrecorder, Taildrop, Tailscale Serve, Funnel, and building Go
  applications that embed Tailscale via the tsnet library. Use when someone
  asks about Tailscale networking, mesh VPN, VPN replacement, containers,
  Kubernetes operator, CI/CD runners, device management, session recording,
  audit logging, LLM API access, AI cost control, file sharing, exposing
  internal services, or writing a Go program that joins a tailnet as its own
  device — even when they describe the scenario without naming the product.
---

# Tailscale

Tailscale is a zero-config mesh VPN that creates a secure peer-to-peer network (called a **tailnet**) between your devices. It uses WireGuard for encryption and connects devices directly rather than routing through a central gateway.

Beyond the core VPN, Tailscale offers a family of products built on the same identity and networking layer. This skill covers all of them — consult the reference file for whichever topic is relevant.

## How references work

References fall into two shapes depending on what the skill needs to do for the user.

**Descriptive references** (most files — `aperture.md`, `containers.md`, `enterprise.md`, `device-management.md`, `session-recording.md`, `api.md`, `tsnet.md`) help you *describe* a topic to a user: explain it, draft configuration, recommend an approach. These use a hybrid layout — stable mental model and load-bearing configuration shapes inline, plus a curated list of canonical `tailscale.com/docs/...` URLs to **WebFetch for current detail**. Follow the in-file instructions about when to fetch. When WebFetch is available, prefer the live page over the inline summary for specifics (configuration keys, environment variables, supported models, pricing). When WebFetch is unavailable, answer from inline content and tell the user which doc page to consult.

**Operational references** (currently `cli.md`) help you *operate* a tool on the user's machine — Claude actually invokes the commands. These keep concrete command/flag content inline because wrong flags break real systems. The fallback is *local*, not network: run `tailscale help <subcommand>` to verify a flag before suggesting it. The canonical docs URL is the second fallback, for when the tool isn't installed.

The remaining references (`access-control.md`, `common-tasks.md`, `connectivity.md`, `exit-nodes.md`, `installation.md`, `subnet-routers.md`) are smaller and self-contained — read the file, answer the question.

## Core concepts

- **Tailnet**: Your private network of authenticated devices and users.
- **WireGuard**: The encryption protocol underneath Tailscale. Key management is automatic.
- **MagicDNS**: Automatic DNS names for every device (for example, `ssh my-server`).
- **100.x.y.z addresses**: Each device gets a stable Tailscale IP in the CGNAT range.
- **Tailnet policy file**: JSON configuration in the admin console that defines access controls, groups, tags, and SSH rules. Deny-by-default.

## Authoring defaults

When the user asks you to write or edit a tailnet policy file:

- **Use grants, not ACLs.** Grants are Tailscale's recommended way to express access rules. Grants cover what ACLs do (network-layer access) plus application-layer capabilities (Kubernetes, Aperture, tsrecorder, Taildrive) in one form. ACLs are still supported for reading existing policies and migrations, but every new access rule you write should be a grant. Refer to `references/access-control.md` for the conversion pattern and https://tailscale.com/docs/reference/grants-vs-acls for the canonical comparison.
- **The grant-vs-ACL choice only applies to access rules.** Other policy-file sections have their own dedicated syntax and aren't grants: `"ssh"` (SSH access), `"autoApprovers"` (auto-approving advertised routes and exit nodes), `"nodeAttrs"` (node-level attributes like Funnel), `"postures"` (device posture definitions, referenced from grants via `srcPosture`), and the `"groups"`/`"tagOwners"` definitions.

## Quick start

For macOS/Windows, download Tailscale from https://tailscale.com/download.

For iOS, iPadOS, tvOS, Android devices, Roku devices, and Fire TV, install Tailscale through the platform's app store.

Install Tailscale on Linux devices with the installation script:

```bash
curl -fsSL https://tailscale.com/install.sh | sh   # Install (Linux)
sudo tailscale up                                    # Connect
tailscale status                                     # Verify
```

When authenticating with Tailscale, associate user devices with a user account. Use tags and auth keys to add servers and non-user devices to your tailnet.


## Find your task

### "I want to reach my work machines from my personal laptop or phone"

```
Need remote access to work?
├─ My work computers or internal apps → references/common-tasks.md
├─ Remote desktop into my work machine (RDP, VNC) → references/connectivity.md
├─ Replace our old company VPN → references/enterprise.md
└─ A device that can't run Tailscale (printer, camera, cloud VPC) → references/subnet-routers.md
```

### "I'm traveling and want my internet to work like I'm home"

```
Traveling or on Wi-Fi you don't trust?
├─ Protect my traffic on hotel, cafe, or airport Wi-Fi → references/exit-nodes.md
├─ Use my home country's sites and streaming while abroad → references/exit-nodes.md
└─ Set up an exit node for family (the one you mail your parents) → references/exit-nodes.md
```

### "I want to give people access to our servers only when they need it and audit what they did"

```
Need to lock down access?
├─ Access only when it's needed, not standing admin rights → references/access-control.md
├─ A break-glass path for emergencies → references/access-control.md
├─ Record SSH or kubectl sessions → references/session-recording.md
├─ Govern privileged access to servers, databases, and clusters (PAM) → references/border0.md
└─ Reach the Kubernetes API server → references/containers.md
```

### "I want my services and machines to connect securely across networks"

```
Need machines talking to each other?
├─ A CI/CD pipeline that reaches private infra → references/enterprise.md
├─ Kubernetes workloads across clusters or clouds → references/containers.md
├─ Services across more than one cloud → references/enterprise.md
├─ Thousands of field devices (fleets, vehicles, robots) → references/device-management.md
├─ Fix overlapping IPs across sites → references/subnet-routers.md
└─ Link two office networks together (site-to-site) → references/subnet-routers.md
```

### "I want to share a file or app on my machine with someone else"

```
Need to share or open something up?
├─ Send a file to someone's device → references/sharing-and-publishing.md (Taildrop)
├─ Keep a folder synced across my devices → references/sharing-and-publishing.md (Taildrive)
├─ Let a teammate reach an app on my laptop → references/sharing-and-publishing.md (Serve)
└─ Put an app on the public internet → references/sharing-and-publishing.md (Funnel)
```

### "I'm testing an app and need it to reach or look like somewhere else"

```
Testing an app?
├─ Preview a local dev server with teammates or the internet → references/sharing-and-publishing.md
├─ Remote into a desktop (RDP, VNC, RustDesk) → references/connectivity.md
└─ Make test traffic appear to come from another country → references/exit-nodes.md
```

### "Something is broken or I'm seeing an error message"

```
Hit an error or something not working?
├─ A specific error or status message (in the app or admin console) → references/error-messages.md
├─ Devices can't connect, slow/relayed, or DNS/NAT problems → references/connectivity.md
├─ A grant or access rule isn't behaving → references/access-control.md
└─ Kubernetes operator problems → references/containers.md
```

### "I want to run my own LLM and keep it private"

```
Running your own AI?
├─ Reach my home model (Ollama, LM Studio) from my other devices → references/installation.md
├─ Put my home GPU on my tailnet for inference → references/tsnet.md
└─ Open my private chat UI or RAG to just my devices → references/sharing-and-publishing.md (Serve)
```

### "I want to control what our company's AI tools cost and can reach"

```
Governing how your company uses AI?
├─ Centralize and rotate our LLM API keys → references/aperture.md
├─ See cost and usage per person or team → references/aperture.md
├─ Put quotas or budgets on AI spend → references/aperture.md
└─ Control which MCP tools agents are allowed to use → references/aperture.md
```

### "I want to give an AI agent a safe identity to reach tools"

```
Securing AI agents?
├─ Give each agent its own identity on the network → references/tsnet.md
├─ Let agents reach each other across machines → references/tsnet.md
├─ Control exactly which tools and data an agent can reach → references/access-control.md
└─ Fence an agent off so it can only touch what I allow → references/access-control.md
```

### "I want to get to my home computer, files, and media when I'm away"

```
Need to reach home?
├─ Home computers and files → references/installation.md
├─ A headless Pi or home server, with no port forwarding → references/subnet-routers.md
├─ Media or backups (Jellyfin, *arr, Nextcloud) → references/sharing-and-publishing.md
├─ Smart-home gear (Home Assistant, Pi-hole) → references/subnet-routers.md
└─ Remote desktop or game streaming (Moonlight, RDP) → references/connectivity.md
```

### "I want to connect my company's devices securely through our email or SSO"

```
Need everyone connected through SSO?
├─ Provision users from our identity provider (SSO, SCIM) → references/device-management.md
├─ Push Tailscale to managed devices (Jamf, Intune) → references/device-management.md
├─ Require posture or approval before connecting → references/device-management.md
└─ Automate nodes (auth keys, ephemeral nodes, Terraform) → references/enterprise.md
```

### "I'm building an app that needs to reach private resources securely"

```
Building it into your app?
├─ My service needs to reach a private database or API → references/tsnet.md
├─ Give my app its own identity, separate from the host → references/tsnet.md
└─ Serve or publish my app straight from code → references/tsnet.md
```


## Topic index

Read the reference file that matches the user's question. Each file is self-contained.

### Networking & connectivity

| Topic | Reference file | When to read |
|-------|---------------|--------------|
| Installation | `references/installation.md` | Installing Tailscale on any platform, updating, uninstalling |
| Exit nodes | `references/exit-nodes.md` | Routing all internet traffic through a device (VPN-style), travel security |
| Subnet routers | `references/subnet-routers.md` | Reaching devices that can't run Tailscale (printers, cameras, cloud VPCs) |
| Access control | `references/access-control.md` | Grants, ACLs, tags, groups, policy file structure |
| Connectivity | `references/connectivity.md` | Peer relay, DERP servers, NAT traversal, tailnet lock, connection types |
| Common tasks | `references/common-tasks.md` | Tailscale SSH, MagicDNS, auth keys, key expiry |

### Sharing & publishing

| Topic | Reference file | When to read |
|-------|---------------|--------------|
| Sharing & publishing | `references/sharing-and-publishing.md` | Taildrop (file transfer), Taildrive (persistent folder sharing), Tailscale Serve (private), Tailscale Funnel (public) |

### Containers & orchestration

| Topic | Reference file | When to read |
|-------|---------------|--------------|
| Docker & Kubernetes | `references/containers.md` | Running Tailscale in Docker containers, sidecar pattern, Docker Compose, Kubernetes operator, cluster ingress/egress, Connector CRD, ProxyGroup |

### Enterprise & infrastructure

| Topic | Reference file | When to read |
|-------|---------------|--------------|
| Enterprise patterns | `references/enterprise.md` | VPN replacement, infrastructure access, ephemeral nodes, CI/CD integration (GitHub Actions), site-to-site networking, app connectors, auth keys for automation, Terraform provider |
| Device management | `references/device-management.md` | Device approval, device posture, MDM deployment, SCIM user/group provisioning, bulk device operations, enterprise rollout |
| Session recording | `references/session-recording.md` | tsrecorder setup, SSH session recording, S3 storage, Kubernetes kubectl recording, API request recording, failover, audit compliance |
| Border0 (PAM) | `references/border0.md` | Privileged access management, application-aware access, just-in-time access, session recording for SSH/Kubernetes/RDP/VNC/databases, connectors and sockets, credential elimination |

### Building on Tailscale

| Topic | Reference file | When to read |
|-------|---------------|--------------|
| tsnet (Go library) | `references/tsnet.md` | Building a Go application with Tailscale built in, so the app is itself a device on the tailnet; apps that authenticate their users by Tailscale identity with no separate login flow; apps that control access with tags and capability grants managed in the policy file; running several such apps on one host, each with its own identity and access rules; reaching or serving private tailnet services from Go with nothing exposed publicly |

### AI & LLM governance

| Topic | Reference file | When to read |
|-------|---------------|--------------|
| Aperture | `references/aperture.md` | AI gateway, LLM request routing, API key centralization, usage visibility, cost control, quotas, coding agent integration, MCP proxying |

### Reference

| Topic | Reference file | When to read |
|-------|---------------|--------------|
| CLI | `references/cli.md` | Tailscale CLI commands, flags, serve/funnel, file transfer, diagnostics, tailnet lock |
| API | `references/api.md` | Tailscale REST API, authentication, device management, DNS, policy file, webhooks |
| Error & status messages | `references/error-messages.md` | Looking up a specific client or admin-console error/status message (DERP relay, DNS, SSH/SELinux, Docker, Windows, SSO, billing) and its fix |

## CLI quick reference

| Command | What it does |
|---------|-------------|
| `tailscale up` | Connect to your tailnet |
| `tailscale down` | Disconnect |
| `tailscale status` | Show connected devices |
| `tailscale ip` | Show your Tailscale IP addresses |
| `tailscale ping <host>` | Test connectivity to a device |
| `tailscale set --ssh` | Enable Tailscale SSH on this device |
| `tailscale set --advertise-exit-node` | Advertise as an exit node |
| `tailscale set --exit-node=<ip>` | Use a specific exit node |
| `tailscale set --advertise-routes=<cidr>` | Advertise subnet routes |
| `tailscale set --accept-routes` | Accept advertised subnet routes (Linux) |
