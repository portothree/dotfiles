# Docker and Kubernetes

Tailscale runs inside containers via the `tailscale/tailscale` image, and inside Kubernetes via the Tailscale Operator. Both let containers/pods join your tailnet for secure access without exposing public ports.

> The **Kubernetes operator** docs live in their own sub-trees under `/docs/kubernetes-operator/`. The shapes below are stable; **WebFetch the matching page** for current CRD fields, annotations, OAuth scope names, and supported versions before committing configuration.

## Docker

### Mental model

A Tailscale container joins your tailnet just like any other device. The two common deployment patterns:

- **Standalone** — one container per host, exposes its own Tailscale IP/hostname.
- **Sidecar** — Tailscale runs alongside another container with `network_mode: service:tailscale`; the app is reachable on Tailscale's network.

State must persist across restarts (`TS_STATE_DIR` mounted to a volume) or each restart creates a new device.

### Standalone container

```bash
docker run -d \
  --name=tailscale \
  --hostname=my-container \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --device=/dev/net/tun \
  -e TS_AUTHKEY=tskey-auth-xxxxx \
  -e TS_STATE_DIR=/var/lib/tailscale \
  -e TS_USERSPACE=false \
  -v tailscale-state:/var/lib/tailscale \
  tailscale/tailscale:latest
```

### Docker Compose sidecar

```yaml
services:
  tailscale:
    image: tailscale/tailscale:latest
    hostname: my-app
    cap_add: [NET_ADMIN, NET_RAW]
    devices: ["/dev/net/tun"]
    environment:
      - TS_AUTHKEY=tskey-auth-xxxxx
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=false
    volumes:
      - tailscale-state:/var/lib/tailscale

  my-app:
    image: my-app:latest
    network_mode: service:tailscale
    depends_on: [tailscale]

volumes:
  tailscale-state:
```

With `network_mode: service:tailscale`, `my-app` is reachable via the Tailscale container's IP and MagicDNS name. Works the same with Podman / Colima / Portainer.

### Common environment variables (verify full list against docs)

- `TS_AUTHKEY` — auth key (append `?ephemeral=true` for short-lived containers; device auto-removes ~30–60 min after exit).
- `TS_HOSTNAME` — custom hostname.
- `TS_USERSPACE` — `false` for kernel-mode networking (faster; needs `NET_ADMIN`/`NET_RAW` + `/dev/net/tun`).
- `TS_ROUTES` — advertise subnet CIDRs.
- `TS_STATE_DIR` — state path (mount as volume).
- `TS_SERVE_CONFIG` — JSON configuration for Serve/Funnel.
- `TS_TAILNET_TARGET_IP` / `TS_TAILNET_TARGET_FQDN` — proxy non-tailnet traffic to a tailnet device.
- `TS_CLIENT_ID` / `TS_CLIENT_SECRET` — OAuth credentials instead of auth keys.

### Docker — where to find current information

| Topic | Fetch |
|---|---|
| Docker overview | https://tailscale.com/docs/features/containers/docker |
| Image parameters / environment variable reference | https://tailscale.com/docs/features/containers/docker/docker-params |
| Image components | https://tailscale.com/docs/features/containers/docker/docker-components |
| Docker Desktop integration | https://tailscale.com/docs/features/containers/docker/docker-desktop |
| Connect a standalone container | https://tailscale.com/docs/features/containers/docker/how-to/connect-docker-standalone |
| Connect via Docker manager (Portainer etc.) | https://tailscale.com/docs/features/containers/docker/how-to/connect-docker-alt-manager |
| Sidecar pattern (`network_mode: service:tailscale`) | https://tailscale.com/docs/features/containers/docker/how-to/connect-docker-container |
| LXC (unprivileged) | https://tailscale.com/docs/features/containers/lxc/lxc-unprivileged |

---

## Kubernetes Operator

The operator manages Tailscale integration at the cluster level through custom resources. It runs proxy `StatefulSet`s and handles authentication via an OAuth client tied to a tag (typically `tag:k8s-operator`).

### Mental model

Four primary capabilities, each with its own CRDs and patterns:

