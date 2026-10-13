# Domain 3 — Networking

How Pods get IPs, how Services and DNS work, how traffic gets in (Ingress, Gateway API), and how to restrict it (NetworkPolicy).

**Prerequisites:** Domains 0–1; [`00-06`](../00-foundations/00-06-first-app-end-to-end.md) §6 (one request, end to end).
**Exams:** all three — Services & networking is 20% of CKA and CKAD.
**Lab environment:** kind; a second kind config with **Cilium** (or Calico) replaces kindnet for the NetworkPolicy and eBPF labs.

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 03-01 | The Kubernetes network model | Pod IPs, flat network, Pod CIDR vs Service CIDR, CNI | Planned |
| 03-02 | Services | ClusterIP, NodePort, LoadBalancer, ExternalName, headless; EndpointSlices; session affinity | Planned |
| 03-03 | kube-proxy internals | iptables, nftables and IPVS modes; tracing a packet | Planned |
| 03-04 | DNS and CoreDNS | Service/Pod records, search domains, `ndots`, debugging | Planned |
| 03-05 | Ingress | Controllers, rules, TLS, pathType; the ingress-nginx retirement | Planned |
| 03-06 | Gateway API | GatewayClass, Gateway, HTTPRoute, traffic splitting, role separation | Planned |
| 03-07 | NetworkPolicy | Default deny, ingress/egress, selectors, the AND/OR trap, DNS egress | Planned |
| 03-08 | CNI deep dive | veth, bridges, routing vs overlay, Calico, Cilium/eBPF | Planned |
| 03-09 | Troubleshooting networking | A decision tree from symptom to root cause | Planned |

## Key point-losers in this domain

- NetworkPolicy is **ignored** unless the CNI enforces it.
- In a NetworkPolicy `from:` list, `namespaceSelector` and `podSelector` in **one item** are AND; in **separate items** they are OR.
- A default-deny **egress** policy also blocks DNS — allow UDP/TCP 53 to kube-dns.
- A headless Service (`clusterIP: None`) returns Pod IPs from DNS; kube-proxy does no load balancing for it.
- `LoadBalancer` stays `<pending>` without a cloud controller (or MetalLB / cloud-provider-kind locally).
