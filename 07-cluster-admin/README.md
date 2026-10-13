# Domain 7 — Cluster administration

Building, upgrading, backing up and repairing clusters — the core of the CKA.

**Prerequisites:** Domains 0–6; [`00-03`](../00-foundations/00-03-cluster-architecture.md) is essential.
**Exams:** CKA (Cluster architecture, installation & configuration 25%).
**Status:** **deferred by choice** — written after Domain 8, studied before the CKA mock exams (this domain is 25% of the CKA).
**Lab environment:** VMs for kubeadm (e.g. Multipass or KVM on the Ubuntu lab machine) — decided when the domain is written. `07-07` (AKS) is optional for the CKA.

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 07-01 | Building a cluster with kubeadm | Container runtime, kubeadm init/join, CNI install | Planned |
| 07-02 | Upgrading a cluster | Version skew policy, control plane then nodes, drain/uncordon | Planned |
| 07-03 | etcd operations | snapshot save/restore, defrag, member management | Planned |
| 07-04 | Certificates and PKI | The cluster CA, `kubeadm certs`, the CSR API | Planned |
| 07-05 | Node management | cordon, drain, kubelet configuration | Planned |
| 07-06 | High-availability control planes | Stacked vs external etcd, load-balanced API server | Planned |
| 07-07 | Managed Kubernetes (AKS) | What the cloud manages, node pools, upgrades, links to AZ-104 | Planned |

## Key point-losers in this domain

- Upgrade **one minor version at a time**; control plane first, then kubelets.
- `kubeadm upgrade apply` on the first control-plane node, `kubeadm upgrade node` on the others.
- An etcd restore goes to a **new data directory**; then point the etcd static Pod at it.
- `etcdctl` needs `--endpoints`, `--cacert`, `--cert`, `--key` — read them from the etcd manifest.
- kubeadm-issued certificates expire after **one year**; check with `kubeadm certs check-expiration`.
