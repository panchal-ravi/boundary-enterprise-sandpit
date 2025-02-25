#!/bin/bash
export KUBECONFIG=./kubeconfig
export CLUSTER_NAME=My-Kubernetes-Cluster
export PORT=$(cat ~/.credentials/boundary-kube.json | jq .port)

kill -9 $(lsof -i -P -n | grep LISTEN | grep -i $PORT | awk '{print $2}') >/dev/null 2>&1 || true
rm ./kubeconfig
