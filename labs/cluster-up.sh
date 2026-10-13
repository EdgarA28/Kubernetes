#!/usr/bin/env bash
# Creates the course's 3-node kind cluster (k8s-lab) and switches kubectl to it.
set -euo pipefail
CLUSTER=k8s-lab
CONFIG="$(dirname "$0")/kind-cluster.yaml"
for t in docker kind kubectl; do command -v "$t" >/dev/null || { echo "$t not on PATH" >&2; exit 1; }; done
docker info >/dev/null 2>&1 || { echo "Docker is not running" >&2; exit 1; }
if kind get clusters | grep -qx "$CLUSTER"; then
  echo "Cluster $CLUSTER already exists - reusing it."; kind export kubeconfig --name "$CLUSTER"
else
  kind create cluster --config "$CONFIG"
fi
kubectl config use-context "kind-$CLUSTER" >/dev/null
kubectl wait --for=condition=Ready nodes --all --timeout=180s
kubectl get nodes -o wide
