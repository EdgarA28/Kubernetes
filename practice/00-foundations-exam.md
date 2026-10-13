# Practice — Foundations cumulative exam

Two parts covering all of `00-foundations`:

- **Part A — 25 multiple-choice questions.** Scenario-led, one best answer. ~30 minutes.
- **Part B — 5 hands-on tasks** on your `k8s-lab` cluster, CNCF-exam style. ~30 minutes.

**Closed-book. Target: 20/25 in Part A and 4/5 tasks in Part B before starting Domain 1.**

---

## Part A — Questions

**1.** A container is killed and `kubectl describe pod` shows `Last State: Terminated, Exit Code: 137`. What does 137 mean in itself?

A. The application returned error code 137
B. The process received SIGKILL (128 + 9)
C. The image could not be pulled
D. The process received SIGTERM and exited cleanly

---

**2.** A container exceeds its **CPU** limit. What happens?

A. It is OOMKilled
B. It is throttled and runs slower
C. It is evicted from the node
D. The Pod is rescheduled to a bigger node

---

**3.** Since Kubernetes v1.24, which statement is true?

A. Images built with `docker build` can no longer run on Kubernetes
B. The kubelet talks to Docker Engine through dockershim
C. The kubelet talks to a CRI runtime such as containerd or CRI-O; OCI images built by Docker still run
D. Kubernetes nodes must run Podman

---

**4.** An image has `ENTRYPOINT ["/app"]` and `CMD ["--port=8080"]`. A Pod sets only `args: ["--port=9090"]`. What runs?

A. `/app --port=8080`
B. `/app --port=9090`
C. `--port=9090`
D. `/app --port=8080 --port=9090`

---

**5.** Which is the **only** component that reads from and writes to etcd?

A. kube-scheduler
B. kube-controller-manager
C. kube-apiserver
D. kubelet

---

**6.** What does the scheduler do when it has chosen a node for a Pod?

A. Connects to the kubelet on that node and asks it to start the containers
B. Writes the node name into the Pod's `spec.nodeName` via the API server
C. Pulls the image onto that node
D. Creates the Pod's network namespace

---

**7.** A Pod has been `Pending` for 10 minutes. `kubectl describe pod` shows `Events: <none>`. Most likely cause?

A. The image does not exist
B. No node has enough CPU
C. The kube-scheduler is not running
D. The container is crash-looping

---

**8.** You create a Deployment. It shows `READY 0/3`, and `kubectl get rs` shows no ReplicaSet for it. Which component should you check first?

A. kube-scheduler
B. kube-controller-manager
C. CoreDNS
D. kube-proxy

---

**9.** You run `kubectl delete pod kube-scheduler-cp1 -n kube-system`. What happens?

A. The scheduler is permanently removed
B. The Pod comes back, because it is a static Pod defined by a file the kubelet watches
C. The controller manager recreates it from its Deployment
D. The command is refused because kube-system is protected

---

**10.** On a kubeadm cluster, where are the control-plane static Pod manifests by default?

A. `/var/lib/kubelet/pods/`
B. `/etc/kubernetes/manifests/`
C. `/etc/kubernetes/pki/`
D. `/opt/cni/bin/`

---

**11.** An etcd cluster has **4** members. How many member failures can it tolerate while still accepting writes?

A. 0
B. 1
C. 2
D. 3

---

**12.** A worker node loses power. A **bare Pod** (no controller) was running on it. With default settings, what eventually happens to that Pod?

A. It is recreated on another node after about 5 minutes
B. It is evicted and not recreated anywhere
C. It keeps running on the dead node
D. The scheduler moves it immediately

---

**13.** Which statement about the kubelet is correct?

A. It is a Pod in kube-system managed by a DaemonSet
B. It is a systemd service on each node that runs Pods bound to that node and reports their status
C. It runs only on the control plane
D. It reads Pod specs directly from etcd

---

**14.** What is the correct `apiVersion` for a CronJob?

A. `v1`
B. `apps/v1`
C. `batch/v1`
D. `cron/v1`

---

**15.** Which of these is **cluster-scoped**?

A. PersistentVolumeClaim
B. Role
C. PersistentVolume
D. ServiceAccount

---

**16.** You add a label to a Deployment's `metadata.labels`. What happens to `metadata.generation`?

A. It increments, and a rollout starts
B. It does not change, because generation tracks `spec` changes only
C. It resets to 1
D. It increments, but no rollout starts

---

**17.** A namespace has been stuck in `Terminating` for an hour. What is the mechanism holding it?

A. A ResourceQuota
B. A finalizer that no controller is removing
C. A PodDisruptionBudget
D. The namespace has a `deletionTimestamp` in the future

---

**18.** You delete a Deployment with `--cascade=orphan`. What remains?

A. Nothing
B. The ReplicaSet and its Pods, without an owner reference
C. Only the Pods
D. The Deployment, marked for deletion

