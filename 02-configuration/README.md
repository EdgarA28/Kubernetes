# Domain 2 — Configuration and packaging

Getting configuration and secrets into Pods, and packaging whole applications with Kustomize and Helm.

**Prerequisites:** Domain 1.
**Exams:** CKAD (Environment, configuration & security), CKA (Helm and Kustomize are in the current curriculum).

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 02-01 | ConfigMaps | env, envFrom, volume mounts, update propagation, immutable ConfigMaps | Planned |
| 02-02 | Secrets | Types, base64 ≠ encryption, projected volumes, imagePullSecrets | Planned |
| 02-03 | Downward API and projected volumes | Pod metadata and resources inside the container | Planned |
| 02-04 | Kustomize | Bases, overlays, patches, generators, `apply -k` | Planned |
| 02-05 | Helm | Charts, values, templates, releases, upgrade/rollback, writing a chart | Planned |
| 02-06 | Organising manifests | Recommended labels, repository layout, environments | Planned |

## Key point-losers in this domain

- ConfigMaps mounted as **volumes** update (eventually); consumed as **env vars** they never do — the Pod must restart. `subPath` mounts never update.
- `kubectl get secret -o yaml` shows base64, which anyone can decode. Secrets are plaintext in etcd unless encryption at rest is configured.
- A missing ConfigMap/Secret key → `CreateContainerConfigError`, unless marked `optional: true`.
- `helm upgrade --install` is idempotent; `helm rollback` creates a **new** revision.
