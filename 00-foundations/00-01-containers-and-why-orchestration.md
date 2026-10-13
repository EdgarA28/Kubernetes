# 00-01 — Containers, and why orchestration exists

> **Module type:** Foundation
> **Time:** ~75 minutes (45 reading, 30 lab)
> **Prerequisites:** basic Linux shell; the Ubuntu lab machine with Docker Engine (`00-02` step 2)
> **Maps to:** CKA/CKAD assume all of it silently — exit codes, image references, the runtime stack and resource limits all reappear in troubleshooting questions

---

## 1. Why this module exists

Kubernetes is a system for running **containers** across many machines. Almost every confusing
Kubernetes symptom — `OOMKilled`, exit code 137, `ImagePullBackOff`, "it works locally but not in
the Pod", a Pod that ignores `kubectl delete` for 30 seconds — is a **container** behaviour, not a
Kubernetes behaviour. If the layer underneath is fuzzy, those symptoms look like magic.

This module rebuilds that layer: what a container really is on Linux, what an image is, who
actually runs containers in a Kubernetes cluster, and what problem orchestration solves that a
single `docker run` cannot.

---

## 2. The object model — what a container is made of

```mermaid
graph TD
    IMG["Image<br/><i>read-only layers + config (OCI)</i>"] -->|unpacked by| RT["Container runtime<br/><i>containerd / CRI-O → runc</i>"]
    RT --> P["Linux process (PID 1 in the container)"]
    NS["Namespaces<br/><i>what the process can SEE</i><br/>pid · net · mnt · uts · ipc · user · cgroup"] --> P
    CG["cgroups<br/><i>what the process can USE</i><br/>cpu · memory · pids · io"] --> P
    FS["Union filesystem (overlayfs)<br/><i>image layers + one writable layer</i>"] --> P
    K["Host kernel<br/><i>shared by every container on the machine</i>"] --- P
```

**A container is a normal Linux process** with three things applied to it:

| Ingredient | Controls | Analogy |
|---|---|---|
| **Namespaces** | What the process can **see** — its own PID tree, network stack, hostname, mounts | Blinkers on a horse |
| **cgroups** (control groups) | What the process can **use** — CPU time, memory, number of PIDs, disk I/O | A fuse box |
| **A layered root filesystem** | What files it sees as `/` | A stack of transparent sheets |

There is **no guest kernel**. Every container on a node uses the node's kernel. That is why
containers start in milliseconds, and also why a container is a weaker isolation boundary than a VM.

---

## 3. Concepts

### 3.1 Namespaces — isolation of *view*

| Namespace | Isolates | What you notice inside the container |
|---|---|---|
| `pid` | Process IDs | Your app is PID 1; you cannot see host processes |
| `net` | Network interfaces, IPs, routes, ports, iptables | Its own `eth0`, its own IP, port 80 free even if the host uses it |
| `mnt` | Mount points | Its own `/` |
| `uts` | Hostname | `hostname` returns the container ID (or the Pod name, in Kubernetes) |
| `ipc` | Shared memory, semaphores | — |
| `user` | UID/GID mapping | root inside can map to an unprivileged UID outside (not default in Docker) |
| `cgroup` | The view of `/sys/fs/cgroup` | Sees only its own cgroup |

> **Kubernetes link:** all containers in one **Pod share the `net` namespace** (and optionally
> `pid`). That is why two containers in a Pod reach each other on `localhost`, and why they cannot
> both bind port 8080. The Pod *is* a set of shared namespaces. More in `01-02`.

### 3.2 cgroups — limits on *use*

**cgroups** (control groups) are a Linux kernel feature that **limits and measures** how much of
the machine's resources a group of processes can use: CPU, memory, number of processes, disk I/O.
Namespaces decide what a process can *see*; cgroups decide what it can *use*. Modern systems
(including Ubuntu 22.04+ and every current Kubernetes node) use **cgroup v2**.

**How they work.** The kernel organises processes into a tree of groups under `/sys/fs/cgroup/`.
Each group is a directory of small files holding its limits and its current usage; the kernel
enforces the limits for every process in the group.

```
/sys/fs/cgroup/<some group>/
├── memory.max      → 67108864        64 MiB limit
├── memory.current  → 23412736        what the group uses right now
├── cpu.max         → 50000 100000    50 ms of CPU per 100 ms period = half a core
├── cpu.weight      → 100             relative share when CPUs are contended
├── cpu.stat        → … nr_throttled, throttled_usec   how often and how long it was throttled
└── pids.max        → max number of processes (fork-bomb protection)
```

