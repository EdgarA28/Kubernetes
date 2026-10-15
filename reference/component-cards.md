# Component reference cards

The lookup you need during a troubleshooting task: for each cluster component, **what it is, how it
runs, where its configuration lives, how it authenticates, where its logs are, and how to restart
it.** What each component *does* is explained in
[`00-03` — Cluster architecture](../00-foundations/00-03-cluster-architecture.md) §3; lab step 9.8
there has you verify every card on your own cluster.

All paths are **kubeadm defaults**, which kind and the CKA (Certified Kubernetes Administrator)
clusters both use (kubeadm — "Kubernetes admin" — is the official cluster bootstrap tool).

Abbreviations used in the cards: **PKI** (Public Key Infrastructure — the CAs, certificates and keys
in `/etc/kubernetes/pki/`), **CA** (Certificate Authority — the key pair that signs certificates),
**CSR** (Certificate Signing Request), **TLS** (Transport Layer Security), **CIDR** (Classless
Inter-Domain Routing — an IP range like `10.244.0.0/16`), **TCP/UDP** (Transmission Control
Protocol / User Datagram Protocol), **CLI** (Command-Line Interface).

The first thing to know about any component is **how it runs**, because that decides every other
answer:

| Runs as | Components | Configured by | Logs | Restarted by |
|---|---|---|---|---|
| **Static Pod** | kube-apiserver, etcd, kube-scheduler, kube-controller-manager | Flags in `/etc/kubernetes/manifests/<name>.yaml` | `kubectl logs`, or `crictl logs` when the API server is down | Editing (or moving out and back) the manifest |
| **systemd service** | kubelet, containerd | Config file + unit file on the node | `journalctl -u <unit>` | `systemctl restart <unit>` |
| **DaemonSet / Deployment** | kube-proxy, CNI agent, CoreDNS | A ConfigMap in `kube-system` | `kubectl logs` | `kubectl rollout restart` |

## kube-apiserver

| | |
|---|---|
| **What it is** | The HTTPS (HTTP Secure) API (Application Programming Interface) server — the only door to cluster state |
| **Runs as** | Static Pod on every control-plane node — `/etc/kubernetes/manifests/kube-apiserver.yaml` |
| **Port** | **6443** (HTTPS) |
| **Key flags** | `--advertise-address`, `--etcd-servers=https://127.0.0.1:2379`, `--service-cluster-ip-range`, `--authorization-mode=Node,RBAC`, `--enable-admission-plugins`, `--client-ca-file`, `--tls-cert-file`/`--tls-private-key-file`, `--service-account-key-file` |
| **Certificates** (`/etc/kubernetes/pki/`) | Serving: `apiserver.crt/.key`. To etcd: `apiserver-etcd-client.crt/.key` + `etcd/ca.crt`. To kubelets: `apiserver-kubelet-client.crt/.key`. Trusts clients signed by `ca.crt` |
| **Health** | `curl -k https://127.0.0.1:6443/livez` on the node, or `kubectl get --raw='/readyz?verbose'` |
| **Logs** | `kubectl -n kube-system logs kube-apiserver-<node>`. When it is down: `crictl ps -a --name kube-apiserver` → `crictl logs <id>`; files in `/var/log/pods/kube-system_kube-apiserver-*/` |
| **Restart** | Edit the manifest; the kubelet recreates the Pod (takes ~30–60 s to come back) |
| **Typical CKA break** | Wrong `--etcd-servers` port, a mistyped cert path, an invalid flag → `kubectl` gets *connection refused* |

## etcd

