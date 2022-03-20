# homelab

```mermaid
flowchart TD
	A[Proxmox VE] --> B{100 - NixOS K8s node};
	A[Proxmox VE] --> B{102 - Mining rig};
	A[Proxmox VE] --> B{103 - NixOS working machine};
	A[Proxmox VE] --> B{104 - NixOS working machine};
```

## Resources

- https://github.com/0dragosh/homelab-k3s
- https://github.com/TUM-DSE/doctor-cluster-config/tree/master/modules/k3s
- https://github.com/fluxcd/flux2-kustomize-helm-example
