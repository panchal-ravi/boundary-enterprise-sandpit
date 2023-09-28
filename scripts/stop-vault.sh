#!/bin/bash
# export BOUNDARY_ADDR=$(cat ./generated/boundary_cluster_url) 
export BOUNDARY_ADDR=$(terraform output -raw boundary_cluster_url)
# export BOUNDARY_AUTHENTICATE_PASSWORD_PASSWORD=$(cat ./generated/boundary_password)
export BOUNDARY_AUTHENTICATE_PASSWORD_PASSWORD=$TF_VAR_boundary_admin_password
export BOUNDARY_TLS_INSECURE=true
export AUTH_ID=$(boundary auth-methods list -scope-id global -format json | jq ".items[].id" -r)
boundary authenticate password -auth-method-id=$AUTH_ID -login-name=admin -password env://BOUNDARY_AUTHENTICATE_PASSWORD_PASSWORD
export PROJECT_ID=$(boundary scopes list -scope-id global -recursive -format json | jq '.items[] | select(.scope.type=="org") | .id' -r)
export BOUNDARY_CONNECT_TARGET_SCOPE_ID=$PROJECT_ID
export BOUNDARY_SCOPE_ID=$PROJECT_ID
kill -9 $(lsof -i -P -n | grep LISTEN | grep -i 8200 | awk '{print $2}') >/dev/null 2>&1 || true
boundary sessions cancel -id $(boundary sessions list -scope-id $PROJECT_ID -format json | jq '.items[]? | select(.endpoint|test(".8200")) | .id' -r) >/dev/null 2>&1 || true
