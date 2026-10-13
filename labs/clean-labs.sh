#!/usr/bin/env bash
# Removes namespaces and cluster-scoped objects labelled course=k8s; resets the default namespace.
set -euo pipefail
[ "$(kubectl config current-context)" = "kind-k8s-lab" ] || { echo "Not on kind-k8s-lab - refusing" >&2; exit 1; }
kubectl delete namespaces -l course=k8s --wait=true --timeout=120s
# One kind at a time: a kind that is not installed yet must not abort the rest.
for k in clusterroles clusterrolebindings persistentvolumes storageclasses priorityclasses \
         customresourcedefinitions validatingadmissionpolicies validatingadmissionpolicybindings \
         validatingwebhookconfigurations mutatingwebhookconfigurations ingressclasses gatewayclasses; do
  kubectl delete "$k" -l course=k8s --ignore-not-found 2>/dev/null || true
done
kubectl get all -n default --no-headers 2>/dev/null | grep -v '^service/kubernetes ' || true
kubectl config set-context --current --namespace=default >/dev/null
echo "Clean. Default namespace reset to 'default'."
