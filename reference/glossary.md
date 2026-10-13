# Glossary — every term used in this course

Terms as Kubernetes uses them. Where a term is explained in depth, the module is linked. Entries
marked with a domain number are defined when that domain is written.

---

## A

**Admission controller** — Code in the API server that runs after authorisation and can **mutate** (change) or **validate** (accept/reject) a request before it is stored. Examples: ServiceAccount, LimitRanger, ResourceQuota, PodSecurity, webhooks, ValidatingAdmissionPolicy. → `00-03`, Domain 6

**Annotation** — Non-identifying key/value metadata on an object; not selectable. For tools and humans. → `00-04`

**API group** — A family of related kinds served under `/apis/<group>/<version>`, e.g. `apps`, `batch`. The **core** group has no name and lives under `/api/v1`. → `00-04`

**apiVersion** — `group/version` written in every manifest (`apps/v1`), or just `v1` for the core group. → `00-04`

**apply** — Declarative create-or-update that merges your file into the live object; client-side (last-applied annotation, three-way merge) or server-side (field managers). → `00-05`

## C

**cgroup (control group)** — Linux kernel feature limiting what a process group can **use**: CPU, memory, PIDs, I/O. Kubernetes `resources.limits` become cgroup settings. → `00-01`

**ClusterIP** — The default Service type: a virtual IP reachable only inside the cluster. → `00-06`, Domain 3

**Cluster-scoped** — An object that does not live in a namespace (Node, PV, StorageClass, ClusterRole, Namespace, CRD). → `00-04`

**CNI (Container Network Interface)** — The plugin interface that gives Pods their network: IP address, interfaces, routes. Implementations: kindnet, Calico, Cilium, Flannel. → `00-03`, Domain 3

**Context** — In kubeconfig, a named triple of cluster + user + default namespace. → `00-05`

**Controller** — A loop that watches objects and acts to make actual state match desired state. Level-triggered. → `00-03`

**CoreDNS** — The cluster DNS server; resolves Service names to ClusterIPs. Runs as a Deployment behind the `kube-dns` Service. → `00-03`, Domain 3

**CRI (Container Runtime Interface)** — The gRPC API the kubelet uses to manage Pods and containers. Implemented by containerd and CRI-O. → `00-01`

**`crictl`** — CLI for CRI runtimes; the node-level debugging tool replacing `docker` on Kubernetes nodes. → `00-01`, `00-03`

**CrashLoopBackOff** — Status of a container that keeps exiting; the kubelet waits exponentially longer between restarts (up to 5 min). Read `logs --previous`. → `00-06`

**CRD (CustomResourceDefinition)** — Adds a new kind to the API. Domain 9

**CSI (Container Storage Interface)** — Plugin interface for storage drivers. Domain 4

## D

**DaemonSet** — Runs one Pod per (matching) node. kube-proxy and CNI agents use it. Domain 1

**Declarative configuration** — Describing desired state (files, usually in Git) and letting controllers converge on it, rather than issuing step-by-step commands. → `00-01`, `00-05`

**Deployment** — Manages ReplicaSets to provide rolling updates and rollback for stateless Pods. → `00-06`, Domain 1

**Digest** — Content hash identifying an exact image (`@sha256:…`). Immutable, unlike a tag. → `00-01`

**dockershim** — The adapter that let the kubelet use Docker Engine; removed in v1.24. → `00-01`

**Downward API** — Exposes a Pod's own metadata (name, namespace, labels, resources) to its containers via env or files. → `00-06`, Domain 2

**Dry run** — `--dry-run=client` builds an object locally; `--dry-run=server` runs it through validation and admission without storing. → `00-05`

## E

**EndpointSlice** — Lists the IPs and ports of Ready Pods behind a Service; maintained by the EndpointSlice controller and consumed by kube-proxy. → `00-06`, Domain 3

**etcd** — The distributed key-value store (Raft) holding all cluster state. Only the API server accesses it. → `00-03`, Domain 7

**Event** — An object recording something that happened to another object (`Scheduled`, `Pulling`, `FailedScheduling`, `BackOff`). Shown at the bottom of `kubectl describe`. Kept ~1 hour by default. → `00-03`

**Exit code 137 / 143** — 128 + signal: 137 = SIGKILL (often OOM), 143 = SIGTERM. → `00-01`

## F

**Field manager** — The identity recorded in `managedFields` as owner of a field; basis of server-side apply conflicts. → `00-04`, `00-05`

**Finalizer** — A string in `metadata.finalizers` that blocks actual deletion until a controller removes it. Cause of "stuck Terminating". → `00-04`

## G

**Garbage collector** — Controller that deletes objects whose owners (per `ownerReferences`) no longer exist. → `00-04`

**Generation / observedGeneration** — `metadata.generation` increments on spec changes; `status.observedGeneration` is the generation the controller last processed. → `00-04`

**GVK / GVR** — Group-Version-Kind / Group-Version-Resource; how the API identifies a type. → `00-04`

## I

**Image** — Read-only filesystem layers plus config (entrypoint, cmd, env, user), in OCI format. → `00-01`

**ImagePullBackOff / ErrImagePull** — The kubelet cannot pull the image: wrong name/tag, missing credentials, unreachable registry. → `00-02`, `00-06`

