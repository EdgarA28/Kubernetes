# Kubernetes — master study plan (basics → advanced)

*Written against Kubernetes **v1.36**. Target certification: **CKA**. Labs run in **bash on an Ubuntu
lab machine** (`00-02`). Re-check version-specific facts against <https://kubernetes.io/docs> when
something looks off.*

This is the **master document** for the course in this folder. It holds the goals, the complete
topic map, the schedule, how certification exams map onto it, and the index of every module —
written and planned.

---

## 0. What this course is, and who it is for

**Audience:** someone who has used Kubernetes before (or studied it) and needs to **revise and
re-learn it properly** — from first principles up to operating, securing and extending clusters.
Nothing is assumed: every object and term is defined on first use, but the pace assumes you have
seen some of it before.

**Primary goal: pass the CKA** — build, debug and repair a cluster under time pressure, in a bash
terminal. Everything the CKA needs is mandatory; CKAD/CKS-only depth and the expert domains (9–10)
are marked **optional** and come after the exam.

By the end you can

1. explain *why* every Kubernetes object exists and what it attaches to,
2. build, debug and repair a cluster under time pressure (**CKA — the target**),
3. design and ship applications onto it (CKAD-level, mostly covered on the way),
4. harden it (CKS-level — optional, after the CKA), and
5. extend it with your own controllers and run it as a platform (optional, beyond any exam).

**How it differs from a syllabus or a tutorial**

| Gap in a typical course | How this course fixes it |
|---|---|
| Objects are shown as YAML to copy, not explained | Section 2 of every module is the **object model**: what it is, what it contains, what it attaches to, who reconciles it |
| "Magic" — things happen and nobody says which component did it | Section 6, **Under the hood**: which controller acted, what was written to etcd, what the kubelet did |
| Labs that only work when you follow the script | Every lab has a **break-it** step: you cause a failure on purpose and debug it, because that is the CKA |
| Imperative or declarative, never both | Every module shows **YAML and `kubectl` imperative** — the exam needs the speed of the second, real life needs the first |
| No retrieval practice — week 1 is gone by week 8 | Self-checks per module, cumulative exams per domain, two full mock exams at the end |
| Advanced topics bolted on at the end | Domains 9–10 build on the internals laid down in Domain 0 (`00-03`, `00-04`) |

---

## 1. Certifications this course covers

You do not need to take an exam, but the CNCF exams are the best external yardstick. All three are
**performance-based**: a real terminal, real clusters, 2 hours, ~15–20 tasks, open access to
`kubernetes.io/docs`. Speed with `kubectl` matters as much as knowledge.

| Exam | Focus | Pass mark | Domains (weight) |
|---|---|---|---|
| **CKAD** — Certified Kubernetes Application Developer | Building and running apps on a cluster | 66% | App design & build 20% · App deployment 20% · Observability & maintenance 15% · Environment, configuration & security 25% · Services & networking 20% |
| **CKA** — Certified Kubernetes Administrator | Building, running and fixing clusters | 66% | Troubleshooting **30%** · Cluster architecture, installation & configuration 25% · Services & networking 20% · Workloads & scheduling 15% · Storage 10% |
| **CKS** — Certified Kubernetes Security Specialist (requires a valid CKA) | Securing cluster, workloads, supply chain | 67% | Cluster setup 15% · Cluster hardening 15% · System hardening 10% · Minimise microservice vulnerabilities 20% · Supply chain security 20% · Monitoring, logging & runtime security 20% |

> Weights and pass marks change. Re-read the official curriculum at
> <https://github.com/cncf/curriculum> the week you book.

### The CKA mapped onto this course

