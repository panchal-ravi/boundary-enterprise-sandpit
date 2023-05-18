#!/bin/bash
TFDIR=$(pwd)

cd $TFDIR
echo -e "\n\n\n----Starting Vault Session----\n\n\n"
$TFDIR/scripts/start-vault.sh
sleep 2

echo -e "\n\n\n----Destroying SSH Target----\n\n\n"
terraform destroy -target module.ssh-target -auto-approve

echo -e "\n\n\n----Destroying Windows RDP Target----\n\n\n"
terraform destroy -target module.rdp-target -auto-approve

echo -e "\n\n\n----Destroying DB  Target----\n\n\n"
terraform destroy -target module.db-target -auto-approve

echo -e "\n\n\n----Destroying Kubernetes  Target----\n\n\n"
terraform destroy -target module.k8s-target -auto-approve

echo -e "\n\n\n----Destroying Vault Credential Store----\n\n\n"
terraform destroy -target module.vault-credstore -auto-approve

echo -e "\n\n\n----Stoping Vault Session----\n\n\n"
$TFDIR/scripts/stop-vault.sh

echo -e "\n\n\n----Destroying Boundary Resources----\n\n\n"
terraform destroy -target module.boundary-resources -auto-approve

echo -e "\n\n\n----Destroying Boundary Workers----\n\n\n"
terraform apply -target module.boundary-workers -auto-approve


echo -e "\n\n\n----Destroying Boundary Cluster----\n\n\n"
terraform destroy -target module.boundary-cluster -auto-approve