| | |
|---|---|
| **What it is** | The cluster's key-value database ("/etc distributed") — holds every object |
| **Runs as** | Static Pod — `/etc/kubernetes/manifests/etcd.yaml` |
| **Ports** | **2379** clients, **2380** peers, 2381 metrics/health (localhost, HTTP) |
| **Data** | `--data-dir=/var/lib/etcd`, mounted from the node with a `hostPath` volume |
| **Certificates** (`/etc/kubernetes/pki/etcd/`) | `ca.crt/.key` (etcd's **own** CA), `server.crt/.key`, `peer.crt/.key`, `healthcheck-client.crt/.key` |
| **etcdctl flags** | `--endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key` — copy them from the manifest |
| **Health** | `etcdctl <flags> endpoint health` |
| **Logs** | `kubectl -n kube-system logs etcd-<node>`, or `crictl logs` |
| **Restart** | Edit the manifest |
| **Typical CKA break** | Backup and restore (`07-03`): restore to a new directory, then change the `hostPath` of the data volume in this manifest |

## kube-scheduler

| | |
|---|---|
| **What it is** | Chooses a node for each unscheduled Pod and records it in `spec.nodeName` |
| **Runs as** | Static Pod — `/etc/kubernetes/manifests/kube-scheduler.yaml` |
| **Port** | **10259** (HTTPS: health and metrics only) |
| **Authenticates with** | kubeconfig `/etc/kubernetes/scheduler.conf` (a client cert for user `system:kube-scheduler`) |
| **Key flags** | `--kubeconfig`, `--leader-elect=true`, `--config` (scheduler profiles, Domain 5) |
| **Leader election** | Lease `kube-system/kube-scheduler` — `kubectl -n kube-system get lease kube-scheduler` shows the active instance |
| **Logs** | `kubectl -n kube-system logs -l component=kube-scheduler` |
| **Restart** | Edit the manifest |
| **Typical CKA break** | Wrong kubeconfig path or a bad flag → every new Pod `Pending` with no events |

## kube-controller-manager

| | |
|---|---|
| **What it is** | One process running the built-in reconcile loops (Deployment, ReplicaSet, Node, Job, certificate signing…) |
| **Runs as** | Static Pod — `/etc/kubernetes/manifests/kube-controller-manager.yaml` |
| **Port** | **10257** (HTTPS: health and metrics only) |
| **Authenticates with** | kubeconfig `/etc/kubernetes/controller-manager.conf` (user `system:kube-controller-manager`) |
| **Key flags** | `--cluster-cidr` and `--allocate-node-cidrs` (Pod IP ranges in CIDR — Classless Inter-Domain Routing — notation), `--service-cluster-ip-range`, `--cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt` and `--cluster-signing-key-file=…/ca.key` (signs approved CSRs — Certificate Signing Requests), `--service-account-private-key-file=/etc/kubernetes/pki/sa.key` (signs ServiceAccount tokens), `--root-ca-file`, `--controllers` |
| **Leader election** | Lease `kube-system/kube-controller-manager` |
| **Logs** | `kubectl -n kube-system logs -l component=kube-controller-manager` |
| **Restart** | Edit the manifest |
| **Typical CKA break** | Bad flag or kubeconfig → Deployments with no ReplicaSets, no scaling, approved CSRs never signed |

## kubelet

| | |
|---|---|
| **What it is** | The node agent: runs the Pods bound to its node through the runtime and reports their status |
| **Runs as** | systemd service `kubelet` on **every** node, control plane included |
| **Ports** | **10250** (kubelet API: logs, exec, port-forward go through it), 10248 (`/healthz`, localhost) |
| **Config file** | `/var/lib/kubelet/config.yaml` (a `KubeletConfiguration`: `staticPodPath`, `clusterDNS`, `cgroupDriver`, eviction thresholds, `authentication`/`authorization`) |
| **Unit and flags** | `systemctl cat kubelet` shows the unit and its kubeadm drop-in (`10-kubeadm.conf`); extra flags in `/var/lib/kubelet/kubeadm-flags.env` (e.g. `--container-runtime-endpoint`) |
| **Authenticates with** | kubeconfig `/etc/kubernetes/kubelet.conf` → client cert `/var/lib/kubelet/pki/kubelet-client-current.pem` (rotated automatically). Bootstrap: `/etc/kubernetes/bootstrap-kubelet.conf` on joining nodes |
| **Logs** | `journalctl -u kubelet --no-pager -n 100` (add `-f` to follow) |
| **Restart** | `systemctl restart kubelet` (after editing the unit: `systemctl daemon-reload` first) |
| **Typical CKA break** | Service stopped/disabled, wrong path to the CA or config, wrong runtime endpoint → node `NotReady`. Fix, then `systemctl enable --now kubelet` |

## containerd (the container runtime)

| | |
|---|---|
| **What it is** | The container runtime: pulls images and creates Pod sandboxes and containers on request, using runc (the OCI — Open Container Initiative — runtime) underneath |
| **Runs as** | systemd service `containerd` on every node |
| **Socket** | `unix:///run/containerd/containerd.sock` (the CRI — Container Runtime Interface — endpoint the kubelet and `crictl` use) |
| **Config** | `/etc/containerd/config.toml` — notably `SystemdCgroup = true`, which must match the kubelet's `cgroupDriver: systemd` |
| **CLI** (Command-Line Interface) | `crictl` ("CRI control", configured by `/etc/crictl.yaml`): `ps`, `pods`, `images`, `logs`, `inspect` |
| **Logs** | `journalctl -u containerd` |
| **Restart** | `systemctl restart containerd` — running containers survive it |
| **Typical CKA break** | Runtime stopped → node `NotReady` with *container runtime is down* in the kubelet log |

## kube-proxy

| | |
|---|---|
| **What it is** | Programs each node's kernel so Service virtual IPs reach the Pods behind them |
| **Runs as** | DaemonSet `kube-system/kube-proxy`, `hostNetwork: true` |
| **Ports** | 10256 (`/healthz`), 10249 (metrics, localhost) |
| **Config** | ConfigMap `kube-system/kube-proxy` (key `config.conf`: `mode`, `clusterCIDR`) |
| **Authenticates with** | Its ServiceAccount `kube-proxy` |
| **Logs** | `kubectl -n kube-system logs ds/kube-proxy` (one Pod) or `-l k8s-app=kube-proxy` |
| **Restart** | `kubectl -n kube-system rollout restart ds kube-proxy` (needed after editing the ConfigMap) |
| **Typical CKA break** | DaemonSet missing/broken → Services stop routing on affected nodes, though DNS still resolves |

## CoreDNS

| | |
|---|---|
| **What it is** | The cluster DNS (Domain Name System) server: resolves Service and Pod names to IPs |
| **Runs as** | Deployment `kube-system/coredns` (2 replicas), behind Service **`kube-dns`** — usually `10.96.0.10` with kubeadm's default Service range |
| **Ports** | 53 UDP/TCP (User Datagram Protocol / Transmission Control Protocol) for DNS, 9153 (metrics), 8080 (`/health`), 8181 (`/ready`) |
| **Config** | ConfigMap `kube-system/coredns`, key `Corefile` |
| **How Pods find it** | The kubelet's `clusterDNS` setting is written into each Pod's `/etc/resolv.conf` |
| **Logs** | `kubectl -n kube-system logs -l k8s-app=kube-dns` |
| **Restart** | `kubectl -n kube-system rollout restart deploy coredns` |
| **Typical CKA break** | Scaled to 0, a broken Corefile, or a `kube-dns` Service selector mismatch → name lookups fail |

## CNI (Container Network Interface) plugin (kindnet on this cluster; Calico, Cilium or Flannel elsewhere)

| | |
|---|---|
| **What it is** | The Pod network: gives each Pod sandbox an interface and IP, and routes traffic between Pods across nodes |
| **Runs as** | A DaemonSet (agent) **plus** binaries the runtime executes for each Pod |
| **Files on the node** | Binaries in `/opt/cni/bin/`, config in `/etc/cni/net.d/` (the first file alphabetically wins) |
| **Logs** | The DaemonSet's Pod logs; the kubelet log for *failed to set up sandbox* errors |
| **Typical CKA break** | No CNI installed or broken config → nodes `NotReady` (*network plugin not ready*), Pods stuck in `ContainerCreating` |

## The files you will look for most often

```
/etc/kubernetes/
├── manifests/                     static Pods: kube-apiserver, etcd, kube-scheduler, kube-controller-manager
├── admin.conf                     kubeconfig for cluster admins (kubeadm also creates super-admin.conf)
├── kubelet.conf                   kubelet → API server
├── controller-manager.conf        controller manager → API server
├── scheduler.conf                 scheduler → API server
└── pki/                           PKI (Public Key Infrastructure): CAs, certificates, keys
    ├── ca.crt / ca.key            cluster CA (Certificate Authority): signs component and user client certs
    ├── apiserver.crt / .key       API server serving cert
    ├── apiserver-kubelet-client.* API server → kubelets
    ├── apiserver-etcd-client.*    API server → etcd
    ├── front-proxy-ca.* / front-proxy-client.*   API aggregation (09-05)
    ├── sa.key / sa.pub            signs / verifies ServiceAccount tokens
    └── etcd/                      etcd's own CA and its server / peer / healthcheck certs
/var/lib/kubelet/config.yaml       kubelet configuration (staticPodPath, clusterDNS, cgroupDriver)
/var/lib/etcd/                     etcd data
/etc/containerd/config.toml        container runtime configuration
/etc/cni/net.d/ · /opt/cni/bin/    CNI config · CNI binaries
/var/log/pods/ · /var/log/containers/   container log files
```

**When a path is not where you expect** (a non-kubeadm cluster, or a deliberately changed exam
cluster), do not guess. Ask the running process:

```bash
ps -ef | grep [k]ube-apiserver | tr ' ' '\n' | grep -- '--'   # every flag the API server was started with
systemctl cat kubelet                                          # unit + drop-ins → where kubelet config lives
grep staticPodPath /var/lib/kubelet/config.yaml                # where static Pod manifests are
kubectl -n kube-system get pod kube-apiserver-<node> -o yaml   # the manifest as the API sees it
```

