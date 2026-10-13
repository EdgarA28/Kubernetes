# Domain 8 — Observability and troubleshooting

Logs, events, metrics and a systematic method for broken applications, nodes and control planes. Troubleshooting is **30% of the CKA** — the biggest single domain.

**Prerequisites:** Domains 0–7.
**Exams:** CKA (Troubleshooting 30%), CKAD (Observability & maintenance 15%).

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 08-01 | Logs and events | Container logs, `--previous`, rotation, cluster logging architectures | Planned |
| 08-02 | Metrics | metrics-server, `kubectl top`, Prometheus, Grafana, kube-state-metrics | Planned |
| 08-03 | Debugging Pods | `kubectl debug`, ephemeral containers, distroless images | Planned |
| 08-04 | Troubleshooting applications | Pending, CrashLoopBackOff, ImagePullBackOff, CreateContainerConfigError, OOMKilled | Planned |
| 08-05 | Troubleshooting nodes | NotReady, kubelet/runtime down, pressure conditions | Planned |
| 08-06 | Troubleshooting the control plane | Broken static Pods, certificates, etcd | Planned |
| 08-07 | Tracing and OpenTelemetry | The third pillar | Planned |

## Key point-losers in this domain

- Events expire (~1 hour by default); a quiet `describe` on an old failure proves nothing.
- `kubectl top` needs metrics-server — "Metrics API not available" is not a cluster fault.
- When the API server is down, `kubectl logs` cannot help: use `crictl` and `/var/log/pods/` on the node.
- `kubectl debug node/<name> -it --image=busybox` gives a shell with the node's filesystem at `/host`.
