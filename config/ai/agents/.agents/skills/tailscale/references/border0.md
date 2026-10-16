# Border0 by Tailscale

Border0 by Tailscale is a next-generation **Privileged Access Management (PAM)** solution built on the Tailscale platform. It provides application-aware, identity-based, auditable access to Linux servers, databases, Kubernetes clusters, HTTP services, and more in your tailnet.

> **Border0 is in beta and its docs change frequently.** Treat the summary below as orientation. For setup steps, requirements, and specifics — **WebFetch the matching docs page** from the table below before answering. Product-specific configuration (sockets, connectors, policies) lives on the separate Border0 site, `https://docs.border0.com`.

## How it differs from the rest of Tailscale

Border0 uses the **same identity layer and WireGuard encryption** as Tailscale — no new identity provider or passwords to manage. What it adds on top of the tailnet:

- **Application-aware access.** Instead of "can this IP reach this server", policy is "can this person run this SSH command, query this database, or use this Kubernetes resource". Access is scoped to the application, not the whole host.
- **No shared or static credentials.** Upstream credentials are held by Border0 (optionally in a secret store); users authenticate with their Tailscale identity, re-checked on every connection.
- **Just-in-time, time-bound access.** Access is granted when needed, for the right user and resource, then revoked — rather than standing broad privilege.
- **Session auditing and recording.** Session logs, approvals, and recordings (where applicable) so you can prove who did what, when.
- **Browser or client access.** Users reach resources either through the Tailscale client on their device, or a browser at `https://tailscale.client.border0.com` with no client installed.

## Border0 vs. tsrecorder

Both record privileged sessions, so users comparing them need clear guidance:

- **`tsrecorder`** ([session-recording](session-recording.md)) records **Tailscale SSH and `kubectl`** sessions to a recorder node in the tailnet. It is the current, generally-available method for those two session types.
- **Border0** records **more session types — SSH, Kubernetes, RDP, VNC, and databases** — with command/query-level visibility, as part of a broader PAM platform. It is in beta.

For a *new* session-recording deployment where the user needs more than SSH/`kubectl`, or wants PAM features (JIT access, approvals, credential elimination), point them at Border0. For SSH/`kubectl` recording today, `tsrecorder` is the established path.

## Core concepts

- **Connector** — a device (Linux, AWS EC2, Docker, or Kubernetes) that you register in the Border0 portal. It has Tailscale functionality built in and automatically joins your tailnet. It brokers access to the resources behind it.
- **Socket** — Border0's application-aware proxy for a single resource (an SSH server, a database, a Kubernetes cluster, an HTTP service). "Socket" is the unit you secure and grant access to.
- **Two consoles (initial release).** Setup currently spans **both** the Tailscale admin console (enable the integration) **and** the Border0 portal (`portal.border0.com`, create connectors and sockets).

## Getting access

Border0 is enabled per-tailnet under **Settings > Feature previews > Border0 by Tailscale (Beta)** in the Tailscale admin console (requires Owner, Admin, or IT admin). Availability is gated — free trial via the PAM waitlist, or through Tailscale Sales for organizations.

## Where to find current information — fetch these

| User is asking about… | Fetch |
|---|---|
| What Border0 is, PAM concepts, use cases | https://tailscale.com/docs/border0/what-is-border0 |
| Enabling Border0, connectors, sockets, first setup | https://tailscale.com/docs/border0/get-started |
| Border0 overview / hub | https://tailscale.com/docs/border0 |
| Border0 architecture & key concepts (Border0 site) | https://docs.border0.com/docs/architecture-and-concepts |
| Securing a specific resource — SSH, databases, Kubernetes, HTTP (Border0 site) | https://docs.border0.com |

## Answering pattern

1. For "what is it / should I use it / how does it compare" questions, the summary above is usually enough — and steer session-recording comparisons against [session-recording](session-recording.md).
2. For enabling Border0 or configuring connectors and sockets, WebFetch the get-started page (and the Border0 site for per-resource specifics), then quote steps and requirements verbatim.
3. Border0 is beta and its setup flow (two consoles, feature-preview toggle) is changing — don't assert exact UI steps from memory; fetch first.
