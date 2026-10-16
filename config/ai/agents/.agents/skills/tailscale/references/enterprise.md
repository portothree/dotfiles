# Enterprise and Infrastructure

This reference covers the patterns Tailscale is used for at organizational scale: VPN replacement, ephemeral CI/CD access, site-to-site networking, app connectors, auth-key automation, and Terraform-as-code.

> Several of these topics have their own dedicated docs trees and change independently. The shapes below are stable; **WebFetch the matching page** for current OAuth scope names, flag defaults, Terraform resource fields, and platform-specific architecture guidance before applying configuration.

## Mental model

Tailscale replaces traditional VPN/bastion/jump-host infrastructure with identity-authenticated peer-to-peer connections. The enterprise patterns that build on this core:

- **Infrastructure access** — direct peer connections + ACL grants by group/tag; no public IPs or open ports required. Identity comes from your IdP (Okta, Entra, Google Workspace, others.).
- **Ephemeral nodes** — short-lived devices that auto-remove after ~30–60 min idle. Used for CI runners, containers, serverless. Created via ephemeral auth keys or OAuth clients with `?ephemeral=true`.
- **CI/CD integration** — the `tailscale/github-action` adds an ephemeral, tagged node to a GitHub Actions runner for the duration of the workflow. Recommended auth method is workload identity federation (no long-lived secrets).
- **Site-to-site** — Linux subnet routers on each network advertise CIDRs into the tailnet; SNAT must be disabled for bidirectional traffic. Also refer to `references/subnet-routers.md`.
- **App connectors** — DNS-based routing (instead of CIDR-based) to SaaS apps and cloud-managed services. Useful for predictable egress IPs and IP allowlists at SaaS providers.
- **Auth keys** — non-interactive device authentication. Combine flags as needed: `reusable` × `ephemeral` × `preapproved` × `tagged`. Default expiry 90 days, max 90.
- **Terraform provider** — `tailscale_key`, `tailscale_acl`, `tailscale_dns_*`, and device resources for managing the tailnet as code.

Most enterprise patterns are wired up in the tailnet policy file via groups (humans), tags (machines/services), and grants. Refer to `references/access-control.md` for grant/group/tag syntax in depth.

## Canonical shapes

### GitHub Actions workflow (ephemeral + tagged)

```yaml
name: Deploy
on: push
permissions:
  id-token: write   # required for workload identity federation
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: tailscale/github-action@v4
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci

      - run: |
          export DATABASE_URL="postgresql://user:pass@prod-db.example.ts.net:5432/myapp"
          npm run migrate
```

The node auto-removes when the workflow ends. The OAuth client must be scoped to the same tag (`tag:ci`) so it can mint auth keys for that tag. For zero-secret setups, switch to workload identity federation — same action, different `with:` fields. Fetch the GitHub Action page for the current set.

### Ephemeral auth key (CLI use)

```bash
# Create in admin console: Settings > Keys > Ephemeral + Tagged + Reusable
sudo tailscale up --auth-key=tskey-auth-xxxxxxx
```

Tagged ephemeral keys are the right default for containers, CI, and serverless. Reuse the same key across many instances; nodes auto-remove after exit.

### Site-to-site subnet router (Linux)

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# --snat-subnet-routes=false preserves source IPs so the remote site can reply
sudo tailscale up \
  --advertise-routes=192.168.1.0/24 \
  --snat-subnet-routes=false \
  --accept-routes
```

CIDRs must not overlap between sites. Each site needs return routes (set on devices or upstream router) pointing at the Tailscale subnet router for the remote CIDR.

### Terraform — ephemeral CI key + grant

```hcl
resource "tailscale_key" "ci_key" {
  reusable      = true
  ephemeral     = true
  preauthorized = true
  tags          = ["tag:ci"]
  expiry        = 3600
}