| CKA domain | Weight | Where it is taught |
|---|---|---|
| **Troubleshooting** — clusters and nodes, cluster components, monitoring resource usage, container output streams, services and networking | **30%** | `00-03` (component chain), `00-06`, then all of Domain 8; every lab's break-it step |
| **Cluster architecture, installation & configuration** — RBAC, kubeadm install/upgrade, HA control plane, Helm & Kustomize, CNI/CSI/CRI extension interfaces, CRDs & operators | **25%** | `00-03`, Domain 6 (`06-01`–`06-03`), Domain 7, `02-04`, `02-05`, `09-01` |
| **Services & networking** — Pod connectivity, NetworkPolicy, Service types and endpoints, Gateway API, Ingress, CoreDNS | **20%** | Domain 3 (all) |
| **Workloads & scheduling** — Deployments, rollouts, ConfigMaps/Secrets, autoscaling, self-healing, Pod admission & scheduling | **15%** | Domains 1, 2, 5 |
| **Storage** — StorageClasses, dynamic provisioning, volume types, access modes, reclaim policies, PV/PVC | **10%** | Domain 4 |

**CKA exam facts to plan around:** 2 hours; ~15–20 hands-on tasks on several clusters; each task
names the **context** to switch to and the **host** to `ssh` into; one browser tab on
`kubernetes.io/docs` (and the Helm docs) allowed; pass mark 66%; one free retake; two killer.sh
simulator sessions included.

**Optional for the CKA** (do after the exam or skip): `06-04`–`06-09` beyond the basics (CKS),
`08-07`, Domains 9 (except `09-01`) and 10.

---

## 2. Domains and weights in this course

| # | Domain | Level | Modules | For the CKA | Status |
|---|---|---|---|---|---|
| **0** | **Foundations** — containers, lab setup, architecture, the API, kubectl, the object catalogue | Basic | 7 | Mandatory | ✅ **Complete** |
| 1 | Workloads — Pods, controllers, rollouts, Jobs, probes, resources | Basic → Intermediate | 9 | Mandatory | Next |
| 2 | Configuration & packaging — ConfigMaps, Secrets, Kustomize, Helm | Intermediate | 6 | Mandatory | Planned |
| 3 | Networking — Services, DNS, Ingress, Gateway API, NetworkPolicy, CNI | Intermediate → Advanced | 9 | Mandatory (20%) | Planned |
| 4 | Storage — volumes, PV/PVC, StorageClass, CSI, StatefulSet storage | Intermediate | 5 | Mandatory (10%) | Planned |
| 5 | Scheduling & autoscaling — affinity, taints, quotas, HPA/VPA, PDBs | Intermediate → Advanced | 7 | Mandatory | Planned |
| 6 | Security — authn, RBAC, Pod Security, admission, secrets, supply chain | Advanced | 9 | `06-01`–`06-03` mandatory; rest optional (CKS) | Planned |
| 7 | Cluster administration — kubeadm, upgrades, etcd, certificates, HA | Advanced | 7 | Mandatory (25%) | **Deferred** — written after Domain 8 |
| 8 | Observability & troubleshooting — logs, events, metrics, systematic debugging | Intermediate → Advanced | 7 | Mandatory (**30%**) | Planned |
| 9 | Extending Kubernetes — CRDs, controllers, operators, webhooks | Expert | 6 | `09-01` only | Optional |
| 10 | Production & platform — GitOps, service mesh, multi-tenancy, DR | Expert | 7 | — | Optional |

---

## 3. How the repository is organised

```
kubernetes/
├── k8s-study-plan.md          ← this file: master plan and index
├── README.md                  ← navigation + progress tracker
├── 00-foundations/            ← Domain 0 — complete
├── 01-workloads/              ← Domain 1
├── 02-configuration/          ← Domain 2
├── 03-networking/             ← Domain 3
├── 04-storage/                ← Domain 4
├── 05-scheduling/             ← Domain 5
├── 06-security/               ← Domain 6
├── 07-cluster-admin/          ← Domain 7
├── 08-observability/          ← Domain 8
├── 09-extending/              ← Domain 9
├── 10-production/             ← Domain 10
├── labs/                      ← kind cluster config, cluster up/down, lab cleanup scripts
├── reference/                 ← glossary, kubectl cheat sheet, decision tables
└── practice/                  ← question banks per domain + mock exams
```

---

## 4. The module template

**Every module follows the same ten parts.** This is the contract.

