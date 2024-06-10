resource "boundary_host_catalog_static" "windows_servers" {
  name        = "windows_servers"
  description = "windows servers"
  scope_id    = var.boundary_resources.project_id
}

resource "boundary_host_static" "windows_servers" {
  name            = "windows_server_1"
  description     = "Windows Instance #1"
  address         = aws_instance.windows.private_ip
  host_catalog_id = boundary_host_catalog_static.windows_servers.id
}

resource "boundary_host_set_static" "windows_servers" {
  name            = "windows_host_set"
  description     = "Host set for Windows servers"
  host_catalog_id = boundary_host_catalog_static.windows_servers.id
  host_ids        = [boundary_host_static.windows_servers.id]
}

resource "boundary_role" "windows_admin" {
  name           = "windows_admin"
  description    = "Access to Windows hosts for admin role"
  scope_id       = var.boundary_resources.org_id
  grant_scope_ids = [var.boundary_resources.project_id]
  grant_strings = [
    "ids=${boundary_target.windows_admin.id};actions=read,authorize-session",
    "ids=${boundary_host_static.windows_servers.id};actions=read",
    "ids=${boundary_host_set_static.windows_servers.id};actions=read",
    "ids=*;type=target;actions=list,no-op",
    "ids=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  principal_ids = [file("${path.root}/generated/managed_group_admin_id")]
}

resource "boundary_role" "windows_analyst" {
  name           = "windows_analyst"
  description    = "Access to Windows hosts for analyst role"
  scope_id       = var.boundary_resources.org_id
  grant_scope_ids = [var.boundary_resources.project_id]
  grant_strings = [
    "ids=${boundary_target.windows_analyst.id};actions=read,authorize-session",
    "ids=${boundary_host_static.windows_servers.id};actions=read",
    "ids=${boundary_host_set_static.windows_servers.id};actions=read",
    "ids=*;type=target;actions=list,no-op",
    "ids=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  principal_ids = [file("${path.root}/generated/managed_group_analyst_id")]
}

resource "boundary_target" "windows_admin" {
  type                     = "tcp"
  name                     = "windows_admin"
  description              = "Windows host access for Admin"
  scope_id                 = var.boundary_resources.project_id
  session_connection_limit = -1
  default_port             = 3389
  ingress_worker_filter    = "\"ingress\" in \"/tags/type\""
  egress_worker_filter     = "\"egress\" in \"/tags/type\""
  host_source_ids = [
    boundary_host_set_static.windows_servers.id
  ]

  brokered_credential_source_ids = [ boundary_credential_username_password.static_win_creds.id ]

}

resource "boundary_target" "windows_analyst" {
  type                     = "tcp"
  name                     = "windows_analyst"
  description              = "Windows host access for analyst"
  scope_id                 = var.boundary_resources.project_id
  session_connection_limit = -1
  default_port             = 3389
  ingress_worker_filter    = "\"ingress\" in \"/tags/type\""
  egress_worker_filter     = "\"egress\" in \"/tags/type\""
  host_source_ids = [
    boundary_host_set_static.windows_servers.id
  ]

  brokered_credential_source_ids = [ boundary_credential_username_password.static_win_creds.id ]

}

resource "boundary_credential_username_password" "static_win_creds" {
  name                = "static_windows_creds"
  description         = "Windows credentials"
  credential_store_id = var.boundary_resources.static_credstore_id
  username            = "Administrator"
  password            = rsadecrypt(aws_instance.windows.password_data, file("${path.root}/generated/rsa_key"))
}