---

**19.** `kubectl replace -f cm.yaml` fails with *the object has been modified; please apply your changes to the latest version*. Why?

A. The YAML is invalid
B. The `resourceVersion` in your file is older than the live object's — someone wrote in between
C. ConfigMaps are immutable
D. You lack RBAC permission

---

**20.** Which env entry will the API server **reject**?

A. `value: "3"`
B. `value: '3'`
C. `value: 3`
D. `value: "true"`

---

**21.** What does `kubectl create deployment web --image=nginx --dry-run=client -o yaml` do?

A. Creates the Deployment and prints it
B. Prints the YAML for the Deployment without sending anything to the API server
C. Sends it through admission without saving it
D. Shows the difference from the live object

---

**22.** Your file sets `replicas: 3`, and an HPA has scaled the Deployment to 10. You run `kubectl apply -f`. What happens?

A. Nothing — apply never touches replicas
B. Replicas is set back to 3, and the HPA scales it up again
C. The apply fails with a conflict
D. The HPA is deleted

---

**23.** A Service exists and its DNS name resolves, but connections fail. `kubectl get endpointslices -l kubernetes.io/service-name=web` shows no endpoints. Most likely cause?

A. CoreDNS is down
B. The Service's selector does not match the labels of any Ready Pod
C. The NodePort is outside 30000–32767
D. kube-proxy is in IPVS mode

---

**24.** Which change to a Deployment triggers a new rollout (a new ReplicaSet)?

A. `kubectl scale deploy web --replicas=5`
B. Adding an annotation to the Deployment's `metadata`
C. Changing the container image in `spec.template`
D. Changing `spec.revisionHistoryLimit`

---

**25.** During a rollout, the new Pods are stuck in `ImagePullBackOff`. With default strategy settings and 4 replicas, what is the situation?

A. All Pods are down — full outage
B. Old Pods keep serving; the rollout stalls; Kubernetes does not roll back automatically
C. Kubernetes rolls back automatically after 60 seconds
D. The Deployment is deleted

---

## Part B — Hands-on tasks

Run `./labs/new-lab.sh exam-00` first. Do every task in namespace `exam-00` unless told otherwise. Time limit: 30 minutes for all five.

**B1.** Create a Deployment `shop` with 3 replicas of `nginx:1.27`, container port 80, and a CPU request of `25m`. The Pods must carry the labels `app=shop` and `tier=frontend`.

**B2.** Expose `shop` inside the cluster as a Service `shop` on port **8080**, forwarding to container port 80. Prove it works from a temporary Pod using the DNS name `shop.exam-00`.

**B3.** Write to `~/exam-00-pods.txt` a list of `shop`'s Pods in the format `<pod-name> <node-name>`, one per line, using a single `kubectl` command.

**B4.** Update `shop` to `nginx:1.28` and record the cause `upgrade to 1.28`. Then roll back to the previous revision. Verify the running image.

**B5.** *(Control plane)* On the control-plane node, the scheduler has been broken. Simulate it yourself first:

```bash
docker exec k8s-lab-control-plane sh -c "cp /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/ks.good && sed -i 's#--kubeconfig=/etc/kubernetes/scheduler.conf#--kubeconfig=/etc/kubernetes/scheduler.cnf#' /etc/kubernetes/manifests/kube-scheduler.yaml"
```

Wait one minute and **forget what you changed**. Then: diagnose why new Pods stay `Pending`, find the error, and fix it **without** using `/tmp/ks.good`. Prove it with a new Pod that gets scheduled.

---

## Answers — Part A

| # | Answer | Why |
|---|---|---|
| 1 | **B** | 128 + signal number; 9 = SIGKILL. The *reason* (OOMKilled vs Error) is in `lastState.terminated.reason`. |
| 2 | **B** | CPU is compressible — throttled. Memory is incompressible — killed. |
| 3 | **C** | dockershim was removed; nodes use CRI runtimes. Images are OCI and portable. |
| 4 | **B** | `args` replaces CMD; ENTRYPOINT is kept. |
| 5 | **C** | Everything else goes through the API server. |
| 6 | **B** | The scheduler binds (sets `nodeName`). The kubelet does the rest. |
| 7 | **C** | A running scheduler that cannot place a Pod emits `FailedScheduling`. No events at all = no scheduler. |
| 8 | **B** | The Deployment controller (in kube-controller-manager) creates ReplicaSets. |
| 9 | **B** | Mirror Pod of a static Pod; remove the manifest file to remove it. |
| 10 | **B** | `staticPodPath` in `/var/lib/kubelet/config.yaml` confirms it. |
| 11 | **B** | Quorum of 4 is 3, so only 1 can fail — same as 3 members. |
| 12 | **B** | It is evicted (after the 300 s default toleration), but nothing owns it, so nothing recreates it. |
| 13 | **B** | Systemd service; watches the API server for Pods bound to its node. |
| 14 | **C** | `batch/v1` — Job and CronJob. |
| 15 | **C** | PVs are cluster-scoped; PVCs, Roles and ServiceAccounts are namespaced. |
| 16 | **B** | `generation` changes on spec changes only; metadata changes alter `resourceVersion`. |
| 17 | **B** | Deletion waits until `finalizers` is empty; a missing/failing controller leaves it stuck. |
| 18 | **B** | Orphan cascade removes only the owner and strips owner references from dependents. |
| 19 | **B** | Optimistic concurrency — 409 Conflict on a stale `resourceVersion`. |
| 20 | **C** | Env values must be strings; unquoted `3` is an integer. |
| 21 | **B** | Client-side dry run builds the object locally. (`--dry-run=server` is C.) |
| 22 | **B** | apply sets every field in the file. Leave `replicas` out when an HPA manages it. |
| 23 | **B** | No endpoints = no Ready Pod matches the selector (or none are Ready). |
| 24 | **C** | Only Pod-template changes create a new ReplicaSet. |
| 25 | **B** | `maxUnavailable` (25% of 4 = 1) allows only one old Pod to go; the rest keep serving. Stalled rollouts are never auto-reverted. |