resource "tailscale_acl" "policy" {
  acl = jsonencode({
    grants = [{
      src = ["tag:ci"]
      dst = ["tag:staging"]
      ip  = ["*:*"]
    }]
  })
}
```

The provider also manages DNS, devices, posture integrations, and OAuth clients — check the provider docs for the current resource set.

### OAuth client (programmatic device provisioning)

OAuth clients are tag-scoped credentials that mint short-lived auth keys. Used by the GitHub Action, the Kubernetes operator, Terraform, and `aperture-cli`-style tooling. Append `?ephemeral=true` to the secret when minting ephemeral nodes from automation. Scopes are tag-restricted (the client can only operate on tags it owns).

## Where to find current information

| User is asking about… | Fetch |
|---|---|
| Ephemeral nodes — concept and configuration | https://tailscale.com/docs/features/ephemeral-nodes |
| OAuth clients — scopes, secret handling, ephemeral flag | https://tailscale.com/docs/features/oauth-clients |
| Running Tailscale unattended (servers, daemons) | https://tailscale.com/docs/how-to/run-unattended |
| GitHub Actions integration | https://tailscale.com/docs/integrations/github/github-action |
| GitHub Codespaces integration | https://tailscale.com/docs/integrations/github/github-codespaces |
| GitOps with Tailscale | https://tailscale.com/docs/integrations/github/gitops |
| GitHub as identity provider | https://tailscale.com/docs/integrations/identity/github |
| CI/CD recipe — connect Actions to private infra | https://tailscale.com/docs/solutions/connect-github-CICD-workflows-to-private-infrastructure-without-public-exposure |
| Terraform provider | https://tailscale.com/docs/integrations/terraform-provider |
| Site-to-site overview | https://tailscale.com/docs/features/site-to-site |
| Site-to-site via subnet routers (reference doc) | https://tailscale.com/docs/reference/subnet-site-to-site |
| App connectors — overview | https://tailscale.com/docs/features/app-connectors |
| App connectors — setup recipe | https://tailscale.com/docs/features/app-connectors/how-to/setup |
| App connectors — best practices | https://tailscale.com/docs/reference/best-practices/app-connectors |
| App connectors on Kubernetes (Connector CRD) | https://tailscale.com/docs/kubernetes-operator/connector/deploy-app-connector |
| Deployment checklist (production rollout) | https://tailscale.com/docs/reference/deployment-checklist |
| Reference architecture — AWS | https://tailscale.com/docs/reference/reference-architectures/aws |
| Reference architecture — Azure | https://tailscale.com/docs/reference/reference-architectures/azure |
| Reference architecture — GCP | https://tailscale.com/docs/reference/reference-architectures/gcp |
| Migrating from legacy VPN | https://tailscale.com/docs/solutions/migrate-legacy-vpn-tailscale |
| Migrating from OpenVPN | https://tailscale.com/docs/solutions/migrate-openvpn-tailscale |
| API server proxy (no-auth mode for IdP delegation) | https://tailscale.com/docs/kubernetes-operator/api-server-access/noauth-mode |

## Worked examples

| If the user wants to… | Fetch |
|---|---|
| Give employees secure access to internal corporate apps and data (VPN replacement) | https://tailscale.com/docs/use-cases/vpn-replacement/secure-access |
| Reach resources spread across multiple clouds or regions | https://tailscale.com/docs/use-cases/infrastructure-access/access-multi-cloud-or-multi-region-cloud-envs |
| Present a fixed egress IP that a partner or regulated system can add to an allowlist | https://tailscale.com/docs/use-cases/regulated-environment/static-egress-ip-allowlist |
| Connect to MongoDB Atlas (or similar SaaS) through a predictable IP | https://tailscale.com/docs/solutions/create-a-secure-connection-to-mongodb-atlas |

## Answering pattern

For CI/CD questions, the inline workflow + OAuth-client mental model is usually enough; fetch the `github-action` or `oauth-clients` page only when the user needs a specific input field, scope name, or workload identity federation specifics.

For **architectural** questions (like "How should we deploy across three AWS accounts and a GCP project?"), always fetch the relevant reference architecture page — these are the documents most likely to drift as Tailscale's recommended patterns evolve, and they're load-bearing for production decisions.

For **migration** questions (from OpenVPN, Cisco AnyConnect, others), fetch the matching `solutions/migrate-*` page; the inline mental model is too generic.

For Terraform: fetch the provider page rather than recalling resource fields from memory — the provider gains and renames resources frequently.
