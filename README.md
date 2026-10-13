# Kubernetes — from first principles to advanced: complete study guide

A course to **revise and re-learn Kubernetes properly**: from what a container actually is, through
workloads, networking, storage, scheduling and security, to running clusters, extending the API and
operating Kubernetes as a platform. Every object is explained rather than assumed, and every module
ends in a hands-on lab you implement yourself.

Written against **Kubernetes v1.36**. **Target: the CKA exam.** Labs run in **bash on an Ubuntu lab machine**, on
**kind** (Kubernetes in Docker) — free.

---

## Start here

| If you… | Go to |
|---|---|
| Are starting the course | [`00-foundations/00-01`](00-foundations/00-01-containers-and-why-orchestration.md) — read Domain 0 in order |
| Want the full topic map, schedule and exam mapping | [`k8s-study-plan.md`](k8s-study-plan.md) |
| Need a cluster now | [`00-foundations/00-02`](00-foundations/00-02-lab-environment-kind.md), then `labs/cluster-up.sh` |
| Just finished a lab | Run [`labs/clean-labs.sh`](labs/clean-labs.sh) |
| Broke the cluster beyond repair | `labs/cluster-down.sh` then `labs/cluster-up.sh` — about a minute |
| Want every Kubernetes object on one map | [`00-foundations/00-07`](00-foundations/00-07-object-catalogue.md) — the object catalogue |
| Need a term defined | [`reference/glossary.md`](reference/glossary.md) |
| Need a command | [`reference/kubectl-cheatsheet.md`](reference/kubectl-cheatsheet.md) |
| Want to test myself on the foundations | [`practice/00-foundations-exam.md`](practice/00-foundations-exam.md) — score 20+ before Domain 1 |

---

## Structure

```
kubernetes/
├── README.md                  ← you are here
├── k8s-study-plan.md          ← master plan: goals, topic map, schedule, exam mapping, roadmap
├── 00-foundations/            ← containers, lab setup, architecture, the API, kubectl  ✅ complete
├── 01-workloads/              ← Pods, Deployments, StatefulSets, Jobs, probes, resources
├── 02-configuration/          ← ConfigMaps, Secrets, Kustomize, Helm
├── 03-networking/             ← Services, DNS, Ingress, Gateway API, NetworkPolicy, CNI
├── 04-storage/                ← volumes, PV/PVC, StorageClass, CSI
├── 05-scheduling/             ← affinity, taints, quotas, autoscaling, PDBs
├── 06-security/               ← authn, RBAC, Pod Security, admission, supply chain
├── 07-cluster-admin/          ← kubeadm, upgrades, etcd, certificates, HA, AKS
├── 08-observability/          ← logs, metrics, systematic troubleshooting
├── 09-extending/              ← CRDs, controllers, operators, webhooks
├── 10-production/             ← GitOps, service mesh, multi-tenancy, DR, capstone
├── labs/                      ← kind config + cluster and cleanup scripts
├── reference/                 ← glossary, kubectl cheat sheet
└── practice/                  ← question banks per domain + mock exams
```

---

## Domain 0 — Foundations ✅

| # | Module | Covers |
|---|---|---|
| 00-01 | [Containers, and why orchestration exists](00-foundations/00-01-containers-and-why-orchestration.md) | Namespaces, cgroups, images and layers, OCI, the runtime stack, what Kubernetes is and is not |
| 00-02 | [Lab environment: kind, kubectl and the tooling](00-foundations/00-02-lab-environment-kind.md) | Install the tools, create a 3-node cluster, kubeconfig contexts, the lab rules |
| 00-03 | [Cluster architecture](00-foundations/00-03-cluster-architecture.md) | Every control plane and node component, what happens on `kubectl apply`, static Pods |
| 00-04 | [The API and the object model](00-foundations/00-04-api-and-object-model.md) | Groups/versions/kinds, spec vs status, labels, namespaces, owners, finalizers, YAML traps |
| 00-05 | [kubectl fluency](00-foundations/00-05-kubectl-fluency.md) | kubeconfig, verbs, output formats, generating YAML, apply vs create, patch |
| 00-06 | [Your first application, end to end](00-foundations/00-06-first-app-end-to-end.md) | Pod → Deployment → Service → scale → rollout → rollback → debug |
| 00-07 | [The object catalogue](00-foundations/00-07-object-catalogue.md) | Every built-in kind: what it is, contains, connects to, who acts on it, CKA weight |

---

## Domains 1–10

Each module follows the same ten-part template:

1. Why this exists
2. The object model
3. Concepts
4. Declarative YAML
5. Imperative `kubectl`
6. Under the hood
7. Decision table
8. Gotchas and exam traps
9. Lab — build → verify → **break it** → fix → clean up
10. Self-check with answers

| Domain | Level | Status |
|---|---|---|
| [1 — Workloads](01-workloads/) | Basic → Intermediate | Planned |
| [2 — Configuration and packaging](02-configuration/) | Intermediate | Planned |
| [3 — Networking](03-networking/) | Intermediate → Advanced | Planned |
| [4 — Storage](04-storage/) | Intermediate | Planned |
| [5 — Scheduling and autoscaling](05-scheduling/) | Intermediate → Advanced | Planned |
| [6 — Security](06-security/) | Advanced | Planned |
| [7 — Cluster administration](07-cluster-admin/) | Advanced | Deferred — written after Domain 8 |
| [8 — Observability and troubleshooting](08-observability/) | Intermediate → Advanced | Planned |
| [9 — Extending Kubernetes](09-extending/) | Expert | Optional (`09-01` is CKA) |
| [10 — Production and platform](10-production/) | Expert | Optional |

---

## Rules of this course

1. **Every lab runs in its own namespace labelled `course=k8s`.** Cleanup is `kubectl delete ns -l course=k8s`.
2. **Breaking things is part of the lab.** The cluster is disposable; recreating it takes a minute.
3. **Every object is shown as YAML and as imperative `kubectl`.** One for Git, one for speed.
4. **Nothing is magic.** If something happens, the module says which component did it.
5. **Retrieval over re-reading.** Do every self-check closed-book before opening the answers.

---

## Progress tracker

- [ ] `00-foundations` read end to end
- [ ] Ubuntu lab machine: Docker Engine, kubectl, kind, bash/vim setup (`00-02`); `labs/cluster-up.sh` creates a 3-node kind cluster
- [ ] Scheduler broken and repaired (`00-03` lab)
- [ ] Capstone app built and torn down (`00-06`)
- [ ] CoreDNS dissected (`00-07` lab)
- [ ] Foundations exam: 20+ / 25
- [ ] Domain 1 · 2 · 3 · 4 · 5 · 6 · 7 · 8 · 9 · 10
- [ ] CKA mock exams: mock 1 · mock 2 · killer.sh session 1 · killer.sh session 2
- [ ] CKA booked · CKA passed
