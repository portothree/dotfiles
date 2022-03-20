# homelab

```mermaid
flowchart TD
	A[Proxmox VE] --> B{100 - NixOS K8s node};
	A --> C{102 - Mining rig};
	A --> D{103 - NixOS working machine};
	A --> E{104 - NixOS working machine};
```

## Resources

- https://github.com/0dragosh/homelab-k3s
- https://github.com/TUM-DSE/doctor-cluster-config/tree/master/modules/k3s
- https://github.com/fluxcd/flux2-kustomize-helm-example
