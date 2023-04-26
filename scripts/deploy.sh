#!/bin/bash
TFDIR=/Users/ravipanchal/learn/boundary/boundary-enterprise-sandpit/

if [ $# -eq 0 ]; then
    echo -e Usage: \"deploy.sh \<ssh\> \<db\> \<win\> \<k8s\>\" to deploy selected targets
    echo -e Usage: \"deploy.sh all\" to deploy all targets
    exit 1
else
    echo -e "Arguments passed: $@"
fi


cd $TFDIR
if [ ! -f "$TFDIR/generated/boundary_password" ]
then 
    $TFDIR/scripts/setup.sh $TFDIR
fi

echo -e "\n\n\n----Creating Boundary Cluster----\n\n\n"

terraform apply -target module.boundary-cluster -auto-approve
sleep 5

echo -e "\n\n\n----Creating Boundary Resources----\n\n\n"

terraform apply -target module.boundary-resources -auto-approve
sleep 5

echo -e "\n\n\n----Starting Vault Session----\n\n\n"
$TFDIR/scripts/start-vault.sh
sleep 5

echo -e "\n\n\n----Creating Vault Credential Store----\n\n\n"
terraform apply -target module.vault-credstore -auto-approve
sleep 5

for target in "$@"
do
    if [[ $target = "ssh" || $target = "all" ]]; then
        echo -e "\n\n\n----Creating SSH Target----\n\n\n"
        terraform apply -target module.ssh-target -auto-approve
    fi
    if [[ $target = "db" || $target = "all" ]]; then
        echo -e "\n\n\n----Creating Database Target----\n\n\n"
        terraform apply -target module.db-target -auto-approve
    fi
    if [[ $target = "win" || $target = "all" ]]; then
        echo -e "\n\n\n----Creating Database Target----\n\n\n"
        terraform apply -target module.db-target -auto-approve

        echo -e "\n\n\n----Creating Windows RDP Target----\n\n\n"
        terraform apply -target module.rdp-target -auto-approve
    fi
    if [[ $target = "k8s" || $target = "all" ]]; then
        echo -e "\n\n\n----Creating Kubernetes Target----\n\n\n"
        terraform apply -target module.k8s-target -auto-approve
    fi
done

echo -e "\n\n\n----Stopping Vault Session----\n\n\n"
$TFDIR/scripts/stop-vault.sh
sleep 5



