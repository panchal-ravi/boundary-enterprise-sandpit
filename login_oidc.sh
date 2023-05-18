#!/bin/bash

boundary logout >/dev/null 2>&1

export BOUNDARY_ADDR=https://$(terraform output -raw boundary_cluster_url)
export BOUNDARY_CAPATH=./modules/infra/aws/cluster/tmp/ca.cert
export BOUNDARY_TLS_SERVER_NAME=boundary.demo.com
export BOUNDARY_TLS_INSECURE=true
export ORG_ID=$(boundary scopes list -scope-id global -recursive -format json 2>/dev/null | jq '.items[] | select(.scope.type=="global") | .id' -r)
export AUTH_ID=$(boundary auth-methods list -scope-id=$ORG_ID -format json 2>/dev/null | jq ".items[] | select(.is_primary == true) | .id" -r)
export PROJECT_ID=p_qGkCIReZt8
export BOUNDARY_CONNECT_TARGET_SCOPE_ID=$PROJECT_ID
export BOUNDARY_SCOPE_ID=$PROJECT_ID


boundary authenticate oidc -scope-id=$ORG_ID -auth-method-id $AUTH_ID 