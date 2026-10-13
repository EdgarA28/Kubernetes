# Domain 1 — Workloads

Pods and the controllers that run them. Everything later in the course is built on these objects.

**Prerequisites:** all of [`00-foundations`](../00-foundations/) — especially [`00-03`](../00-foundations/00-03-cluster-architecture.md) (who reconciles what) and [`00-06`](../00-foundations/00-06-first-app-end-to-end.md).
**Exams:** CKAD (App design & build, App deployment), CKA (Workloads & scheduling).

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 01-01 | Pods in depth | Lifecycle, phases, container states, restartPolicy, command/args, termination, `preStop` | Planned |
| 01-02 | Multi-container Pods | Init containers, native sidecars, ambassador/adapter, shared volumes & network | Planned |
| 01-03 | ReplicaSets and Deployments | Selectors, pod-template-hash, adoption, scaling | Planned |
| 01-04 | Rollouts | RollingUpdate vs Recreate, maxSurge/maxUnavailable, history, undo, pause; blue/green & canary with plain objects | Planned |
| 01-05 | DaemonSets | One per node, update strategies, node targeting | Planned |
| 01-06 | StatefulSets | Stable identity, ordering, headless Service, volumeClaimTemplates, partitions | Planned |
| 01-07 | Jobs and CronJobs | completions, parallelism, backoffLimit, indexed Jobs, TTL, concurrencyPolicy, time zones | Planned |
| 01-08 | Probes | liveness, readiness, startup; exec/http/tcp/grpc; how bad probes cause outages | Planned |
| 01-09 | Resources and QoS | requests vs limits, throttling vs OOM, QoS classes, eviction, in-place resize | Planned |

## Key point-losers in this domain

- `restartPolicy` is set on the **Pod**, not per container (native sidecars are the exception), and Deployments allow only `Always`.
- A Job's Pod template needs `restartPolicy: Never` or `OnFailure`.
- Liveness probes that check dependencies turn a database blip into a cluster-wide restart storm.
- A Pod is **Guaranteed** only if every container has requests == limits for CPU and memory; no requests or limits anywhere makes it **BestEffort**.
- Scaling a StatefulSet down does **not** delete its PVCs.
