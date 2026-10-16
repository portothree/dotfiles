# tsnet — embed Tailscale in a Go program

`tsnet` is a Go library that lets a program join a tailnet as its own device, with its own Tailscale IP, MagicDNS name, and ACL identity. Use it when you want an application, not the machine it runs on, to be a first-class tailnet member. Serving HTTP is the best-known use, but tsnet is a general networking library. It gives your program tailnet-scoped listeners across protocols (TCP, TLS, UDP, SSH), outbound connections and clients, and a full LocalAPI, not just an HTTP server.

Common use cases:

- Run multiple services on one host, each with its own tailnet identity and access rules, like an admin tool and metrics endpoint with separate access controls.
- Expose an internal service over any protocol without opening a public port: plain TCP (`srv.Listen`), TLS/HTTPS with an auto-provisioned Let's Encrypt cert (`srv.ListenTLS(":443")`), UDP (`srv.ListenPacket`), or Tailscale SSH (`srv.ListenSSH`).
- Optionally expose to the public internet via Funnel (`srv.ListenFunnel(":443")`).
- Make outgoing calls to other tailnet devices from inside your binary with `srv.Dial(...)` for any connection or `srv.HTTPClient()` for HTTP. A client-only program can reach private tailnet services with no inbound listener at all.
- Front an external, non-Go backend by advertising it as a Tailscale Service via a reverse proxy (`ListenService` plus `httputil.NewSingleHostReverseProxy`).
- Build serverless or short-lived workers as ephemeral tailnet nodes (`Server.Ephemeral = true`).
- Identify the calling user from the WireGuard identity (`LocalClient.WhoIs`) and authorize via capability grants in the policy file.

> tsnet is **Go-only**. For other languages, run the regular `tailscaled` daemon (often as a sidecar) — refer to `containers.md`.

## Mental model

A `tsnet.Server` is one tailnet node. You set fields on it (hostname, auth, state dir, tags), then call `Start()` — or just call `Listen()` / `HTTPClient()` / `LocalClient()` and they will `Start` implicitly. Each `Server` keeps its own state directory (default: OS user configuration directory, with the `tsnet-<binary>` subdirectory). Run multiple `Server` instances in one process to give one binary multiple tailnet identities — each instance must use a distinct `Dir`.

Listeners are normal `net.Listener` values; the rest of your code can be plain `net/http`, gRPC, raw TCP, Gin, gorilla/mux — anything that accepts a listener.

The **identity story** is unusual and worth internalizing: tsnet apps don't have a sign-in flow. The WireGuard tunnel *is* the identity. In a request handler, `lc.WhoIs(ctx, r.RemoteAddr)` resolves the connecting peer to a tailnet user, node, and capability map — that becomes your authorization basis.

## Hello, tsnet

A minimal HTTP server that joins the tailnet and identifies the caller via `LocalClient.WhoIs`.

```go
// tshello.go
package main

import (
	"crypto/tls"
	"flag"
	"fmt"
	"html"
	"log"
	"net/http"
	"strings"

	"tailscale.com/tsnet"
)

var addr = flag.String("addr", ":80", "address to listen on")

func main() {
	flag.Parse()
	srv := new(tsnet.Server)
	srv.Hostname = "tshello"
	defer srv.Close()

	ln, err := srv.Listen("tcp", *addr)
	if err != nil {
		log.Fatal(err)
	}
	defer ln.Close()

	lc, err := srv.LocalClient()
	if err != nil {
		log.Fatal(err)
	}

	if *addr == ":443" {
		ln = tls.NewListener(ln, &tls.Config{GetCertificate: lc.GetCertificate})
	}

	log.Fatal(http.Serve(ln, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		who, err := lc.WhoIs(r.Context(), r.RemoteAddr)
		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
		fmt.Fprintf(w, "<h1>Hello, world!</h1><p>You are <b>%s</b> from <b>%s</b> (%s)</p>",
			html.EscapeString(who.UserProfile.LoginName),
			html.EscapeString(firstLabel(who.Node.ComputedName)),
			r.RemoteAddr)
	})))
}

func firstLabel(s string) string { s, _, _ = strings.Cut(s, "."); return s }
```

