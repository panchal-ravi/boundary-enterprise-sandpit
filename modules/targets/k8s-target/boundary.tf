### Postgres DB in K8s
resource "boundary_host_catalog_static" "eks_db_servers" {
  name        = "eks_db_servers"
  description = "EKS DB servers"
  scope_id    = var.project_id
}

# EKS cluster
resource "boundary_host_catalog_static" "eks_cluster" {
  name        = "eks_cluster"
  description = "EKS Cluster"
  scope_id    = var.project_id
}

resource "boundary_host_static" "eks_db_servers" {
  name            = "eks_postgres_1"
  description     = "EKS Postgres DB server"
  address         = "postgres.default.svc.cluster.local"
  host_catalog_id = boundary_host_catalog_static.eks_db_servers.id
}

resource "boundary_host_static" "eks_cluster" {
  name            = "eks_cluster_1"
  description     = "EKS Cluster #1"
  address         = trimprefix(data.aws_eks_cluster.cluster.endpoint, "https://")
  host_catalog_id = boundary_host_catalog_static.eks_cluster.id
}

resource "boundary_host_set_static" "eks_db_servers" {
  name            = "eks_postgres_set"
  description     = "Host set for DB servers"
  host_catalog_id = boundary_host_catalog_static.eks_db_servers.id
  host_ids        = [boundary_host_static.eks_db_servers.id]
}

resource "boundary_host_set_static" "eks_cluster" {
  name            = "eks_cluster_set"
  description     = "Host set for EKS cluster"
  host_catalog_id = boundary_host_catalog_static.eks_cluster.id
  host_ids        = [boundary_host_static.eks_cluster.id]
}


resource "boundary_target" "eks_postgres_admin" {
  type                     = "tcp"
  name                     = "eks_postgres_admin"
  description              = "EKS Postgres DB target for Admin"
  scope_id                 = var.project_id
  session_connection_limit = -1
  default_port             = 5432
  ingress_worker_filter    = "\"eks\" in \"/tags/type\""
  host_source_ids = [
    boundary_host_set_static.eks_db_servers.id
  ]

  brokered_credential_source_ids = [
    var.static_db_creds_id
  ]
}

resource "boundary_target" "eks_readonly" {
  type                     = "tcp"
  name                     = "eks_readonly"
  description              = "EKS Readonly target for Developers"
  scope_id                 = var.project_id
  session_connection_limit = -1
  default_port             = 443
  ingress_worker_filter    = "\"ingress\" in \"/tags/type\""
  host_source_ids = [
    boundary_host_set_static.eks_cluster.id
  ]

  brokered_credential_source_ids = [
    boundary_credential_library_vault.eks_token_readonly.id
  ]
}

resource "boundary_credential_library_vault" "eks_token_readonly" {
  name                = "eks_token_readonly"
  description         = "EKS service account token for readonly access by Developers"
  credential_store_id = var.vault_credstore_id
  path                = "kubernetes/creds/my-role"
  http_method         = "POST"
  http_request_body   = <<EOT
{
  "kubernetes_namespace": "test"
}
EOT
}

resource "boundary_role" "db_admin" {
  name           = "eks_db_admin"
  description    = "Access to EKS DB for dba role"
  scope_id       = var.org_id
  grant_scope_id = var.project_id
  grant_strings = [
    "id=${boundary_target.eks_postgres_admin.id};actions=read,authorize-session",
    "id=*;type=target;actions=list,no-op",
    "id=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  principal_ids = [var.auth0_managed_group_admin_id, var.okta_managed_group_admin_id]
}

resource "boundary_role" "eks_readonly" {
  name           = "eks_readonly"
  description    = "Access to EKS for Developers"
  scope_id       = var.org_id
  grant_scope_id = var.project_id
  grant_strings = [
    "id=${boundary_target.eks_readonly.id};actions=read,authorize-session",
    "id=*;type=target;actions=list,no-op",
    "id=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  principal_ids = [var.auth0_managed_group_analyst_id, var.okta_managed_group_analyst_id]
}
