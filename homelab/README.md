# homelab


## Overview

```mermaid
graph TD
	subgraph Home devices
		A[PC - Proxmox VE] -->|192.168.1.106| 100{VM - NixOS};
		100 -->|:22| 100_ssh[OpenSSH];
		100 -->|:6443 :80| K3s[K3s];
		K3s -->|192.168.1.100-192.168.1.250| MetalLB(MetalLB);
		click MetalLB "https://metallb.org" _blank
		K3s -->|:80| Kong(Kong Ingress);
		K3s --> Pi-hole(Pi-hole);
		Kong -->|pi.hole| Pi-hole;
		
		A -->|192.158.1.103| 102{VM - Debian};
		102 -->|:22| 102_ssh[OpenSSH];
		102 --> lolminer[LolMiner];
		
		A -->|192.158.1.104| 103{VM - NixOS};
		103 -->|:22| 103_ssh[OpenSSH];
		
		A -->|192.168.1.105| 104{VM - NixOS};
		104 -->|:22| 104_ssh[OpenSSH];
		
		
		B[Watchy]
	end
	
	subgraph Gandi.net VPS 
		C[DATACENTER FR-SD6] -->|46.226.106.65| Tosh{V-R4 - NixOS};	
	end
	
	classDef orange fill:#f96;
	classDef blue	fill:#00f;
	class A orange
	class C blue
```

Diagram/flowchart using [mermaid](https://github.com/mermaid-js/mermaid)

### K3s

Running as a systemd service in a NixOS box with `traefik` and `servicelb` **disabled**.

### MetalLB

In [layer 2](https://metallb.org/concepts/layer2/) mode and ip pool of `192.168.1.100-192.168.1.250`

### LolMiner

The VM with id `102` have a Nvidia 3060 Ti GPU allocated that is being used to mine Ethereum and Ton using [lolminer](https://github.com/Lolliedieb/lolMiner-releases)

## Resources

- https://github.com/0dragosh/homelab-k3s
- https://github.com/TUM-DSE/doctor-cluster-config/tree/master/modules/k3s
- https://github.com/fluxcd/flux2-kustomize-helm-example
