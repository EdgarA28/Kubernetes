# Domain 10 — Production and platform engineering

Running Kubernetes as a platform: GitOps, progressive delivery, service mesh, multi-tenancy, disaster recovery and cost — finished with a capstone.

**Prerequisites:** the whole course.
**Exams:** none — this is where the exams stop and the job starts.
**Lab environment:** kind; the second half of the capstone on **AKS** (costs money — tear down in the same session).

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 10-01 | GitOps | Argo CD and Flux, app-of-apps, drift detection | Planned |
| 10-02 | Progressive delivery | Canary and blue/green with Argo Rollouts or Flagger | Planned |
| 10-03 | Service mesh | Istio (sidecar and ambient), Linkerd; mTLS, traffic policy | Planned |
| 10-04 | Multi-tenancy | Namespace-per-team, vCluster, policy | Planned |
| 10-05 | Backup and disaster recovery | Velero, etcd snapshots, multi-cluster | Planned |
| 10-06 | Cost and capacity | Rightsizing, requests hygiene, spot nodes | Planned |
| 10-07 | Capstone | A production-grade platform on kind, then on AKS | Planned |

## Key point-losers in this domain

- GitOps means the cluster pulls from Git; a manual `kubectl apply` is drift and will be reverted.
- A backup you have never restored is not a backup.
- A mesh's mTLS secures Pod-to-Pod traffic, not traffic to the API server or to the outside world.
