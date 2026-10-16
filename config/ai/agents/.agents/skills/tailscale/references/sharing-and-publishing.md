# Sharing and Publishing

## Taildrop (ad-hoc file transfer)

Taildrop sends files directly between your personal devices over Tailscale — encrypted, peer-to-peer, no third-party servers involved. Currently in public alpha; available on all plans.

### Setup

1. Enable in the admin console: **Settings > General > Send Files**
2. **macOS**: Also enable in System Settings > General > Login Items & Extensions > Sharing (check Tailscale)
3. Other platforms: No extra setup needed

### Usage

**Linux CLI:**
```bash
# Send a file
tailscale file cp report.pdf my-laptop:

# Send multiple files
tailscale file cp *.csv my-desktop:

# Receive files (check for incoming)
tailscale file get .
```

**macOS/Windows**: Right-click a file and choose "Send with Tailscale", then select the target device.

**iOS/Android**: Use the native Share menu and select Tailscale.

### Limitations
- **Personal devices only** — you cannot send files to devices owned by other users, even on the same tailnet
- Cannot use Taildrop with tagged devices
- Both devices must be running Tailscale
- Transfer resume supported on most platforms (except macOS and iOS as receivers)

---

## Taildrive (persistent folder sharing)

Taildrive persistently shares folders with other users and devices on your tailnet. Unlike Taildrop (one-off transfers), Taildrive mounts shared folders that stay accessible. Uses WebDAV under the hood. Currently in alpha (v1.64.0+).

### Setup

#### 1. Enable in the tailnet policy file

An admin must add node attributes to enable sharing and access:

```json
{
  "nodeAttrs": [
    {
      "target": ["autogroup:member"],
      "attr": ["drive:share", "drive:access"]
    }
  ]
}
```

#### 2. Define sharing permissions with grants

```json
{
  "grants": [
    {
      "src": ["group:engineering"],
      "dst": ["tag:nas"],
      "app": {
        "tailscale.com/cap/drive": [{
          "shares": ["*"],
          "access": "rw"
        }]
      }
    }
  ]
}
```

Access can be `"rw"` (read-write) or `"ro"` (read-only). You can restrict to specific share names instead of `"*"`.

#### 3. Share a directory

- **Linux CLI**: Use the Tailscale CLI to share a directory
- **macOS**: Use the GUI in the Tailscale app
- **Windows**: Right-click a folder to share it

#### 4. Access shared folders

Shared folders appear at a globally unique path: `/<tailnet>/<machine>/<share>`

Example: `/example.com/nas-device/docs`

- **macOS/Windows**: Mounted as a network drive
- **Linux**: Mount the WebDAV share (served at `100.100.100.100:8080`)
- **iOS/Android**: Access through the Tailscale app (access only, cannot share)

### Limitations
- Server component only on Linux, macOS, Windows, Synology (iOS/Android can only access, not share)
- Cannot use with shared devices (cross-tailnet sharing)
- Integrates with tailnet access controls and policy file

---

## Tailscale Serve (private service sharing)

Serve exposes a local service to other devices on your tailnet over HTTPS. Only tailnet members can access it.

### Setup

```bash
# Serve a local HTTP service on port 3000
tailscale serve 3000
```

This creates `https://<machine-name>.<tailnet>.ts.net` accessible to tailnet devices. Tailscale handles TLS certificates automatically.

### Requirements
- HTTPS must be enabled in your tailnet (the CLI will prompt you to enable it if needed)

### Features
- **Identity headers**: Serve automatically adds headers to requests: `Tailscale-User-Login`, `Tailscale-User-Name`, `Tailscale-User-Profile-Pic` — your backend can use these for authentication without any extra setup
- Respects tailnet access control rules

### Limitations
- Cannot use the same port for Serve (private) and Funnel (public) simultaneously
- macOS file/directory serving limited to the open-source CLI variant

---

## Tailscale Funnel (public service sharing)

Funnel exposes a local service to the **public internet** — anyone can access it, even without Tailscale. Traffic is routed through Funnel relay servers that hide your IP address while maintaining end-to-end encryption. Currently in beta (v1.38.3+).

### Setup

#### 1. Enable Funnel

```bash
tailscale funnel 3000
```

The CLI will walk you through enabling the required settings (MagicDNS, HTTPS, funnel node attribute) if they aren't already configured.

#### 2. Share your URL

Funnel creates a public URL: `https://<machine-name>.<tailnet>.ts.net`

Anyone on the internet can access it.

### How it works
1. DNS resolves your Funnel URL to a Tailscale relay server (your IP is never exposed)
2. The relay server creates a TCP proxy to your device over Tailscale
3. The relay cannot decrypt the traffic — it's end-to-end encrypted
4. Your device terminates TLS and serves the content

### Requirements
- Tailscale v1.38.3+
- MagicDNS enabled
- HTTPS enabled with valid certificates
- Funnel node attribute in tailnet policy file (auto-configured by CLI)

### Limitations
- **Restricted ports**: Can only listen on 443, 8443, and 10000
- **TLS only**: All connections must be TLS-encrypted
- **Bandwidth limits**: Non-configurable bandwidth limits apply
- **macOS**: Only works with the open-source CLI variant (not App Store or Standalone)
- **Rate limiting**: Frequent certificate requests may exceed Let's Encrypt limits (34-hour wait)
- Cannot use the same port for Serve and Funnel simultaneously

### Serve vs. Funnel

| | Serve | Funnel |
|---|---|---|
| **Audience** | Tailnet members only | Anyone on the internet |
| **Authentication** | Tailscale identity headers | None (public) |
| **Your IP** | Visible to tailnet peers | Hidden behind relay |
| **Ports** | Any | 443, 8443, 10000 only |
| **TLS** | Automatic | Automatic |

## Worked examples

| If the user wants to… | Fetch |
|---|---|
| Let teammates preview a web app running on their laptop, privately | https://tailscale.com/docs/use-cases/application-testing/share-local-dev-server-with-team |
| Put a local development server on the public internet for a demo or webhook | https://tailscale.com/docs/use-cases/application-testing/share-local-dev-server-with-internet |
| Let friends join a game server they host, without a public IP | https://tailscale.com/docs/use-cases/personal-or-at-home-use/share-private-game-server |
| Run a private Minecraft server just for their group | https://tailscale.com/docs/solutions/set-up-minecraft |
| Code from an iPad against a real development environment (VS Code, code-server) | https://tailscale.com/docs/solutions/code-on-ipad-vscode-caddy-code-server |
| Reach a home or lab inference server (Ollama, LM Studio) from other devices | https://tailscale.com/docs/use-cases/ai-infrastructure-access/connect-inference-servers |
| Give a team private access to an AI training cluster | https://tailscale.com/docs/use-cases/ai-infrastructure-access/secure-ai-training-cluster |
