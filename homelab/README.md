# homelab

```mermaid
flowchart TD
	A[Proxmox VE] -->|192.168.1.100| 100{NixOS K8s node};
	A -->|192.158.1.103| 102{Debian Mining rig};
	A -->|192.158.1.104| 103{NixOS work machine};
	A -->|192.168.1.105| 104{NixOS work machine};
```

## Resources

- https://github.com/0dragosh/homelab-k3s
- https://github.com/TUM-DSE/doctor-cluster-config/tree/master/modules/k3s
- https://github.com/fluxcd/flux2-kustomize-helm-example