| # | Section | What it does |
|---|---|---|
| 1 | **Why this exists** | The problem the object or feature solves — and what people did before it |
| 2 | **The object model** | What it *is*, what it *contains*, what it *attaches to*, which controller reconciles it — usually a diagram |
| 3 | **Concepts** | Plain language, every term defined on first use |
| 4 | **Declarative YAML** | A complete, annotated manifest — the form you keep in Git |
| 5 | **Imperative `kubectl`** | The fastest way to create/inspect/change it — the form you use in an exam |
| 6 | **Under the hood** | What actually happens: API server → etcd → controller → kubelet → runtime |
| 7 | **Decision table** | When to choose this over the alternative |
| 8 | **Gotchas and exam traps** | Numbered and specific |
| 9 | **Lab** | Build it → verify it → **break it on purpose** → fix it → clean up |
| 10 | **Self-check** | Closed-book questions with worked answers |

---

## 5. Domain 0 — Foundations ✅ complete

| # | Module | Covers | Load-bearing facts |
|---|---|---|---|
| 00-01 | [Containers, and why orchestration exists](00-foundations/00-01-containers-and-why-orchestration.md) | Namespaces, cgroups, images, layers, digests, OCI, the runtime stack | A container is a process; exit 137 = SIGKILL (often OOM); Docker is not the K8s runtime |
| 00-02 | [Lab environment: kind, kubectl and the tooling](00-foundations/00-02-lab-environment-kind.md) | Ubuntu lab machine, Docker Engine, kind multi-node cluster, bash setup, the lab rules | Every lab lives in a namespace labelled `course=k8s` |
| 00-03 | [Cluster architecture](00-foundations/00-03-cluster-architecture.md) | API server, etcd, scheduler, controller manager, kubelet, kube-proxy, CNI, CoreDNS, static pods | Only the API server talks to etcd; controllers are level-triggered reconcile loops |
| 00-04 | [The API and the object model](00-foundations/00-04-api-and-object-model.md) | Groups/versions/kinds, spec vs status, metadata, labels, namespaces, owners, finalizers, YAML | `spec` = desired, `status` = observed; GC follows `ownerReferences` |
| 00-05 | [kubectl fluency](00-foundations/00-05-kubectl-fluency.md) | kubeconfig, verbs, output formats, generating YAML, apply vs create, patching | `--dry-run=client -o yaml` is the most valuable exam habit |
| 00-06 | [Your first application, end to end](00-foundations/00-06-first-app-end-to-end.md) | Pod → Deployment → Service → scale → rollout → rollback → debug | The capstone: everything in Domain 0 used together |
| 00-07 | [The object catalogue](00-foundations/00-07-object-catalogue.md) | Every built-in kind: what it is, contains, connects to, who acts on it, CKA weight | Selection failures are silent; reference failures are loud |

**Checkpoint:** score 20+ on [`practice/00-foundations-exam.md`](practice/00-foundations-exam.md)
before starting Domain 1.

---

## 6. Complete topic map, mapped to modules

### Domain 1 — Workloads

| Module | Covers | Exam |
|---|---|---|
| `01-01` | **Pods in depth** — lifecycle, phases, container states, restartPolicy, command/args vs ENTRYPOINT/CMD, termination & grace period, `preStop` | CKAD, CKA |
| `01-02` | **Multi-container Pods** — init containers, native sidecars (`restartPolicy: Always` in `initContainers`), ambassador/adapter patterns, shared volumes & network | CKAD |
| `01-03` | **ReplicaSets and Deployments** — selectors, pod-template-hash, ownership, scaling | CKAD, CKA |
| `01-04` | **Rollouts** — RollingUpdate (`maxSurge`/`maxUnavailable`), Recreate, history, rollback, pause/resume, blue/green & canary with plain objects | CKAD |
| `01-05` | **DaemonSets** — one per node, update strategies, node targeting | CKA |
| `01-06` | **StatefulSets** — stable identity, ordered rollout, headless Service, `volumeClaimTemplates`, partitions | CKA, CKAD |
| `01-07` | **Jobs and CronJobs** — completions, parallelism, backoffLimit, indexed jobs, `activeDeadlineSeconds`, TTL, concurrencyPolicy, time zones | CKAD |
| `01-08` | **Probes** — liveness, readiness, startup; exec/http/tcp/grpc; the failure modes of bad probes | CKAD |
| `01-09` | **Resources** — requests vs limits, CPU throttling vs OOM, QoS classes, eviction, in-place Pod resize | CKAD, CKA |

