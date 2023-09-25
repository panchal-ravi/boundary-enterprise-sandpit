## Pre-Requisites
- AWS Account
- Auth0 Account: [Sign Up - Auth0](https://auth0.com/signup)
- Auth0 Machine-Machine client application: [Create Auth0 client application](https://registry.terraform.io/providers/auth0/auth0/latest/docs/guides/quickstart)
- Okta Account: [Sig Up - Okta](https://developer.okta.com/signup/)
- Okta API Token: [Create an Okta API token](https://developer.okta.com/docs/guides/create-an-api-token/main/)
- Boundary CLI - 0.12.2: [Install Boundary CLI](https://developer.hashicorp.com/boundary/tutorials/hcp-getting-started/hcp-getting-started-install?in=boundary%2Fhcp-getting-started)
- Boundary Desktop (Optional): [Install Boundary Desktop](https://developer.hashicorp.com/boundary/tutorials/hcp-getting-started/hcp-getting-started-desktop-app)
- Microsoft Remote Desktop
- jq (command line JSON processor): [Install jq](https://stedolan.github.io/jq/download/)
- psql (command line): [Install psql](https://www.postgresql.org/download/)
- ssh (command line)
- kubectl (command line): [Install kubectl](https://kubernetes.io/docs/tasks/tools/)

# Initial Setup
## Setup .envrc file with Variables.  Please treat these as secrets!
Once creds are created as per prerequisites, we need to make them available to Terraform as below.  It uses direnv if you have it installed.

```sh
vi .envrc

export TF_VAR_controller_db_username=<boundary_controller_db_username>
export TF_VAR_controller_db_password=<boundary_controller_db_password>
export TF_VAR_auth0_domain=<auth0_domain>
export TF_VAR_auth0_client_id=<auth0_client_id>
export TF_VAR_auth0_client_secret=<auth0_client_secret>
export TF_VAR_okta_base_url=okta.com
export TF_VAR_okta_org_name=<okta_org_name>
export TF_VAR_okta_api_token=<okta_api_token>
export TF_VAR_okta_domain=<okta_org_name>.okta.com
export TF_VAR_user_password=<auth0_user_password> #password for auth0/okta users 
export TF_VAR_rds_username=<rds_username>
export TF_VAR_rds_password=<rds_password>
```
Please ensure the passwords set in above environment variables follow below rules:

- **Password Length:** Minimum 10 characters.
- **Password Complexity:** Password should contain a combination of upper-case and lower-case letters, numbers, and special characters.

## Clone this repo to your local machine
```sh
git clone https://github.com/panchal-ravi/boundary-enterprise-sandpit
cd <cloned-directory>
```

## Build Boundary Enterprise image using packer
```sh
cd amis/boundary
# Verify region is set correctly in variables.pkrvars.hcl file
packer build -var-file="variables.pkrvars.hcl" .
```

## Setup Boundary Enterprise Cluster
```sh
cd <cloned-directory>

# To deploy selected targets i.e. SSH, Windows, Database and Kubernetes 
./scripts/deploy.sh <ssh> <db> <win> <k8s>

# For e.g. to deploy only SSH and Database targets, run below command:
./scripts/deploy.sh ssh db

# To deploy all targets
./scripts/deploy.sh all
```



## Teardown Boundary Enterprise Cluster
```sh
cd <cloned-directory>

./scripts/destroy.sh
```


