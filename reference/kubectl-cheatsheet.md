# kubectl cheat sheet

Grouped by task. `k` = `kubectl` (alias from `00-02`). Grows with each domain.

## Context and namespace

```bash
k config get-contexts
k config current-context
k config use-context kind-k8s-lab
k config set-context --current --namespace=<ns>
k config view --minify
```

## Discover

```bash
k api-resources [--namespaced=false] [--api-group=apps]
k api-versions
k explain <kind>[.<field>…] [--recursive]
```

## Read

```bash
k get <kind> [-n ns | -A] [-o wide|yaml|json|name] [-l k=v] [--show-labels] [-L k] [-w]
k get <kind> --sort-by=.metadata.creationTimestamp
k get pods --field-selector status.phase!=Running
k get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,IP:.status.podIP
k get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}'
k describe <kind> <name>                          # read Events at the bottom
k events --for pod/<name>
k get events -A --sort-by=.lastTimestamp
k logs <pod> [-c ctr] [--previous] [--tail=50] [-f] [--since=10m]
k logs -l app=web --prefix --tail=20
k get --raw='/readyz?verbose'
```

## Generate YAML (exam speed)

```bash
export do="--dry-run=client -o yaml"                  # bash
k run p --image=nginx:1.27 --port=80 --labels=a=b $do
k run p --image=busybox:1.37 --restart=Never --command -- sh -c 'echo hi'   # command
k run p --image=busybox:1.37 --restart=Never -- echo hi                     # args
k create deployment d --image=nginx:1.27 --replicas=3 --port=80 $do
k expose deployment d --port=80 --target-port=8080 [--type=NodePort] $do
k create job j --image=busybox:1.37 $do -- echo hi
k create cronjob c --image=busybox:1.37 --schedule="*/5 * * * *" $do -- date
k create configmap cm --from-literal=k=v --from-file=app.conf $do
k create secret generic s --from-literal=password=x $do
```

## Change

```bash
k apply -f file.yaml | -f dir/ | -k overlay/
k diff -f file.yaml
k edit <kind> <name>
k set image deploy/d <container>=<image>
k set env deploy/d KEY=value
k scale deploy/d --replicas=5
k label <kind> <name> k=v [--overwrite] | k-
k annotate <kind> <name> k=v
k patch <kind> <name> -p '<strategic merge json>'
k patch <kind> <name> --type=merge -p '{"spec":{"replicas":2}}'
k patch <kind> <name> --type=json -p '[{"op":"replace","path":"/spec/replicas","value":2}]'
k replace --force -f file.yaml                         # delete + recreate (immutable fields)
```

## Rollouts

```bash
k rollout status deploy/d
k rollout history deploy/d [--revision=N]
k rollout undo deploy/d [--to-revision=N]
k rollout restart deploy/d
k rollout pause|resume deploy/d
k annotate deploy/d kubernetes.io/change-cause="why" --overwrite
```

## Interact

```bash
k exec -it <pod> [-c ctr] -- sh
k port-forward svc/<svc> 8080:80
k cp <pod>:/path ./local
k run tmp --rm -it --image=busybox:1.37 --restart=Never -- sh
k run tmp --rm -it --image=curlimages/curl:8.10.1 --restart=Never -- -s http://svc.ns
```

## Delete

```bash
k delete <kind> <name> [--cascade=background|foreground|orphan]
k delete pod <pod> --grace-period=0 --force
k delete -f file.yaml
k delete ns -l course=k8s                              # course cleanup
```

## Wait and permissions

```bash
k wait --for=condition=Ready pod -l app=web --timeout=60s
k wait --for=delete pod/<pod> --timeout=60s
k auth can-i <verb> <resource> [--as=user | --as=system:serviceaccount:ns:sa] [-n ns]
k auth whoami
```

## On a node (kind: `docker exec -it <node> bash`)

```bash
systemctl status kubelet --no-pager
journalctl -u kubelet --no-pager | tail -50
ls /etc/kubernetes/manifests/
cat /var/lib/kubelet/config.yaml
crictl ps [-a] [--name <ctr>]
crictl pods
crictl logs <container-id>
crictl inspect <container-id>
```

## Debug flow for a Pod

```
k get pod → k describe pod (Events) → k logs → k logs --previous → k exec / k debug
```