`docker run --memory 64m --cpus 0.5` does nothing more than write those files. You read them
yourself in lab step 9.3.

The two limits that matter most, and that behave **completely differently**:

| Resource | When the limit is reached | Symptom |
|---|---|---|
| **Memory** | The kernel's OOM killer **kills** the process (`SIGKILL`) | Exit code **137**; in Kubernetes, `OOMKilled` |
| **CPU** | The process is **throttled** — it waits for its next time slice | Slow, high latency; *no* error, *no* restart |

Memory is **incompressible** (you cannot take memory back gradually, so the only enforcement is a
kill), CPU is **compressible** (time can simply be handed out more slowly). Memorise this pair —
it is the basis of Kubernetes requests, limits and QoS in `01-09`. Lab step 9.4 triggers an OOM
kill on purpose.

**Why cgroups matter in Kubernetes:**

| Kubernetes setting | What it becomes in the cgroup |
|---|---|
| `resources.limits.memory` | `memory.max` — exceed it and the container is OOMKilled |
| `resources.limits.cpu` | `cpu.max` — exceed it and the container is throttled |
| `resources.requests.cpu` | `cpu.weight` — its share of CPU when the node is busy |
| `resources.requests` (CPU and memory) | Not a cgroup limit for memory: the **scheduler** uses requests to decide which node has room (`00-03`, Domain 5) |

- Every Pod gets its own cgroup, with one child cgroup per container; the kubelet creates them
  through the container runtime.
- The kubelet and the runtime must use the **same cgroup driver**. On systemd-based nodes that
  means `cgroupDriver: systemd` in the kubelet config and `SystemdCgroup = true` in containerd's
  `config.toml`. A mismatch is a classic broken-node fault (containerd card, `00-03` §3.10).

> **CKA symptom pair:** *"the app is slow but never restarts"* → a CPU limit is throttling it
> (`cpu.stat` shows `nr_throttled` climbing). *"It keeps restarting with exit code 137"* → the
> memory limit and `OOMKilled`.

### 3.3 Images — the package

An **image** is a set of read-only filesystem **layers** plus a **config** (default command,
environment, working directory, user, exposed ports). The format is standardised by the **OCI**
(Open Container Initiative) image spec, so an image built by Docker, Podman, Buildah or BuildKit
runs on any OCI runtime.

```
nginx:1.27
├── config            ← Entrypoint, Cmd, Env, User, WorkingDir, ExposedPorts
└── layers (bottom → top)
    ├── sha256:aaa…   debian base filesystem
    ├── sha256:bbb…   apt-get install nginx
    └── sha256:ccc…   copy default config
            +
        [writable layer]  ← created per container, discarded when the container is removed
```

- Each Dockerfile instruction that changes files creates a layer. Layers are **shared** between
  images and cached, so pulling a second image built on the same base is fast.
- A running container gets one **thin writable layer** on top (copy-on-write via **overlayfs**).
  Anything written there **disappears when the container is removed**. This is why containers are
  treated as disposable, and why Kubernetes needs volumes (Domain 4).

### 3.4 Image references: tag vs digest

```
registry.k8s.io/pause:3.10
└──────┬──────┘└─┬─┘ └┬─┘
    registry   repo   tag          ← mutable: someone can push a new image to the same tag

docker.io/library/nginx@sha256:4c0fdaa8b634…   (64 hex characters in full)
                        └──────── digest ────────┘
                                                   ← immutable: content-addressed hash
```

| Part | Default if omitted |
|---|---|
| Registry | `docker.io` |
| Namespace on Docker Hub | `library/` for official images (`nginx` = `docker.io/library/nginx`) |
| Tag | `latest` — which is just a tag name, **not** "the newest version" |

> **Kubernetes link:** the default `imagePullPolicy` is `Always` when the tag is `:latest` (or
> missing), and `IfNotPresent` otherwise. A typo anywhere in the reference produces
> `ErrImagePull` → `ImagePullBackOff`. Production manifests pin a **digest** or at least an
> immutable version tag.

### 3.5 Exit codes and signals

When you stop a container, the runtime sends **`SIGTERM`** to PID 1, waits a grace period, then
sends **`SIGKILL`**. Docker waits 10 s; Kubernetes waits `terminationGracePeriodSeconds`
(default **30 s**).