Bootstrap:

```shell
mkdir tshello && cd tshello
go mod init tshello
go get tailscale.com/tsnet
go run .
```

On first run the program logs an auth URL — open it to add the device to your tailnet. Then from any other tailnet device: `curl http://tshello`.

A shorter alternative to the `tls.NewListener` block is `srv.ListenTLS("tcp", ":443")`, which returns a listener already wrapped with an auto-provisioned cert. Use `srv.ListenFunnel("tcp", ":443")` to additionally expose the same listener to the public internet via Funnel.

## Authenticating the app to the tailnet

Four ways to authenticate a `tsnet.Server`, in increasing order of automation:

| Method | Set via | Use when |
|---|---|---|
| Interactive auth URL | (no auth set) | Local development; you're fine clicking a login link on first start |
| **Auth key** | `Server.AuthKey` or `TS_AUTHKEY` environment variable | Most servers and containers — quick to issue and revoke |
| **OAuth client** | `Server.ClientSecret` (+ `Server.AdvertiseTags`) or `TS_CLIENT_SECRET` environment variable | Fleets / long-running deployments where you want scoped, rotatable credentials and auto-minted auth keys |
| **Workload identity (OIDC)** | `Server.ClientID` + `Server.IDToken` or environment variables `TS_CLIENT_ID` + `TS_ID_TOKEN` (+ `Server.AdvertiseTags`), plus a blank import (refer to the workload identity section below) | Running in GCP, Azure, or GitHub Actions and want no static secret. The cloud provider's OIDC token is exchanged for an auth key |

`Server.AuthKey` takes precedence over `TS_AUTHKEY`, which takes precedence over the legacy `TS_AUTH_KEY`. OAuth and workload-identity flows **require** `Server.AdvertiseTags`. The minted auth key is tag-scoped, and untagged tsnet nodes can't be created this way. The OAuth client needs the `auth_keys` write scope and a tag in `AdvertiseTags`.

### Auth key

```go
srv := &tsnet.Server{
	Hostname: "myapp",
	AuthKey:  os.Getenv("TS_AUTHKEY"),
}
```

Generate the key in the admin console (**Settings → Keys**). Recommended settings for a long-running tsnet server: add a tag (such as `tag:myapp`), and **don't** mark ephemeral so the device persists across restarts. For genuinely short-lived workers, set `Server.Ephemeral = true` instead and the device is cleaned up after disconnect.

### OAuth client

```go
srv := &tsnet.Server{
	Hostname:      "myapp",
	ClientSecret:  os.Getenv("TS_CLIENT_SECRET"),
	AdvertiseTags: []string{"tag:myapp"},
}
```

tsnet exchanges the client secret for a short-lived auth key on each `Start`.

### Workload identity (OIDC)

For fleets running in a cloud provider (GCP, Azure, GitHub Actions), exchange the provider's OIDC token for an auth key with no static secret. Workload identity federation is **not linked into tsnet by default**, to keep cloud-provider dependencies out of programs that don't use it. Add a blank import or tsnet silently ignores `ClientID`, `IDToken`, and `Audience` and continues to the next auth method:

```go
import _ "tailscale.com/feature/identityfederation"
```

```go
srv := &tsnet.Server{
	Hostname:      "myapp",
	ClientID:      os.Getenv("TS_CLIENT_ID"),
	IDToken:       os.Getenv("TS_ID_TOKEN"),
	AdvertiseTags: []string{"tag:myapp"},
}
```

Instead of supplying `IDToken` yourself, set `Server.Audience` (or `TS_AUDIENCE`) and tsnet requests the ID token from the cloud provider on your behalf before exchanging it. Refer to workload-identity-federation docs for the automatic cloud token discovery flow.

