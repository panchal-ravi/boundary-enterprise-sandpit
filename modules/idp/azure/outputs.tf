output "client" {
  value = {
    client_id = azuread_application.client_app.application_id,
    client_secret = azuread_application_password.client_app.value
  }
}
output "az_ad_group_admin_id" {
  value = azuread_group.admin.object_id
}
output "az_ad_group_analyst_id" {
  value = azuread_group.analyst.object_id
}
output "managed_group" {
  value = {
    admin_id   = boundary_managed_group.db_admin.id,
    analyst_id = boundary_managed_group.db_analyst.id
  }
}
