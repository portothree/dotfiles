# Session Recording

Tailscale records two kinds of sessions to a **`tsrecorder`** node in your tailnet:

1. **Tailscale SSH sessions** — terminal output (stdout/stderr) from Tailscale SSH connections.
2. **Kubernetes sessions via the operator** — `kubectl exec` / `attach` / `debug` / `run`, plus (optionally) all Kubernetes API requests.

Both ride on the same recorder image. Output is written in `asciinema` format (`.cast`, newline-delimited JSON — grep-able and replayable).

> **Recording more than SSH/`kubectl`?** `tsrecorder` covers Tailscale SSH and `kubectl` sessions. For RDP, VNC, or database session recording, or full privileged-access-management (JIT access, approvals, credential elimination), refer to [Border0 by Tailscale](border0.md). For SSH/`kubectl` recording today, `tsrecorder` is the established path.

> The Kubernetes recorder docs live under `/docs/kubernetes-operator/recorder/` **WebFetch the matching page** for current CRD fields, flag names, and IAM/IRSA specifics before applying configuration.

## Mental model

- A `tsrecorder` node joins your tailnet like any other device (Docker container, or K8s `Recorder` CR managed by the operator).
- The SSH server (or K8s operator) **streams session data over WireGuard** to the recorder.
- Recorder writes to local disk or **S3-compatible storage** (Amazon S3, MinIO, GCS, Wasabi, R2).
- Recording is wired up by **policy**, not by per-host config:
  - SSH: a `recorder` field on an `ssh` access rule.
  - K8s: a `tailscale.com/cap/kubernetes` grant pointing at the recorder tag.
- **`enforceRecorder: true`** = "fail closed" (deny the session if the recorder is unreachable). Default is fail-open.
- Multiple recorders sharing one tag give automatic failover (lowest tailnet IP first).

What's **not** captured: stdin/keystrokes (so typed passwords are not recorded). Output is captured, so anything printed to the terminal is.

## Canonical shapes

### Deploy `tsrecorder` (Docker, S3 backend)

```bash
docker run --name tsrecorder --rm -it \
  -e TS_AUTHKEY=$TS_AUTHKEY \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -v $HOME/tsrecorder:/data \
  tailscale/tsrecorder:stable \
  /tsrecorder \
    --dst='s3://s3.us-east-2.amazonaws.com' \
    --bucket=$S3_BUCKET_NAME \
    --statedir=/data/state \
    --ui
```

Drop the AWS vars and use `--dst=/data/recordings` for local storage. The `--ui` flag enables the web viewer (requires HTTPS on your tailnet). On EC2 with an IAM role attached, omit the access/secret keys entirely.

### Deploy `tsrecorder` in Kubernetes

The operator manages this via the `Recorder` CRD:

```yaml
apiVersion: tailscale.com/v1alpha1
kind: Recorder
metadata: {name: recorder}
spec:
  enableUI: true
  tags: ["tag:k8s-recorder"]
  storage:
    s3:
      endpoint: s3.us-east-1.amazonaws.com
      bucket: tsrecorder-bucket
      credentials:
        secret: {name: s3-auth}
```

Requires the Tailscale Kubernetes operator already installed and `tag:k8s-recorder` owned by `tag:k8s-operator`.

### Turn on **SSH** session recording

In the tailnet policy file:

```json
"tagOwners": {
  "tag:session-recorder": ["<owner>"]
},
"ssh": [
  {
    "action": "check",
    "src": ["group:engineering"],
    "dst": ["tag:server"],
    "users": ["autogroup:nonroot"],
    "recorder": ["tag:session-recorder"],
    "enforceRecorder": true
  }
]
```

Sessions matching this rule are recorded. `enforceRecorder: true` = deny if the recorder is down.

### Turn on **Kubernetes** session recording

In the tailnet policy file, via a Kubernetes capability grant:

```json
"grants": [
  {
    "src": ["group:engineering"],
    "dst": ["tag:k8s-operator"],
    "app": {
      "tailscale.com/cap/kubernetes": [{
        "recorder": ["tag:tsrecorder"],
        "enforceRecorder": true,
        "enableEvents": true
      }]
    }
  }
]
```

- `recorder` — tag of your tsrecorder instance.
- `enforceRecorder: true` — fail closed (deny sessions when recorder is unreachable).
- `enableEvents: true` — also record Kubernetes API requests (not just `kubectl` sessions). Without this, only the interactive session types are captured. This is an **alpha** feature (Tailscale v1.90+) that additionally requires setting `TS_EXPERIMENTAL_KUBE_API_EVENTS=true` on the API server proxy and an `acls` rule allowing `tag:k8s-operator:443` — so `enableEvents` alone is not sufficient. Fetch the Kubernetes recorder docs for the current setup before promising it works.

### Viewing recordings

- **Review recordings**: recordings can be reviewed in the Tailscale admin console.
- **Web UI** at `https://<recorder-name>.<tailnet-dns>.ts.net` (needs `--ui` and tailnet HTTPS).
- **CLI**: `asciinema play <file.cast>` to replay, `grep` directly on the file to search.
- **Storage layout**: `<stablenodeid>/<timestamp>.cast` under the destination root.

## Where to find current information

| User is asking about… | Fetch |
|---|---|
| SSH session recording — full setup | https://tailscale.com/docs/features/tailscale-ssh/tailscale-ssh-session-recording |
| SSH recording to S3 (IAM policy, R2/MinIO/GCS specifics, IRSA) | https://tailscale.com/docs/features/tailscale-ssh/how-to/session-recording-s3 |
| Multiple recorders / failover | https://tailscale.com/docs/reference/multiple-recorder-nodes |
| Kubernetes recorder — overview | https://tailscale.com/docs/kubernetes-operator/recorder |
| Deploying tsrecorder via the operator (Recorder CRD, storage, IRSA) | https://tailscale.com/docs/kubernetes-operator/recorder/deploy-tsrecorder |
| kubectl session + API event recording | https://tailscale.com/docs/kubernetes-operator/recorder/kubectl-session-recording |

## Worked examples

| If the user wants to… | Fetch |
|---|---|
| Record SSH sessions to satisfy a compliance or audit requirement (SOC2 and similar) | https://tailscale.com/docs/use-cases/infrastructure-access/record-ssh-sessions-compliance |

## Answering pattern

The inline shapes above are usually enough to answer "how do I turn this on" questions. For specifics that drift — IAM policy JSON, full `tsrecorder` flag list, S3-compatible backend quirks (R2's `S3_SEND_CONTENT_MD5`, GCS `interop` keys), or the latest `Recorder` CRD fields (IRSA annotations, `statefulSet` overrides). WebFetch the matching page and quote field names and flags verbatim from the fetched content.
