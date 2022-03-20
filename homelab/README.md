# homelab

```mermaid
flowchart TD
	A[Proxmox VE] --> 100{100 - NixOS K8s node};
	A --> 102{102 - Debian Mining rig};
	A --> 103{103 - NixOS work machine};
	A --> 104{104 - NixOS work machine};
```

## Resources

- https://github.com/0dragosh/homelab-k3s
- https://github.com/TUM-DSE/doctor-cluster-config/tree/master/modules/k3s
- https://github.com/fluxcd/flux2-kustomize-helm-example
