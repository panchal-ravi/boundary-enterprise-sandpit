#!/bin/bash
# mkdir ~/.credentials
nohup boundary connect -target-name eks_readonly  -format=json | tee ~/.credentials/boundary-kube.json 1>/dev/null &
#exit 0
sleep 2

rm ./kubeconfig
touch ./kubeconfig
export KUBECONFIG=./kubeconfig
export CLUSTER_NAME=My-Kubernetes-Cluster
export PORT=$(cat ~/.credentials/boundary-kube.json | jq .port)
export REMOTE_USER_TOKEN=$(cat $HOME/.credentials/boundary-kube.json | \
  jq '.credentials[] | select(.credential_source.name=="eks_token_readonly")' | \
  jq -r .secret.decoded.service_account_token)

# Save cert from Boundary to file
cat $HOME/.credentials/boundary-kube.json | \
  jq '.credentials[] | select(.credential_source.name=="eks_ca_crt")' | \
  jq -r .credential.eks_ca_crt | base64 -d > $HOME/.credentials/boundary-kube-cert.crt


echo "Cluster name is: ${CLUSTER_NAME}"
echo "Port number is: ${PORT}"
echo "Configuring Kubernetes contexts..."

kubectl config set-cluster $CLUSTER_NAME \
  --server=https://127.0.0.1:$PORT \
  --tls-server-name kubernetes \
  --certificate-authority=$HOME/.credentials/boundary-kube-cert.crt

kubectl config set-context $CLUSTER_NAME --cluster=$CLUSTER_NAME
kubectl config set-credentials boundary-user --token=$REMOTE_USER_TOKEN
kubectl config set-context $CLUSTER_NAME --user=boundary-user --namespace test
kubectl config use-context $CLUSTER_NAME