1. **Ingress** — expose Kubernetes Services to the tailnet (or the public internet via Funnel). Use Service `LoadBalancer` with `loadBalancerClass: tailscale`, the `tailscale.com/expose: "true"` annotation, or an `Ingress` resource with `ingressClassName: tailscale`.
2. **Egress** — let pods reach tailnet services. Use `ExternalName` services with the `tailscale.com/tailnet-fqdn` annotation, or target a tailnet IP behind a subnet router.
3. **Connector** — runs subnet routers, exit nodes, and app connectors inside the cluster via the `Connector` CRD.
4. **API server access** — expose the K8s API server over Tailscale for secure `kubectl` (auth mode integrates with RBAC; noauth mode delegates to external IdPs).

Operators and proxies should run the **same version** (within ~4 minor versions). State is stored in Kubernetes Secrets by default. TLS for Ingress is auto-provisioned (90-day, auto-renewed).

### Canonical install (Helm)

```bash
helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update

helm upgrade --install tailscale-operator tailscale/tailscale-operator \
  --namespace=tailscale --create-namespace \
  --set-string oauth.clientId="<CLIENT_ID>" \
  --set-string oauth.clientSecret="<CLIENT_SECRET>" \
  --wait
```

OAuth client needs `write` scope on devices, auth keys, and services, all scoped to the operator's tag. Tag setup in the tailnet policy file:

```json
"tagOwners": {
  "tag:k8s-operator": [],
  "tag:k8s": ["tag:k8s-operator"]
}
```

Exact scope names may shift — verify against the install page below.

### Canonical CRD shapes

These are skeletons; field names occasionally change. Fetch the relevant page before applying.

**Expose a Service to the tailnet** (LoadBalancer):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  loadBalancerClass: tailscale
  selector: {app: my-app}
  ports: [{port: 80}]
```

**Egress to a tailnet host:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
  annotations:
    tailscale.com/tailnet-fqdn: prod-db.example.ts.net
spec:
  type: ExternalName
  externalName: placeholder
```

**Connector (subnet router or app connector):**

```yaml
apiVersion: tailscale.com/v1alpha1
kind: Connector
metadata: {name: cluster-cidrs}
spec:
  hostnamePrefix: k8s-router
  subnetRouter:
    advertiseRoutes: ["10.40.0.0/14"]
```

**ProxyGroup (HA — multiple proxy replicas):**

```yaml
apiVersion: tailscale.com/v1alpha1
kind: ProxyGroup
metadata: {name: ha-proxies}
spec:
  type: egress
  replicas: 3
```

### Kubernetes operator — where to find current information

