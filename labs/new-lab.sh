#!/usr/bin/env bash
# Usage: ./labs/new-lab.sh lab-00-03
set -euo pipefail
NAME="${1:?usage: new-lab.sh <namespace>}"
[ "$(kubectl config current-context)" = "kind-k8s-lab" ] || { echo "Not on kind-k8s-lab - refusing" >&2; exit 1; }
kubectl create namespace "$NAME" --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl label namespace "$NAME" course=k8s --overwrite >/dev/null
kubectl config set-context --current --namespace="$NAME" >/dev/null
echo "Namespace $NAME ready (course=k8s) and set as default."