### Domain 2 — Configuration and packaging

| Module | Covers | Exam |
|---|---|---|
| `02-01` | **ConfigMaps** — env, envFrom, volume mounts, update propagation, immutable ConfigMaps | CKAD |
| `02-02` | **Secrets** — types, base64 ≠ encryption, projected volumes, imagePullSecrets, why env vars leak | CKAD, CKS |
| `02-03` | **Downward API and projected volumes** — Pod metadata into the container | CKAD |
| `02-04` | **Kustomize** — bases, overlays, patches, generators, `kubectl apply -k` | CKA, CKAD |
| `02-05` | **Helm** — charts, values, templates, releases, upgrade/rollback, writing a chart | CKA, CKAD |
| `02-06` | **Labels, annotations and organising manifests** — recommended labels, repo layout, environments | CKAD |

### Domain 3 — Networking

| Module | Covers | Exam |
|---|---|---|
| `03-01` | **The Kubernetes network model** — every Pod gets an IP, flat network, CNI, Pod CIDR vs Service CIDR | CKA |
| `03-02` | **Services** — ClusterIP, NodePort, LoadBalancer, ExternalName, headless; EndpointSlices; session affinity | all |
| `03-03` | **kube-proxy internals** — iptables vs nftables vs IPVS modes; tracing a packet through the rules | CKA |
| `03-04` | **DNS and CoreDNS** — records for Services and Pods, search domains, `ndots`, debugging DNS | CKA |
| `03-05` | **Ingress** — controllers, rules, TLS, path types; the ingress-nginx retirement and what replaces it | CKA, CKAD |
| `03-06` | **Gateway API** — GatewayClass, Gateway, HTTPRoute, traffic splitting, role separation | CKA |
| `03-07` | **NetworkPolicy** — default deny, ingress/egress, namespace & pod selectors, the AND/OR trap | all |
| `03-08` | **CNI deep dive** — veth pairs, bridges, routing vs overlay, Calico and Cilium (eBPF) | CKA |
| `03-09` | **Troubleshooting networking** — a decision tree from "connection refused" to the root cause | CKA |

### Domain 4 — Storage

| Module | Covers | Exam |
|---|---|---|
| `04-01` | **Volumes** — emptyDir, hostPath, configMap/secret, projected; lifetime vs Pod lifetime | CKAD |
| `04-02` | **PersistentVolumes and Claims** — binding, access modes, reclaim policies, volumeMode | CKA |
| `04-03` | **StorageClasses and dynamic provisioning** — `volumeBindingMode: WaitForFirstConsumer`, expansion, default class | CKA |
| `04-04` | **CSI** — drivers, snapshots, clones, ephemeral volumes | CKA |
| `04-05` | **Stateful workloads in practice** — a replicated database on a StatefulSet; backup thinking | — |

### Domain 5 — Scheduling and autoscaling

| Module | Covers | Exam |
|---|---|---|
| `05-01` | **The scheduler** — filter and score, `nodeName`, `nodeSelector`, scheduling failures | CKA |
| `05-02` | **Affinity and anti-affinity** — node and pod, required vs preferred | CKA |
| `05-03` | **Taints and tolerations** — effects, control-plane taint, eviction by taint | CKA |
| `05-04` | **Topology spread constraints, PriorityClasses and preemption** | CKA |
| `05-05` | **ResourceQuota and LimitRange** — multi-team clusters | CKA, CKAD |
| `05-06` | **Autoscaling** — HPA (metrics-server, custom metrics), VPA, Cluster Autoscaler vs Karpenter, KEDA | CKA |
| `05-07` | **Disruption** — PodDisruptionBudgets, drain, voluntary vs involuntary disruption | CKA |

### Domain 6 — Security

