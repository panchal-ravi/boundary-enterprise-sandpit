output "project_id" {
  value = boundary_scope.project[local.digital_channel_org].id
}

output "projects" {
  value = boundary_scope.project
}

output "org_id" {
  value = boundary_scope.org[local.digital_channel_org].id
}

output "auth0_managed_group_analyst_id" {
  value = boundary_managed_group.auth0_db_analyst.id
}

output "auth0_managed_group_admin_id" {
  value = boundary_managed_group.azure_db_admin.id
}

output "azure_managed_group_analyst_id" {
  value = boundary_managed_group.azure_db_analyst.id
}

output "azure_managed_group_admin_id" {
  value = boundary_managed_group.auth0_db_admin.id
}

output "okta_managed_group_analyst_id" {
  value = boundary_managed_group.okta_db_analyst.id
}

output "okta_managed_group_admin_id" {
  value = boundary_managed_group.okta_db_admin.id
}

output "static_credstore_id" {
  value = boundary_credential_store_static.static_cred_store[local.digital_channel_org].id
}

output "static_db_creds_id" {
  value = boundary_credential_username_password.static_db_creds[local.digital_channel_org].id
}

output "global_auth_method_id" {
  value = boundary_auth_method_password.password.id
}
output "boundary_admin_userid" {
  value = boundary_account_password.admin.id
}
