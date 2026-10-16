# Error and status messages

Tailscale publishes a documentation page for many of the specific error and status messages a user can hit, in the client (the app or daemon on a device) and in the admin console. When a user quotes a message or a health-check warning, match it to the row below and WebFetch that page for the cause and fix. This is usually faster than diagnosing from scratch.

Two groups: **client messages** (surfaced by the Tailscale app, `tailscale` CLI, or `tailscaled` on a device) and **console messages** (surfaced in the admin console during sign-in or administration).

Hub (fetch when no row matches, or to browse the current set): https://tailscale.com/docs/reference/messages

## Client messages

| If the user sees / reports… | Fetch |
|---|---|
| "Coordination server reports an issue" | https://tailscale.com/docs/reference/messages/client/coordination-server-issue |
| "Could not apply configuration" | https://tailscale.com/docs/reference/messages/client/could-not-apply-config |
| Docker connectivity broken by stateful filtering | https://tailscale.com/docs/reference/messages/client/docker-stateful-filtering |
| "Invalid packet filter" | https://tailscale.com/docs/reference/messages/client/invalid-packet-filter |
| Local log misconfiguration | https://tailscale.com/docs/reference/messages/client/local-log-config-error |
| "MagicSock function not running" | https://tailscale.com/docs/reference/messages/client/magicsock-receive-func-error |
| "Network map response timeout" | https://tailscale.com/docs/reference/messages/client/network-map-response-timeout |
| "Network down" / network status warning | https://tailscale.com/docs/reference/messages/client/network-status |
| Relay server unavailable (no DERP connection) | https://tailscale.com/docs/reference/messages/client/no-derp-connection |
| No home relay server | https://tailscale.com/docs/reference/messages/client/no-derp-home |
| "Out of sync" (not in map poll) | https://tailscale.com/docs/reference/messages/client/not-in-map-poll |
| Linux DNS configuration issue (`resolv.conf` overwritten) | https://tailscale.com/docs/reference/messages/client/resolv-conf-overwritten |
| Tailscale blocked by Screen Time | https://tailscale.com/docs/reference/messages/client/screen-time-controlclient |
| "Security update available" | https://tailscale.com/docs/reference/messages/client/security-update-available |
| Windows network configuration failed | https://tailscale.com/docs/reference/messages/client/set-network-category-failed |
| Tailscale SSH unavailable with SELinux enabled | https://tailscale.com/docs/reference/messages/client/ssh-unavailable-selinux-enabled |
| "Encrypted connection failed" (TLS) | https://tailscale.com/docs/reference/messages/client/tls-connection-failed |
| "Update available" | https://tailscale.com/docs/reference/messages/client/update-available |
| "Using an unstable version" | https://tailscale.com/docs/reference/messages/client/using-unstable-version |

## Console messages

| If the user sees / reports… | Fetch |
|---|---|
| "Your account is not an administrator" | https://tailscale.com/docs/reference/messages/console/account-not-admin |
| Authentication failed while retrieving details from the identity provider (SSO) | https://tailscale.com/docs/reference/messages/console/auth-failed-sso |
| Login name change detected | https://tailscale.com/docs/reference/messages/console/login-name-change |
| Multiple users with the same login | https://tailscale.com/docs/reference/messages/console/multi-user-login |
| "You don't have access to the admin console" | https://tailscale.com/docs/reference/messages/console/no-access |
| "Error 500: no auth service" | https://tailscale.com/docs/reference/messages/console/no-auth-service |
| Organization has restricted joining external tailnets | https://tailscale.com/docs/reference/messages/console/org-has-restrictions |
| "Reached use limit" | https://tailscale.com/docs/reference/messages/console/reached-use-limit |
| "Failed to load sharing information" | https://tailscale.com/docs/reference/messages/console/sharing-failure |

## Answering pattern

1. Match the user's quoted message or health warning to a row. If they paraphrase, match on the symptom (for example "it says something about a relay server" maps to the DERP rows).
2. WebFetch the matching page and give the cause and fix from that page.
3. If nothing matches, WebFetch the hub to check the current set, since Tailscale adds message pages over time.
4. For broader connectivity or platform problems that are not a specific named message, use `references/connectivity.md` (troubleshooting hub and sections) instead.
