# Domain 4 — Storage

Data that outlives a container, a Pod, or a node.

**Prerequisites:** Domains 1 and 2.
**Exams:** CKA (Storage 10%), CKAD (volumes).

## Planned modules

| # | Module | Covers | Status |
|---|---|---|---|
| 04-01 | Volumes | emptyDir, hostPath, configMap/secret, projected; lifetimes | Planned |
| 04-02 | PersistentVolumes and Claims | Binding, access modes, reclaim policies, volumeMode | Planned |
| 04-03 | StorageClasses and dynamic provisioning | WaitForFirstConsumer, expansion, default class | Planned |
| 04-04 | CSI | Drivers, snapshots, clones, ephemeral volumes | Planned |
| 04-05 | Stateful workloads in practice | Replicated database on a StatefulSet; surviving node loss | Planned |

## Key point-losers in this domain

- Access modes describe **node** attachment (`ReadWriteOnce` = one node, not one Pod); `ReadWriteOncePod` is one Pod.
- A PVC binds to a PV only if size, access mode, StorageClass (and selector) all match.
- `Retain` keeps the PV and its data after the PVC is deleted, but the PV goes `Released` and will not rebind automatically.
- `emptyDir` survives container restarts but not Pod deletion.
