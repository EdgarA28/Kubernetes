# Domain 5 — Scheduling and autoscaling

Controlling where Pods run, how many run, and what may disrupt them.

**Prerequisites:** Domains 1 and 4; [`00-03`](../00-foundations/00-03-cluster-architecture.md) §3.3.
**Exams:** CKA (Workloads & scheduling), CKAD (quotas, resources).

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 05-01 | The scheduler | Filter and score, nodeName, nodeSelector, scheduling failures | Planned |
| 05-02 | Affinity and anti-affinity | Node and Pod; required vs preferred | Planned |
| 05-03 | Taints and tolerations | Effects, control-plane taint, taint-based eviction | Planned |
| 05-04 | Topology spread, priority and preemption | topologySpreadConstraints, PriorityClass | Planned |
| 05-05 | ResourceQuota and LimitRange | Multi-team clusters | Planned |
| 05-06 | Autoscaling | HPA, VPA, Cluster Autoscaler vs Karpenter, KEDA | Planned |
| 05-07 | Disruption | PodDisruptionBudgets, drain, voluntary vs involuntary | Planned |

## Key point-losers in this domain

- The scheduler uses **requests**, never actual usage or limits.
- A toleration **allows** a Pod onto a tainted node; it does not **attract** it there — use affinity for that.
- With a ResourceQuota on cpu/memory, every Pod must declare requests/limits (or get them from a LimitRange) or it is rejected.
- The HPA needs metrics-server and container **requests** to compute utilisation.
- A PDB with `maxUnavailable: 0` blocks `kubectl drain` indefinitely.