| Module | Covers | Exam |
|---|---|---|
| `06-01` | **Authentication** — X.509 client certs, ServiceAccount tokens (bound, projected), OIDC; there is no User object | CKA, CKS |
| `06-02` | **RBAC** — Role/ClusterRole/bindings, aggregation, `kubectl auth can-i`, least privilege | CKA, CKS |
| `06-03` | **ServiceAccounts** — automount, token projection, workload identity to clouds | CKA, CKS |
| `06-04` | **securityContext** — runAsNonRoot, capabilities, readOnlyRootFilesystem, seccomp, AppArmor | CKAD, CKS |
| `06-05` | **Pod Security Standards and Admission** — privileged/baseline/restricted, enforce/audit/warn | CKS |
| `06-06` | **Admission control** — built-in plugins, ValidatingAdmissionPolicy (CEL), webhooks, Kyverno vs OPA Gatekeeper | CKS |
| `06-07` | **Secrets at rest and in transit** — EncryptionConfiguration, KMS, external secret stores | CKS |
| `06-08` | **Supply chain** — image scanning (Trivy), signing (cosign), SBOMs, admission on signatures, minimal images | CKS |
| `06-09` | **Runtime security and audit** — audit policy, Falco, sandboxed runtimes (gVisor, Kata) | CKS |

### Domain 7 — Cluster administration

| Module | Covers | Exam |
|---|---|---|
| `07-01` | **Building a cluster with kubeadm** — on VMs, from scratch | CKA |
| `07-02` | **Upgrading a cluster** — version skew policy, control plane then nodes, drain/uncordon | CKA |
| `07-03` | **etcd operations** — backup, restore, defrag, member management | CKA |
| `07-04` | **Certificates and PKI** — the cluster CA, kubeadm cert renewal, CSR API | CKA |
| `07-05` | **Node management** — cordon, drain, kubelet config, node problems | CKA |
| `07-06` | **High-availability control planes** — stacked vs external etcd, load-balanced API server | CKA |
| `07-07` | **Managed Kubernetes (AKS)** — what the cloud manages, node pools, upgrades, links to AZ-104 | — |

### Domain 8 — Observability and troubleshooting

| Module | Covers | Exam |
|---|---|---|
| `08-01` | **Logs and events** — container logs, `--previous`, log rotation, cluster logging architectures | CKA, CKAD |
| `08-02` | **Metrics** — metrics-server, `kubectl top`, Prometheus and Grafana, kube-state-metrics | CKA |
| `08-03` | **Debugging Pods** — `kubectl debug`, ephemeral containers, debugging distroless images | CKA, CKAD |
| `08-04` | **Troubleshooting applications** — Pending, CrashLoopBackOff, ImagePullBackOff, CreateContainerConfigError, OOMKilled | CKA, CKAD |
| `08-05` | **Troubleshooting nodes** — NotReady, kubelet down, container runtime down, disk pressure | CKA |
| `08-06` | **Troubleshooting the control plane** — broken static Pod manifests, certificates, etcd | CKA |
| `08-07` | **Tracing and OpenTelemetry** — the third pillar | — |

### Domain 9 — Extending Kubernetes

| Module | Covers | Exam |
|---|---|---|
| `09-01` | **CustomResourceDefinitions** — schemas, versions, printer columns, subresources | CKA |
| `09-02` | **The controller pattern** — informers, work queues, reconcile, idempotency | — |
| `09-03` | **Writing an operator** — kubebuilder (Go) end to end | — |
| `09-04` | **Admission webhooks** — writing a mutating and a validating webhook | — |
| `09-05` | **Scheduler and API extensions** — scheduler profiles/plugins, API aggregation | — |
| `09-06` | **Dynamic Resource Allocation (DRA)** — GPUs and devices | — |

### Domain 10 — Production and platform engineering