| User is asking about… | Fetch |
|---|---|
| Operator overview | https://tailscale.com/docs/kubernetes-operator |
| Quickstart | https://tailscale.com/docs/kubernetes-operator/quickstart |
| Install (Helm + OAuth + tags) | https://tailscale.com/docs/kubernetes-operator/install-operator |
| Concepts index | https://tailscale.com/docs/kubernetes-operator/concepts |
| Architecture | https://tailscale.com/docs/kubernetes-operator/concepts/architecture |
| DNSConfig CRD | https://tailscale.com/docs/kubernetes-operator/concepts/dnsconfig |
| ProxyClass CRD (per-proxy configuration) | https://tailscale.com/docs/kubernetes-operator/concepts/proxyclass |
| ProxyGroup CRD (HA proxies) | https://tailscale.com/docs/kubernetes-operator/concepts/proxygroup |
| Ingress overview | https://tailscale.com/docs/kubernetes-operator/ingress |
| Expose to internet (Funnel) | https://tailscale.com/docs/kubernetes-operator/ingress/expose-workload-to-internet |
| Expose to tailnet (L3) | https://tailscale.com/docs/kubernetes-operator/ingress/expose-workload-to-tailnet-l3 |
| Expose to tailnet (L7 / Ingress) | https://tailscale.com/docs/kubernetes-operator/ingress/expose-workload-to-tailnet-l7 |
| Multi-cluster ingress | https://tailscale.com/docs/kubernetes-operator/ingress/multi-cluster |
| Multi-cluster service mirroring | https://tailscale.com/docs/kubernetes-operator/ingress/multi-cluster-service-mirroring |
| Egress overview | https://tailscale.com/docs/kubernetes-operator/egress |
| Access a tailnet service from pods | https://tailscale.com/docs/kubernetes-operator/egress/access-tailnet-service |
| Access IP behind a subnet router | https://tailscale.com/docs/kubernetes-operator/egress/access-ip-behind-subnet-router |
| Expose RDS / cloud DB to tailnet | https://tailscale.com/docs/kubernetes-operator/egress/expose-rds-to-tailnet |
| MagicDNS resolution from pods | https://tailscale.com/docs/kubernetes-operator/egress/enable-magicdns-resolution |
| API server proxy — overview | https://tailscale.com/docs/kubernetes-operator/api-server-access |
| API server proxy — auth + RBAC | https://tailscale.com/docs/kubernetes-operator/api-server-access/auth-and-rbac |
| API server proxy — noauth mode | https://tailscale.com/docs/kubernetes-operator/api-server-access/noauth-mode |
| API server proxy — setup over Tailscale | https://tailscale.com/docs/kubernetes-operator/api-server-access/setup-api-over-tailscale |
| Connector overview | https://tailscale.com/docs/kubernetes-operator/connector |
| Deploy app connector | https://tailscale.com/docs/kubernetes-operator/connector/deploy-app-connector |
| Deploy subnet router | https://tailscale.com/docs/kubernetes-operator/connector/deploy-subnet-router |
| Recorder (tsrecorder in cluster) | https://tailscale.com/docs/kubernetes-operator/recorder |
| Deploy tsrecorder | https://tailscale.com/docs/kubernetes-operator/recorder/deploy-tsrecorder |
| Kubectl session recording | https://tailscale.com/docs/kubernetes-operator/recorder/kubectl-session-recording |
| Manage & configure index | https://tailscale.com/docs/kubernetes-operator/manage-and-configure |
| Static endpoints | https://tailscale.com/docs/kubernetes-operator/manage-and-configure/configure-static-endpoints |
| Custom machine names | https://tailscale.com/docs/kubernetes-operator/manage-and-configure/custom-machine-names |
| Debug endpoints | https://tailscale.com/docs/kubernetes-operator/manage-and-configure/enable-debug-endpoints |
| Expose metrics | https://tailscale.com/docs/kubernetes-operator/manage-and-configure/expose-metrics |
| High availability | https://tailscale.com/docs/kubernetes-operator/manage-and-configure/high-availability |
| Multi-tailnet (one cluster, multiple tailnets) | https://tailscale.com/docs/kubernetes-operator/manage-and-configure/multi-tailnet |
| ProxyGroup policy | https://tailscale.com/docs/kubernetes-operator/manage-and-configure/proxy-group-policy |
| Workload identity federation | https://tailscale.com/docs/kubernetes-operator/manage-and-configure/workload-identity-federation |
| Reference index | https://tailscale.com/docs/kubernetes-operator/reference |
| Version compatibility | https://tailscale.com/docs/kubernetes-operator/reference/compatibility |
| IPv6 support | https://tailscale.com/docs/kubernetes-operator/reference/ipv6 |
| Limitations (EKS Fargate etc.) | https://tailscale.com/docs/kubernetes-operator/reference/limitations |
| RBAC permissions | https://tailscale.com/docs/kubernetes-operator/reference/rbac |
| Tag setup | https://tailscale.com/docs/kubernetes-operator/reference/tags |
| Troubleshooting | https://tailscale.com/docs/kubernetes-operator/reference/troubleshooting |
| **Anything else / topic not listed** | https://tailscale.com/docs/kubernetes-operator |

## Worked examples

| If the user wants to… | Fetch |
|---|---|
| Connect a pod to the tailnet with a sidecar container | https://tailscale.com/docs/solutions/connect-kubernetes-pods-to-tailnet-using-sidecar |
| Manage deployments across many clusters with ArgoCD | https://tailscale.com/docs/solutions/manage-multi-cluster-kubernetes-deployments-argocd |
| Sync secrets across clusters (External Secrets Operator) | https://tailscale.com/docs/solutions/sync-kubernetes-secrets-across-clusters-external-secrets |
| Expose services with custom domains via the Gateway API | https://tailscale.com/docs/solutions/kubernetes-operator-byod-gateway-api |

## Answering pattern

For Docker: the inline patterns are usually enough. Fetch the docs only when the user needs a specific environment variable, image variant, or platform-specific quirk.

For Kubernetes: the operator surface is large and reorganized recently. Match the user's question to a row above, WebFetch that page, and quote CRD fields, annotation names, and Helm values verbatim from the fetched content. Don't invent CRD fields from memory — they change.