## Answers — Part B

<details>
<summary>B1</summary>

```bash
kubectl create deployment shop --image=nginx:1.27 --replicas=3 --port=80 --dry-run=client -o yaml > shop.yaml
```

Edit `shop.yaml`: add `tier: frontend` under `spec.template.metadata.labels` (and optionally `spec.selector.matchLabels`), and under the container:

```yaml
        resources:
          requests:
            cpu: 25m
```

```bash
kubectl apply -f shop.yaml
kubectl get pods -l app=shop,tier=frontend          # 3 Pods
kubectl get deploy shop -o jsonpath='{.spec.template.spec.containers[0].resources}'
```

</details>

<details>
<summary>B2</summary>

```bash
kubectl expose deployment shop --port=8080 --target-port=80
kubectl run t --rm -it --image=curlimages/curl:8.10.1 --restart=Never -- -s -o /dev/null -w "%{http_code}\n" http://shop.exam-00:8080
# 200
```

Note there is no `--command` here: the words after `--` become **args** to the image's `curl` entrypoint.

</details>

<details>
<summary>B3</summary>

```bash
kubectl get pods -l app=shop -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.nodeName}{"\n"}{end}' > ~/exam-00-pods.txt
# or: kubectl get pods -l app=shop --no-headers -o custom-columns=N:.metadata.name,NODE:.spec.nodeName
```

</details>

<details>
<summary>B4</summary>

```bash
kubectl set image deployment/shop nginx=nginx:1.28
kubectl annotate deployment/shop kubernetes.io/change-cause="upgrade to 1.28" --overwrite
kubectl rollout status deployment/shop
kubectl rollout history deployment/shop
kubectl rollout undo deployment/shop
kubectl rollout status deployment/shop
kubectl get deploy shop -o jsonpath='{.spec.template.spec.containers[0].image}'     # nginx:1.27
```

</details>

<details>
<summary>B5</summary>

```bash
kubectl run probe --image=nginx:1.27; kubectl get pod probe         # Pending
kubectl get pods -n kube-system -l component=kube-scheduler          # CrashLoopBackOff / Error
kubectl logs -n kube-system -l component=kube-scheduler              # … scheduler.cnf: no such file or directory
docker exec -it k8s-lab-control-plane bash
  ls /etc/kubernetes/                         # scheduler.conf exists, scheduler.cnf does not
  grep -n -A3 'volumes:' /etc/kubernetes/manifests/kube-scheduler.yaml   # only scheduler.conf is mounted into the Pod
  grep -n 'scheduler.c' /etc/kubernetes/manifests/kube-scheduler.yaml
  sed -i 's#--kubeconfig=/etc/kubernetes/scheduler.cnf#--kubeconfig=/etc/kubernetes/scheduler.conf#' /etc/kubernetes/manifests/kube-scheduler.yaml
  exit
kubectl get pods -n kube-system -l component=kube-scheduler -w      # Running
kubectl get pod probe -o wide                                        # scheduled
```

If `kubectl logs` shows nothing useful, use `crictl ps -a --name kube-scheduler` and `crictl logs <id>` on the node. Clean up: `./labs/clean-labs.sh` and `rm -f ~/exam-00-pods.txt shop.yaml`.

</details>

---

## Scoring

| Part A | Part B | Meaning |
|---|---|---|
| 23–25 | 5/5 | Solid. Start Domain 1. |
| 20–22 | 4/5 | Good. Re-read the modules behind what you missed, then continue. |
| 15–19 | 3/5 | Re-read `00-03` and `00-04` — they carry most of the marks — and redo the `00-03` lab. |
| < 15 | < 3 | Work through Domain 0 again, doing every self-check and lab break-it step. |