| Module | Covers |
|---|---|
| `10-01` | **GitOps** — Argo CD and Flux, app-of-apps, drift detection |
| `10-02` | **Progressive delivery** — canary/blue-green with Argo Rollouts or Flagger |
| `10-03` | **Service mesh** — Istio (sidecar and ambient), Linkerd; mTLS, traffic policy |
| `10-04` | **Multi-tenancy** — namespace-per-team, vClusters, hierarchical policy |
| `10-05` | **Backup and disaster recovery** — Velero, etcd snapshots, multi-cluster |
| `10-06` | **Cost and capacity** — rightsizing, requests hygiene, spot nodes |
| `10-07` | **Capstone** — a production-grade platform on kind, then on AKS |

---

## 7. Schedule — 14 weeks (~8 hrs/week)

| Week | Focus | Modules | Lab targets |
|---|---|---|---|
CKA-first order. Domain 7 is written after Domain 8 but studied before the mock exams — the CKA
cannot be passed without it (25%).

| Week | Focus | Modules | Lab targets |
|---|---|---|---|
| **0** | **Foundations** | `00-01` → `00-07` | Ubuntu lab machine + kind cluster; break the scheduler and fix it; capstone app; dissect CoreDNS; score 20+ |
| 1 | Pods, multi-container, Deployments | `01-01` → `01-04` | Native sidecar; canary with two Deployments and one Service |
| 2 | DaemonSets, StatefulSets, Jobs, probes, resources | `01-05` → `01-09` | OOMKill on purpose; probe that kills a healthy app |
| 3 | Configuration and packaging | `02-01` → `02-06` | Same app via Kustomize overlays and via a Helm chart |
| 4 | Networking I | `03-01` → `03-05` | Trace a ClusterIP packet through the rules; break DNS and fix it |
| 5 | Networking II | `03-06` → `03-09` | Gateway API traffic split; default-deny NetworkPolicy with Cilium |
| 6 | Storage | `04-01` → `04-05` | StatefulSet with per-replica PVCs; reclaim policies |
| 7 | Scheduling and autoscaling | `05-01` → `05-07` | HPA under load; drain a node respecting a PDB |
| 8 | Security for the CKA | `06-01` → `06-03` | Create a user from a CSR; least-privilege RBAC; ServiceAccount tokens |
| 9 | Observability and troubleshooting | `08-01` → `08-06` | 10 broken-cluster scenarios, timed |
| 10 | Cluster administration (deferred — written later) | `07-01` → `07-06` | kubeadm cluster on VMs; upgrade one minor version; etcd backup/restore |
| 11 | Mock exams | — | Two timed CKA mocks + killer.sh; re-lab weak areas; then book the exam |
| *after* | *Optional* | `06-04` → `06-09`, `08-07`, Domains 9–10 | CKS path, operators, platform engineering |

**Daily habit from week 1:** 10 minutes of `00-05` drills, timed, in bash.

---

## 8. How to study each module (the loop that works)

1. **Read the object model first.** YAML is memorable only once you know what each field is *for*.
2. **Build it from YAML**, then **rebuild it imperatively** with `kubectl create … --dry-run=client -o yaml`. Compare.
3. **Watch it happen** — `kubectl get events -w` or `kubectl get pods -w` in a second terminal while you apply.
4. **Break it on purpose.** Every lab has a break-it step. Read the symptom *before* reading the cause.
5. **Answer the self-check closed-book.** Retrieval, not recognition.
6. **Clean up** — `labs/clean-labs.sh`. Rebuilding next time is the practice.

### The lab rules

- Every lab runs in its **own namespace labelled `course=k8s`**. Cleanup is one command:
  `kubectl delete namespace -l course=k8s`.
- The cluster itself is disposable. If you break it beyond repair, `labs/cluster-down.sh` then
  `labs/cluster-up.sh` gives you a fresh one in about a minute. **Breaking it is allowed.**
- Everything runs in **bash on the Ubuntu lab machine**, against **kind** (free, local) — Domains
  0–6, 8 and 9. Domain 7 needs **VMs** for kubeadm; how to provide them is decided when that domain
  is written.

---

## 9. Known point-losers, with the correction

