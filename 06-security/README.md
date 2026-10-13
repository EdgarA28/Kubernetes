# Domain 6 — Security

Who can do what (authentication, RBAC), what Pods may do (securityContext, Pod Security), what gets admitted (admission control), and the supply chain and runtime.

**Prerequisites:** Domains 1–5; [`00-03`](../00-foundations/00-03-cluster-architecture.md) §3.1 (the API request pipeline).
**Exams:** CKA (RBAC, ServiceAccounts), CKAD (securityContext, ServiceAccounts), CKS (all of it, in depth).

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 06-01 | Authentication | X.509 client certs, ServiceAccount tokens, OIDC; there is no User object | Planned |
| 06-02 | RBAC | Role/ClusterRole/bindings, aggregation, `auth can-i`, least privilege | Planned |
| 06-03 | ServiceAccounts | Automount, projected tokens, workload identity | Planned |
| 06-04 | securityContext | runAsNonRoot, capabilities, readOnlyRootFilesystem, seccomp, AppArmor | Planned |
| 06-05 | Pod Security Standards and Admission | privileged/baseline/restricted; enforce/audit/warn | Planned |
| 06-06 | Admission control | ValidatingAdmissionPolicy (CEL), webhooks, Kyverno vs Gatekeeper | Planned |
| 06-07 | Secrets at rest | EncryptionConfiguration, KMS, external secret stores | Planned |
| 06-08 | Supply chain | Trivy scanning, cosign signing, SBOMs, minimal images | Planned |
| 06-09 | Runtime security and audit | Audit policy, Falco, gVisor/Kata | Planned |

## Key point-losers in this domain

- RBAC is **additive only** — there are no deny rules.
- A **ClusterRole bound with a RoleBinding** grants its permissions only in that RoleBinding's namespace.
- Kubernetes has **no User objects**; users are just names in certificates or tokens.
- Permission to create Pods in a namespace effectively grants access to every Secret and ServiceAccount there.
- PodSecurityPolicy was removed in v1.25; Pod Security Admission is configured with **namespace labels**.