### Persistent state directory

State (machine key, node key, peer info) lives in `Server.Dir`. Default is the user configuration directory; override it when running as a service or in a container:

```go
srv := &tsnet.Server{
	Hostname: "myapp",
	Dir:      "/var/lib/tsnet-myapp", // must already exist
}
```

If you run multiple `tsnet.Server` instances in one process, each needs its own `Dir`. Losing the directory means the node re-registers as a new device on next start — so for containerized deployments, mount a persistent volume at the state dir (and at any database file your app uses). After the first auth-key boot writes state, subsequent restarts reconnect without needing the auth key.

### Optional but recommended

- `hostinfo.SetApp("myapp")` before `Start()` — surfaces your app name in admin-console `Hostinfo` so operators can identify what's running.
- `srv.Logf = func(string, ...any) {}` — tsnet's default logging is noisy; silence it and add a verbose flag for debugging.
- `srv.Up(ctx)` after `Start()` — blocks until the node is fully online; useful before calling `LocalClient.Status` or starting to serve.
- `srv.ControlURL = "https://control.example.com"` (or `TS_CONTROL_URL`): point at a self-hosted coordination server. Empty falls back to the environment variable, then to Tailscale's default.

## Controlling access via tailnet policy

Because the tsnet node is its own tailnet member, the tailnet policy file governs it like any other device. The recommended pattern is to **tag the node** (rather than tying it to a user identity) and then write grants against the tag.

### Tag the tsnet node

Declare the tag and assign an owner. If the node authenticates with an auth key, the key must be created with this tag selected; if it uses OAuth, the OAuth client owns the tag implicitly.

```json
{
  "tagOwners": {
    "tag:myapp": ["autogroup:admin"]
  }
}
```

### Network access — who can reach the app