| Belief | Correction | Module |
|---|---|---|
| A container is a lightweight VM | It is a Linux **process** with namespaces and cgroups applied. Same kernel as the host | `00-01` |
| Kubernetes removed Docker, so Docker images don't work | It removed **dockershim** (1.24). Images are OCI — they run on containerd/CRI-O unchanged | `00-01` |
| `kubectl` talks to the nodes | It talks **only to the API server**. So does every other component; only the API server talks to etcd | `00-03` |
| The scheduler starts the Pod | The scheduler only writes `spec.nodeName`. The **kubelet** on that node starts it | `00-03` |
| Deleting a Pod of a Deployment removes it | The ReplicaSet notices the count is short and creates a new one. Scale or delete the owner | `00-03`, `00-06` |
| A namespace is a security boundary | By itself it is only a **name scope**. Isolation needs RBAC, NetworkPolicy, quotas, Pod Security | `00-04`, `06-*` |
| `kubectl apply` and `kubectl create` are interchangeable | `create` fails if it exists; `apply` merges and records ownership of fields | `00-05` |
| A Service routes to a Deployment | It routes to **Pods whose labels match its selector** — Deployment not involved | `00-06`, `03-02` |
| Secrets are encrypted | They are **base64-encoded** — and stored plaintext in etcd unless encryption at rest is configured | `02-02`, `06-07` |
| A liveness probe should check dependencies | Then a database blip restarts every Pod. Liveness = "this process is wedged"; readiness = "send me traffic" | `01-08` |
| CPU limit protects you like a memory limit | Exceeding CPU → **throttled**; exceeding memory → **OOMKilled** | `00-01`, `01-09` |
| NetworkPolicy works on every cluster | Only if the **CNI enforces it**. An unenforced policy is silently ignored | `03-07` |
| Two selectors in one `from` item are OR | Inside one item they are **AND**; separate items are OR. A single `-` changes the meaning | `03-07` |
| You can skip minor versions when upgrading | Control plane upgrades go **one minor at a time** | `07-02` |
| An etcd backup restores in place | Restore goes to a **new data dir**, then the static Pod manifest is pointed at it | `07-03` |

---

## 10. Resources worth using

- **kubernetes.io/docs** — authoritative and allowed during the CNCF exams. Learn to navigate it fast.
- **`kubectl explain <resource>.<field> --recursive`** — the API reference in your terminal.
- **Kubernetes the Hard Way** (Kelsey Hightower) — build every component by hand once (Domain 7).
- **killer.sh** — exam simulator, two sessions included with each CNCF exam purchase. Harder than the real exam.
- **Books:** *Kubernetes Up & Running* (3rd ed.), *Kubernetes Patterns* (2nd ed.), *Programming Kubernetes* (Domain 9).
- **Source code:** `kubernetes/kubernetes` on GitHub, `pkg/controller/` — read the ReplicaSet controller once.

---

## 11. Roadmap — what exists and what comes next

### Built

- ✅ **Domain 0 — Foundations**, seven modules (six on the full ten-part template + the object catalogue)
- ✅ **`labs/`** — kind cluster config, `cluster-up`/`cluster-down`, `new-lab`, `clean-labs` (bash)
- ✅ **`reference/glossary.md`** and **`reference/kubectl-cheatsheet.md`**
- ✅ **`practice/00-foundations-exam.md`** — 25 questions + 5 hands-on tasks with worked answers
- ✅ **Domain 1–10 READMEs** — planned module lists and per-domain point-losers
- ✅ **Published page:** [Kubernetes Foundations](https://claude.ai/artifact/Rx7WqRDiWXvyH6VeWzYkBC) — source in `site/foundations.html`

### Next, in order (CKA-first)

1. **Domain 1 — Workloads** (9 modules).
2. **Domain 2 — Configuration and packaging** (6).
3. **Domain 3 — Networking** (9).
4. **Domain 4 — Storage**, **Domain 5 — Scheduling**, **Domain 6 `06-01`–`06-03`**, **Domain 8**.
5. **Domain 7 — Cluster administration** (deferred by choice; required before the mocks).
6. **CKA mock exams** in `practice/`.
7. Optional: rest of Domain 6, Domains 9–10.

Each domain ships with its modules, a practice exam in `practice/`, new glossary entries and any
lab files in `labs/`.