| Exit code | Meaning | Typical cause |
|---|---|---|
| `0` | Success | Process finished normally (a Job's happy ending) |
| `1` | Generic application error | Crash, bad config, uncaught exception |
| `126` / `127` | Command not executable / not found | Wrong `command:` in the manifest, missing binary in the image |
| `137` | 128 + 9 = **SIGKILL** | **OOM kill**, or killed after the grace period expired |
| `143` | 128 + 15 = **SIGTERM** | Graceful stop — the app exited when asked |

**The PID 1 trap:** PID 1 gets no default signal handlers from the kernel. If your image's command
is a shell (`CMD node server.js` in *shell form* runs `/bin/sh -c "node server.js"`), the shell is
PID 1, may not forward `SIGTERM`, and the app is killed hard after the grace period. Symptom in
Kubernetes: **every Pod deletion takes exactly 30 seconds**. Fix: exec form
(`CMD ["node","server.js"]`), `exec` in entrypoint scripts, or a tiny init like `tini`.

### 3.6 The runtime stack — who actually runs containers

```mermaid
graph LR
    KL["kubelet"] -->|CRI gRPC| CD["containerd<br/>or CRI-O<br/><i>high-level runtime</i>"]
    CD -->|OCI runtime spec| RC["runc<br/><i>low-level runtime</i>"]
    RC -->|clone() + cgroups| PR["container process"]
    DK["docker CLI"] --> DD["dockerd"] --> CD
```

| Layer | Job | Examples |
|---|---|---|
| **CRI** (Container Runtime Interface) | gRPC API the kubelet uses to ask for Pods and containers | — (an interface) |
| **High-level runtime** | Pulls images, manages snapshots, implements CRI | **containerd**, **CRI-O** |
| **Low-level (OCI) runtime** | Actually creates namespaces/cgroups and starts the process | **runc**, crun, gVisor `runsc`, Kata |

**"Kubernetes removed Docker"** — what really happened: until v1.24 the kubelet contained an
adapter called **dockershim** to talk to Docker Engine (which does not implement CRI). v1.24
deleted dockershim. Nodes now run containerd or CRI-O directly. **Images built with Docker are OCI
images and run unchanged.** Docker remains a perfectly good tool for *building* images.

On a Kubernetes node the debugging CLI is **`crictl`** (talks CRI), not `docker`. You will use it
in `00-03`.

### 3.7 What orchestration adds

`docker run` on one machine answers "run this process". Production needs answers to:

| Question | Without an orchestrator | Kubernetes object that answers it |
|---|---|---|
| Which machine should this run on? | You choose, by hand | **Scheduler** (`00-03`, Domain 5) |
| It crashed at 3 a.m. — restart it | A cron script, or you | **kubelet** restart policy; **ReplicaSet** replaces lost Pods |
| The machine died | Rebuild by hand | Controllers recreate Pods on other nodes |
| Run 10 copies; now 30 | Script it | **Deployment** `replicas`, **HPA** |
| How do clients find the copies, whose IPs keep changing? | Config files, a load balancer you maintain | **Service** + **DNS** (Domain 3) |
| Ship v2 without downtime; undo if bad | Careful manual choreography | **Rolling update** + **rollback** (`01-04`) |
| Config and passwords | Baked into images or files on hosts | **ConfigMap**, **Secret** (Domain 2) |
| Disks that follow the workload | NFS mounts by hand | **PersistentVolumeClaim** (Domain 4) |
| Who may do what | SSH keys and sudo | **RBAC** (Domain 6) |

**The core idea:** you do not tell Kubernetes *what to do*; you tell it **what you want to exist**
(desired state), and a set of **controllers** work continuously to make reality match. This is
called **declarative configuration** with **reconciliation**, and it is the single most important
idea in the course. `00-03` shows the machinery.

### 3.8 What Kubernetes is **not**

- **Not a PaaS.** It does not build your code, provide databases, or do CI. (Things built on it do.)
- **Not a VM manager.** It runs containers; the nodes are VMs or physical servers someone else
  provides.
- **Not a security boundary by default.** A fresh cluster lets any Pod talk to any Pod and runs
  containers as root if the image says so. Domain 6 fixes that.
- **Not one product.** It is an API plus pluggable parts: runtime (CRI), networking (CNI), storage
  (CSI), ingress/gateways, DNS. Two "Kubernetes" clusters can behave differently because of
  different plugins.

---

## 4. Declarative form — a Dockerfile, read properly

You will not write many Dockerfiles in this course, but you must be able to *read* one, because
its `ENTRYPOINT`/`CMD`/`USER` decide how the container behaves in a Pod.

```dockerfile
# ---- build stage: has compilers, is thrown away ----
FROM golang:1.24 AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /app ./cmd/server

# ---- runtime stage: only what runs ----
FROM gcr.io/distroless/static:nonroot     # no shell, no package manager
COPY --from=build /app /app
USER 65532:65532                          # non-root — matters for Pod Security (06-05)
EXPOSE 8080                               # documentation only; publishes nothing
ENTRYPOINT ["/app"]                       # exec form → /app is PID 1 and receives SIGTERM
CMD ["--port=8080"]                       # default arguments
```

How the image config maps onto a Kubernetes container spec — **learn this table, it is asked
constantly**:

| Image (Dockerfile) | Kubernetes container field | Rule |
|---|---|---|
| `ENTRYPOINT` | `command` | `command` **replaces** ENTRYPOINT |
| `CMD` | `args` | `args` **replaces** CMD |
| `ENV` | `env` | Merged; Pod spec wins |
| `WORKDIR` | `workingDir` | Pod spec wins |
| `USER` | `securityContext.runAsUser` | Pod spec wins |
| `EXPOSE` | `ports[].containerPort` | Both are informational |

---

## 5. Imperative form — the Docker commands you need

```bash
docker pull nginx:1.27                      # fetch an image
docker image ls                             # local images
docker image history nginx:1.27             # its layers and the instruction that made each
docker image inspect nginx:1.27             # full config (Entrypoint, Cmd, Env, digests…)

docker run -d --name web -p 8080:80 nginx:1.27   # run detached, publish host 8080 → container 80
docker ps                                   # running containers (-a for all)
docker logs -f web                          # stdout/stderr — exactly what `kubectl logs` shows
docker exec -it web sh                      # a shell inside the same namespaces
docker stop web                             # SIGTERM, wait 10s, SIGKILL
docker rm web                               # remove — the writable layer is gone
docker inspect web --format '{{.State.ExitCode}} {{.State.OOMKilled}}'
```

| Docker | Kubernetes equivalent (Domain 0 onward) |
|---|---|
| `docker run` | `kubectl run` / a Pod or Deployment |
| `docker ps` | `kubectl get pods` |
| `docker logs` | `kubectl logs` |
| `docker exec -it` | `kubectl exec -it` |
| `docker inspect` | `kubectl describe` / `kubectl get -o yaml` |
| `-p 8080:80` | a Service, or `kubectl port-forward` |
| `--memory`, `--cpus` | `resources.limits` |
| On a node: `docker ps` | On a node: **`crictl ps`** |

---

## 6. Under the hood — what `docker run` actually did

1. The CLI asked `dockerd` to create a container from `nginx:1.27`.
2. containerd checked its content store for the image's layers; pulled any missing ones by
   **digest** and unpacked them as **snapshots**.
3. It stacked the layers with **overlayfs** and added an empty writable layer.
4. It wrote an **OCI runtime spec** (`config.json`): the process to run, its env, mounts,
   namespaces to create, cgroup limits.
5. **runc** read the spec, called `clone()` with new namespace flags, placed the process into a
   new cgroup with the limits written into `/sys/fs/cgroup/…`, `pivot_root`-ed into the merged
   filesystem, dropped capabilities, and `exec`-ed the entrypoint. Then runc **exited** — the
   container process is not its child afterwards (a small `containerd-shim` keeps stdio and the
   exit status).

In Kubernetes, steps 2–5 are identical. Only step 1 changes: the **kubelet** asks containerd via
**CRI**, and first creates a **sandbox** (the "pause" container that holds the Pod's shared network
namespace).

---

## 7. Decision table — container or VM?

| Requirement | Choose |
|---|---|
| Many small services, fast start, dense packing, same OS kernel | **Containers** |
| A different kernel or OS (Windows app on Linux host) | **VM** (or Windows nodes in K8s) |
| Hostile multi-tenant code (customers' code on your hardware) | **VM**, or sandboxed runtimes (gVisor, Kata) — `06-09` |
| Kernel modules, custom kernel parameters | **VM** |
| Legacy app that expects to be a whole server (systemd, many daemons) | **VM** first; containerise later |

---

## 8. Gotchas and exam traps

1. **Exit code 137** means SIGKILL. In Kubernetes check `lastState.terminated.reason`: `OOMKilled`
   vs `Error`. Not every 137 is an OOM — exceeding the grace period also ends in SIGKILL.
2. **CPU limits throttle, memory limits kill.** "My app is slow but never restarts" → look at CPU
   throttling, not memory.
3. **`latest` is not a version** and changes `imagePullPolicy` to `Always`.
4. **`command` replaces `ENTRYPOINT`, `args` replaces `CMD`.** Setting `command` alone discards
   the image's CMD too.
5. **Writes inside the container are lost** when it is recreated. A Pod restart = a new
   container = a fresh writable layer.
6. **`docker` is not on Kubernetes nodes** (usually). Use `crictl`.
7. **`EXPOSE` publishes nothing.** Neither does `containerPort` — it is informational. A Service
   or `port-forward` is what makes traffic arrive.
8. **Shell-form CMD swallows SIGTERM.** Symptom: every graceful shutdown takes the full grace
   period.

---

## 9. Lab — see that a container is just a process

**Cost:** €0. **Needs:** Docker Engine on the Ubuntu lab machine — if it is not installed yet, do `00-02` steps 1–2 first, then come back. Run in bash.

### 9.1 Same kernel as the host

```bash
uname -r                                       # the host's kernel
docker run --rm alpine:3.20 uname -r           # identical: containers have no kernel of their own
```

✅ **Verify:** both print the same version.

### 9.2 Namespaces: what the process can see

```bash
docker run --rm alpine:3.20 ps aux              # only PID 1 (ps itself) — pid namespace
docker run --rm --pid=host alpine:3.20 ps aux   # now you see the host's processes — namespace NOT applied
docker run --rm alpine:3.20 hostname            # random container ID — uts namespace
docker run --rm alpine:3.20 ip addr             # its own eth0 with its own IP — net namespace
docker run --rm --network host alpine:3.20 ip addr   # the host's interfaces
```

✅ **Verify:** you can explain each difference by naming the namespace that was or was not applied.

> **Kubernetes link:** `hostPID: true` and `hostNetwork: true` in a Pod spec do exactly what
> `--pid=host` and `--network host` did here. That is why Pod Security (`06-05`) forbids them.

### 9.3 cgroups: what the process can use

```bash
docker run --rm --memory 64m alpine:3.20 cat /sys/fs/cgroup/memory.max
docker run --rm --cpus 0.5   alpine:3.20 cat /sys/fs/cgroup/cpu.max
```

✅ **Verify:** `memory.max` is `67108864` (64 × 1024 × 1024). `cpu.max` is `50000 100000` — 50 ms
of CPU per 100 ms period = half a core. Kubernetes writes these same files from `resources.limits`.

Now watch a CPU limit throttle instead of kill. The container spins a busy loop for 3 seconds on a
fifth of a core, then prints its own throttling counters:

```bash
docker run --rm --cpus 0.2 alpine:3.20 sh -c 'timeout 3 sh -c "while :; do :; done"; grep throttled /sys/fs/cgroup/cpu.stat'
```

✅ **Verify:** `nr_throttled` is well above zero and `throttled_usec` is close to 2.4 s (80% of the
3 s), yet the container exited normally. This is the "slow but never restarts" symptom.

### 9.4 Break it: an OOM kill

```bash
docker run --name oom --memory 32m --memory-swap 32m python:3.13-alpine \
  python -c "x = b'x' * (200 * 1024 * 1024); print('allocated')"
docker inspect oom --format 'exit={{.State.ExitCode}} oomkilled={{.State.OOMKilled}}'
docker rm oom
```

**Before reading on, predict the output.**

✅ **Verify:** `allocated` is never printed; `exit=137 oomkilled=true`. You will see exactly this
pair again in a Pod as `Last State: Terminated, Reason: OOMKilled, Exit Code: 137`.

### 9.5 Signals: graceful vs hard stop

```bash
# sleep is PID 1 and installs no SIGTERM handler → the kernel ignores SIGTERM for PID 1…
docker run -d --name s1 alpine:3.20 sleep 3600
time docker stop s1                                                 # ~10 s: waited, then SIGKILL
docker inspect s1 --format '{{.State.ExitCode}}'                      # 137

# …unless something handles it. A shell trap exits on SIGTERM:
docker run -d --name s2 alpine:3.20 sh -c 'trap "exit 0" TERM; while true; do sleep 1; done'
time docker stop s2                                                 # ~1 s
docker inspect s2 --format '{{.State.ExitCode}}'                      # 0
docker rm s1 s2
```

✅ **Verify:** you can explain why `s1` took ~10 s and exited 137 while `s2` stopped in about a
second. (PID 1 ignores signals it has no handler for; `s2` installed one.) In Kubernetes the
same `s1` would take **30 s** to delete.

### 9.6 Layers and digests

```bash
docker pull nginx:1.27
docker image history nginx:1.27
docker image inspect nginx:1.27 --format '{{json .RootFS.Layers}}'
docker image inspect nginx:1.27 --format '{{index .RepoDigests 0}}'
docker image inspect nginx:1.27 --format 'Entrypoint={{json .Config.Entrypoint}} Cmd={{json .Config.Cmd}}'
```

✅ **Verify:** write down nginx's `Entrypoint` and `Cmd`. Now answer: if a Pod sets
`args: ["nginx", "-g", "daemon off;"]` but no `command`, what runs? (Answer in the self-check.)

### 9.7 Clean up

```bash
docker container prune -f
```

---

## 10. Self-check

1. Name the three ingredients that turn a process into a container, and what each controls.
2. A container exceeds its CPU limit. What happens? Its memory limit?
3. A Pod restarts with exit code 137. List two possible causes and the field that distinguishes them.
4. Does Kubernetes v1.36 run Docker images? Does it run Docker Engine? Explain the difference.
5. What does `crictl` talk to, and why use it instead of `docker` on a node?
6. An image has `ENTRYPOINT ["/docker-entrypoint.sh"]` and `CMD ["nginx","-g","daemon off;"]` (nginx's real config). A Pod sets `command: ["sleep","3600"]` only. What runs?
7. Same image; a Pod sets `args: ["nginx","-g","daemon off;"]` only. What runs?
8. Every `kubectl delete pod` in a team takes 30 seconds. What is the most likely cause in the image, and two fixes?
9. Why is `nginx:latest` a bad choice in a production manifest — two reasons?
10. Two containers in the same Pod both try to listen on port 8080. What happens and why?
11. Where on a Linux node do cgroup limits live, and which file does `resources.limits.memory` become? Which one does `resources.limits.cpu` become?
12. Why must the kubelet and containerd agree on the cgroup driver, and where is each one set?

<details>
<summary>Answers</summary>

1. **Namespaces** (what it can see), **cgroups** (what it can use), a **layered root filesystem** (what files it sees as `/`). All running on the shared host kernel.
2. CPU: **throttled** — slower, no restart. Memory: **killed** by the OOM killer (SIGKILL, exit 137, `OOMKilled`).
3. An **OOM kill**, or **SIGKILL after the termination grace period** expired (or any other SIGKILL). `status.containerStatuses[].lastState.terminated.reason` says `OOMKilled` vs `Error`.
4. Yes to images — they are **OCI images**, runtime-independent. No to Docker Engine — **dockershim** was removed in v1.24; nodes use a CRI runtime such as **containerd** or **CRI-O**.
5. The **CRI** endpoint of the node's runtime (containerd/CRI-O). Docker usually is not installed on nodes, and even if it were, it would not see the kubelet's containers.
6. `sleep 3600`. `command` replaces ENTRYPOINT, and when `command` is set without `args`, the image's CMD is **ignored** too.
7. `/docker-entrypoint.sh nginx -g "daemon off;"` — ENTRYPOINT kept, CMD replaced by `args` (here with the same value).
8. PID 1 does not handle **SIGTERM** — typically a **shell-form** CMD/ENTRYPOINT, so `/bin/sh` is PID 1. Fixes: use **exec form**, `exec` the app at the end of an entrypoint script, or an init such as **tini** (or handle SIGTERM in the app). Lowering `terminationGracePeriodSeconds` hides the symptom but loses graceful shutdown.
9. It is **mutable** (you cannot tell which version is running, and nodes may run different ones), and it forces **`imagePullPolicy: Always`**, coupling every Pod start to registry availability. Pin a version tag or digest.
10. The second fails to bind (`address already in use`) and crashes. Containers in a Pod **share the network namespace** — one set of ports.
11. Under `/sys/fs/cgroup/` (cgroup v2), one directory per group. `limits.memory` → **`memory.max`**; `limits.cpu` → **`cpu.max`** (quota per period). CPU requests become `cpu.weight`.
12. Both create and manage the same Pod cgroups; with different drivers (`systemd` vs `cgroupfs`) they build conflicting cgroup trees and the node misbehaves or goes NotReady. Kubelet: `cgroupDriver` in `/var/lib/kubelet/config.yaml`. containerd: `SystemdCgroup = true` in `/etc/containerd/config.toml`.

</details>

---

**Next:** [`00-02` — Lab environment: kind, kubectl and the tooling](00-02-lab-environment-kind.md)
