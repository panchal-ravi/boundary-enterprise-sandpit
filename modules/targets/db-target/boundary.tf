### RDS instances
resource "boundary_host_catalog_static" "db_servers" {
  name        = "db_servers"
  description = "DB servers"
  scope_id    = var.project_id
}

resource "boundary_host_static" "db_servers" {
  name            = "rds_postgres_1"
  description     = "AWS RDS Postgres DB server"
  address         = aws_db_instance.db_target.address
  host_catalog_id = boundary_host_catalog_static.db_servers.id
}

resource "boundary_host_set_static" "db_servers" {
  name            = "rds_postgres_set"
  description     = "Host set for DB servers"
  host_catalog_id = boundary_host_catalog_static.db_servers.id
  host_ids        = [boundary_host_static.db_servers.id]
}

resource "boundary_credential_library_vault" "vault_db_admin" {
  name                = "vault-db-admin"
  description         = "Vault Postgres DB secret for Admin role"
  credential_store_id = var.vault_credstore_id
  path                = "db/creds/admin"
  http_method         = "GET"
  credential_type     = "username_password"
}

resource "boundary_credential_library_vault" "vault_db_analyst" {
  name                = "vault-db-analyst"
  description         = "Vault Postgres DB secret for Analyst role"
  credential_store_id = var.vault_credstore_id
  path                = "db/creds/analyst"
  http_method         = "GET"
  credential_type     = "username_password"
}

resource "boundary_role" "db_analyst" {
  name           = "db_analyst"
  description    = "Access to DB for analyst role"
  scope_id       = var.org_id
  grant_scope_id = var.project_id
  grant_strings = [
    "id=${boundary_target.postgres_analyst.id};actions=read,authorize-session",
    "id=${boundary_host_static.db_servers.id};actions=read",
    "id=${boundary_host_set_static.db_servers.id};actions=read",
    "id=*;type=target;actions=list,no-op",
    "id=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  principal_ids = [var.auth0_managed_group_analyst_id, var.okta_managed_group_analyst_id, var.azure_managed_group_analyst_id]
}

resource "boundary_role" "db_admin" {
  name           = "db_admin"
  description    = "Access to DB for dba role"
  scope_id       = var.org_id
  grant_scope_id = var.project_id
  grant_strings = [
    "id=${boundary_target.postgres_admin.id};actions=read,authorize-session",
    "id=${boundary_host_static.db_servers.id};actions=read",
    "id=${boundary_host_set_static.db_servers.id};actions=read",
    "id=*;type=target;actions=list,no-op",
    "id=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  principal_ids = [var.auth0_managed_group_admin_id, var.okta_managed_group_admin_id, var.azure_managed_group_admin_id]
}


resource "boundary_target" "postgres_admin" {
  type                     = "tcp"
  name                     = "postgres_admin"
  description              = "Postgres DB target for Admin"
  scope_id                 = var.project_id
  session_connection_limit = -1
  default_port             = 5432
  ingress_worker_filter    = "\"ingress\" in \"/tags/type\""
  egress_worker_filter     = "\"egress\" in \"/tags/type\""

  host_source_ids = [
    boundary_host_set_static.db_servers.id
  ]
  brokered_credential_source_ids = [
    boundary_credential_library_vault.vault_db_admin.id
  ]
}

resource "boundary_target" "postgres_analyst" {
  type                     = "tcp"
  name                     = "postgres_analyst"
  description              = "Postgres DB target for Analyst"
  scope_id                 = var.project_id
  session_connection_limit = -1
  default_port             = 5432
  ingress_worker_filter    = "\"ingress\" in \"/tags/type\""
  egress_worker_filter     = "\"egress\" in \"/tags/type\""

  host_source_ids = [
    boundary_host_set_static.db_servers.id
  ]
  brokered_credential_source_ids = [
    boundary_credential_library_vault.vault_db_analyst.id
  ]
}