**imagePullPolicy** — `Always`, `IfNotPresent`, `Never`. Defaults to `Always` for `:latest`/no tag, otherwise `IfNotPresent`. → `00-01`

## K

**kind** — Kubernetes in Docker: each node is a container; bootstrapped with kubeadm. The course's lab cluster. → `00-02`

**kube-apiserver** — The REST front end of the control plane; authn → authz → admission → validation → etcd. → `00-03`

**kube-controller-manager** — Process running the built-in controllers (Deployment, ReplicaSet, Node, Job, EndpointSlice, GC…). → `00-03`

**kube-proxy** — Per-node agent programming iptables/nftables/IPVS so Service IPs reach Pod IPs. → `00-03`, Domain 3

**kube-scheduler** — Assigns unscheduled Pods to nodes (filter, score, bind). → `00-03`, Domain 5

**kubeadm** — Official tool to bootstrap clusters (`init`, `join`, `upgrade`). Domain 7

**kubeconfig** — Client config file listing clusters, users and contexts. → `00-05`

**kubelet** — Per-node agent (systemd service) that runs Pods bound to its node via CRI, runs probes, and reports status. → `00-03`

## L

**Label / selector** — Identifying key/value pairs, and the queries (equality or set-based) that match them. How Services, controllers and policies find objects. → `00-04`

**Lease** — Small object used for node heartbeats (`kube-node-lease`) and leader election (`kube-system`). → `00-03`

**Level-triggered** — Acting on the current difference between desired and actual state, not on individual change events. Makes controllers self-healing. → `00-03`

## M

**Mirror Pod** — The read-only API representation of a static Pod, named `<pod>-<node>`. → `00-03`

## N

**Namespace (Kubernetes)** — A scope for object names; not a security boundary by itself. → `00-04`

**Namespace (Linux)** — Kernel feature isolating what a process can **see** (pid, net, mnt, uts, ipc, user, cgroup). → `00-01`

**NodePort** — Service type opening a port (30000–32767) on every node. → `00-06`, Domain 3

## O

**OCI (Open Container Initiative)** — Standards for image format and runtime behaviour. → `00-01`

**OOMKilled** — Container killed by the kernel for exceeding its memory limit; exit 137. → `00-01`

**ownerReference** — Metadata pointing at an object's owner; drives garbage collection and adoption. → `00-04`

## P

**Pod** — The smallest deployable unit: one or more containers sharing network namespace and volumes, scheduled together on one node. → `00-06`, Domain 1

**Pod template** — `spec.template` of a controller; the blueprint for the Pods it creates. Changing it in a Deployment triggers a rollout. → `00-06`

**port / targetPort / nodePort** — Service port clients use / container port traffic goes to / port opened on every node. → `00-06`

## R

**Raft** — Consensus algorithm used by etcd; writes need a majority (quorum). → `00-03`

**Readiness** — Whether a container should receive traffic; only Ready Pods appear in EndpointSlices. → `00-06`, Domain 1

**Reconciliation** — Continuously driving actual state toward desired state. → `00-01`, `00-03`

**ReplicaSet** — Keeps N Pods matching a template running. Managed by a Deployment. → `00-06`

**resourceVersion** — Opaque version string changing on every write; used for optimistic concurrency (409 Conflict) and watches. → `00-04`

**Rollout / rollback** — Gradual replacement of Pods with a new template version / returning to a previous ReplicaSet (`kubectl rollout undo`). → `00-06`, Domain 1

**runc** — The reference low-level OCI runtime that creates namespaces and cgroups and starts the process. → `00-01`

## S

**Server-side apply** — `kubectl apply --server-side`; field ownership tracked in `managedFields`, conflicts reported. → `00-05`

**Service** — Stable virtual IP + DNS name load-balancing to Pods selected by label. → `00-06`, Domain 3

**spec / status** — Desired state (written by you) / observed state (written by controllers). → `00-04`

**Static Pod** — A Pod the kubelet runs directly from a file in its `staticPodPath` (`/etc/kubernetes/manifests/`), without the API server. How kubeadm runs the control plane. → `00-03`

## T

**Taint** — A node marking that repels Pods unless they tolerate it (e.g. `node.kubernetes.io/unreachable`). → `00-03`, Domain 5

**terminationGracePeriodSeconds** — Time between SIGTERM and SIGKILL when a Pod is deleted; default 30 s. → `00-01`

---

## Numbers to memorise

| Number | What |
|---|---|
| **6443** | kube-apiserver port |
| **2379 / 2380** | etcd client / peer ports |
| **10250** | kubelet API port |
| **10257 / 10259** | controller-manager / scheduler secure ports |
| **30000–32767** | Default NodePort range |
| **30 s** | Default termination grace period |
| **300 s** | Default toleration for `not-ready`/`unreachable` taints before eviction |
| **~40–50 s** | Node-monitor grace period before a silent node is marked NotReady |
| **10** | Default `revisionHistoryLimit` of a Deployment |
| **600 s** | Default `progressDeadlineSeconds` |
| **25% / 25%** | Default `maxSurge` / `maxUnavailable` |
| **5 min** | Maximum CrashLoopBackOff delay |
| **⌊n/2⌋+1** | etcd quorum; 3 members tolerate 1 failure, 5 tolerate 2 |
| **±1 minor** | kubectl ↔ API server supported version skew |
| **63** | Max characters in a label value and in the name part of a label key |