Grants are the recommended access primitive (refer to `access-control.md` — don't write new ACLs). Allow `group:engineering` to reach the app on HTTPS:

```json
{
  "grants": [
    {
      "src": ["group:engineering"],
      "dst": ["tag:myapp"],
      "ip":  ["tcp:443"]
    }
  ]
}
```

Restrict the tsnet app's outbound reach (such as only tagged Postgres servers):

```json
{
  "grants": [
    {
      "src": ["tag:myapp"],
      "dst": ["tag:db"],
      "ip":  ["tcp:5432"]
    }
  ]
}
```

### Application-layer access — capability grants

Pure network access is rarely enough — most tsnet apps also have an authorization layer (admin vs. read-only, per-team permissions). **Don't hard-code that in the binary.** Use a **capability grant** with a custom name under your domain (`tailscale.com/cap/<yourapp>`), and read it in the request handler from `WhoIs(...).CapMap`. Operators change roles by editing the policy file, not by redeploying.

Policy file — grant admin to a group:

```json
{
  "grants": [
    {
      "src": ["group:myapp-admins"],
      "dst": ["tag:myapp"],
      "app": {
        "tailscale.com/cap/myapp": [{ "admin": true }]
      }
    }
  ]
}
```

Application code — resolve user and capabilities from the connection:

```go
import (
	"context"

	"tailscale.com/client/local"
	"tailscale.com/tailcfg"
)

const peerCapName = "tailscale.com/cap/myapp"

type myCaps struct {
	Admin bool `json:"admin"`
}

func currentUser(ctx context.Context, lc *local.Client, remoteAddr string) (login string, isAdmin bool, err error) {
	who, err := lc.WhoIs(ctx, remoteAddr)
	if err != nil {
		return "", false, err
	}
	login = who.UserProfile.LoginName
	caps, _ := tailcfg.UnmarshalCapJSON[myCaps](who.CapMap, peerCapName)
	for _, c := range caps {
		if c.Admin {
			isAdmin = true
		}
	}
	return login, isAdmin, nil
}
```

For tagged callers (other tsnet services calling this one), `who.UserProfile.LoginName` returns `"tagged-devices"` rather than a user email. Handle that explicitly if you need machine-to-machine authorization, and consider granting capabilities to the calling tag in the policy file the same way.

## HTTPS, Funnel, and Tailscale Services

`Server.ListenTLS("tcp", ":443")` returns a listener wrapped with a Let's Encrypt cert provisioned via Tailscale's HTTPS feature. The tailnet must have HTTPS enabled (admin console → DNS → HTTPS) before this works. Check at startup rather than blindly opening :443:

```go
status, _ := lc.Status(ctx)
httpsAvailable := status.Self.HasCap(tailcfg.CapabilityHTTPS) && len(srv.CertDomains()) > 0
```

Fall back to plain `Listen` on :80 (or surface a clear error) when HTTPS isn't available. When HTTPS *is* on, the conventional setup is: redirect :80 → :443, wrap the HTTPS handler with HSTS.

`Server.ListenFunnel("tcp", ":443")` exposes the same listener to the public internet via Funnel. Use `tsnet.FunnelOnly()` as an option for a public-only listener if you want to split private and public logic:

```go
publicLn, _  := srv.ListenFunnel("tcp", ":443", tsnet.FunnelOnly())
privateLn, _ := srv.ListenTLS("tcp", ":443")
```

Funnel requires the `funnel` `nodeAttr` in the policy file. Refer to `sharing-and-publishing.md`.

`Server.ListenService("svc:name", tsnet.ServiceModeHTTP{HTTPS: true, Port: 443})` registers the app as a **Tailscale Service** — a stable virtual hostname/VIP that can be backed by one or more tsnet processes. This is the right pattern for ephemeral infrastructure (fly.io, Cloud Run, k8s pods with non-persistent state) where individual node identities come and go but the service identity should stay stable. Requires a tagged node, a service definition, and an auto-approver in the policy file:

```json
{
  "tagOwners":     { "tag:myapp": ["autogroup:admin"] },
  "autoApprovers": { "services": { "svc:myapp": ["tag:myapp"] } }
}
```

`ListenService` returns `tsnet.ErrUntaggedServiceHost` if the node has no tags — surface that as a clear error to the operator. Note that in service mode, the tsnet internal proxy injects identity headers (`Tailscale-User-Login`, `X-Forwarded-For`) on loopback connections; trust them only when the immediate `RemoteAddr` is loopback, and still look up capabilities via `WhoIs` on the forwarded IP for authorization.

Tailscale Services require devices running Tailscale v1.86.0 or later. The returned listener carries the service's `FQDN`, useful for logging the reachable address:

```go
ln, _ := srv.ListenService("svc:my-service", tsnet.ServiceModeHTTP{HTTPS: true, Port: 443})
log.Printf("Listening on https://%v\n", ln.FQDN)
```

To advertise a Service on multiple ports, call `ListenService` once per port. To front a backend that is external to the tsnet program (any non-Go server), serve a reverse proxy on the listener instead of your own handler:

```go
const targetAddress = "1.2.3.4:80" // the backing server

ln, _ := srv.ListenService("svc:my-service", tsnet.ServiceModeHTTP{HTTPS: true, Port: 443})
log.Fatal(http.Serve(ln, httputil.NewSingleHostReverseProxy(&url.URL{
	Scheme: "http",
	Host:   targetAddress,
})))
```

## Useful Server methods

| Method | Purpose |
|---|---|
| `Listen(network, addr)` | Plain `net.Listener` on the tailnet |
| `ListenTLS(network, addr)` | TLS listener with auto-provisioned cert (HTTPS) |
| `ListenFunnel(network, addr, opts...)` | TLS listener exposed publicly via Funnel; `tsnet.FunnelOnly()` for public-only |
| `ListenService(svc, mode)` | Register as a Tailscale Service (stable identity, multi-instance) |
| `ListenSSH(addr)` | Tailscale SSH listener; connections carry peer identity. Needs blank import `_ "tailscale.com/feature/ssh"` or it errors |
| `ListenPacket(network, addr)` | UDP listener returning `net.PacketConn`; network is `udp`/`udp4`/`udp6`, the address needs an explicit IP (from `TailscaleIPs()`) |
| `Dial(ctx, network, addr)` | Outgoing connection from inside the tailnet |
| `HTTPClient()` | `*http.Client` whose transport routes through the tailnet |
| `LocalClient()` | Talks to embedded `tailscaled` — `WhoIs`, `GetCertificate`, `Status`, others. |
| `TailscaleIPs()` | The node's own tailnet IPv4/IPv6 (after `Start`) |
| `Up(ctx)` | Block until the node is online (after `Start`) |
| `CertDomains()` | Domains the node can mint TLS certs for |
| `Start()` / `Close()` | Lifecycle (most methods Start implicitly; always defer Close) |

## Production checklist

1. **Tag the node**, don't run untagged — keeps the device out of users' personal device lists and makes ACLs writable.
2. **Persist `Server.Dir`** on a mounted volume; persist any app database file too. Without this the node re-registers as a new device each restart.
3. **Authenticate with OAuth or workload identity** for fleet deployments — auth keys are fine for single-instance setups but rotate poorly.
4. **Read authorization from `CapMap`**, not from hard-coded user lists. Operators change roles in the policy file, not by redeploying.
5. **Check `status.Self.HasCap(tailcfg.CapabilityHTTPS)`** and `srv.CertDomains()` before serving TLS. Fail explicitly if HTTPS isn't enabled in the tailnet.
6. **For ephemeral hosts** (fly.io, k8s, serverless), prefer `ListenService` — the service identity survives even when individual nodes are recycled.
7. **Defer `srv.Close()`** in `main` so the device cleanly disconnects.

## Where to find current information

| Topic | Fetch |
|---|---|
| tsnet overview & install | https://tailscale.com/docs/features/tsnet |
| Hello tsnet (basic HTTP app) | https://tailscale.com/docs/features/tsnet/how-to/create-basic-tsnet-app |
| Register a tsnet app as a Tailscale Service | https://tailscale.com/docs/features/tsnet/how-to/register-service |
| `tsnet.Server` field/method reference | https://tailscale.com/docs/reference/tsnet-server-api |
| Auth keys (generation, scoping) | https://tailscale.com/docs/features/access-control/auth-keys |
| OAuth clients (for tsnet `ClientSecret`) | https://tailscale.com/docs/features/oauth-clients |
| Workload identity federation (`ClientID`/`IDToken`) | https://tailscale.com/docs/features/workload-identity-federation |
| Userspace networking concepts | https://tailscale.com/docs/concepts/userspace-networking |
| Go pkg.go.dev reference | https://pkg.go.dev/tailscale.com/tsnet |

## Answering pattern

For "how do I build X with tsnet" questions, the inline `Server` shape, the four auth methods, and the tag-based grant + capability pattern are usually enough to write a working program. Match the listener to the protocol the user needs (`Listen` for TCP, `ListenTLS` for HTTPS, `ListenPacket` for UDP, `ListenSSH` for SSH, `Dial`/`HTTPClient` for outbound), and remember the SSH and workload-identity features need their blank imports. WebFetch the `tsnet-server-api` page when the user needs an exact field name (`Server.Ephemeral`, `Server.ControlURL`, `Server.Audience`, `Server.UserLogf`, `Server.RunWebClient`, or others) or behavior detail you're not certain of. That page is the source of truth and grows over time. WebFetch the auth-keys / OAuth pages when the user needs the current admin-console flow.

When the user asks how to expose a tsnet app on the public internet, route them to Funnel (`ListenFunnel`) — refer to `sharing-and-publishing.md`. When they want stable identity across restarts or multiple replicas, point them at `ListenService` and the `register-service` how-to. For app-level authorization, recommend capability grants (`tailscale.com/cap/<yourapp>`) over hard-coded user lists in the binary.
