# Domain 9 — Extending Kubernetes

Turning Kubernetes into your own API: custom resources, controllers, operators and webhooks.

**Prerequisites:** Domains 0–8; [`00-03`](../00-foundations/00-03-cluster-architecture.md) (controllers) and [`00-04`](../00-foundations/00-04-api-and-object-model.md) (the object model) are the foundation for everything here.
**Exams:** CRDs and operators appear in the CKA curriculum at the "understand and install" level; the rest goes beyond the exams.
**Tooling:** Go and kubebuilder (installed when the domain starts).

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 09-01 | CustomResourceDefinitions | OpenAPI schemas, versions, printer columns, status/scale subresources, CEL validation | Planned |
| 09-02 | The controller pattern | Informers, caches, work queues, reconcile, idempotency | Planned |
| 09-03 | Writing an operator | kubebuilder end to end; owner refs, finalizers, status conditions | Planned |
| 09-04 | Admission webhooks | Mutating and validating webhooks, certificates, failure policy | Planned |
| 09-05 | Scheduler and API extensions | Scheduler profiles/plugins, API aggregation | Planned |
| 09-06 | Dynamic Resource Allocation | Devices and GPUs | Planned |

## Key point-losers in this domain

- A CRD without a controller is just storage — nothing happens when you create the object.
- Reconcile must be **idempotent**: it runs again and again with the same input.
- A webhook with `failurePolicy: Fail` that is down blocks every matching request — possibly including the ones needed to fix it.
