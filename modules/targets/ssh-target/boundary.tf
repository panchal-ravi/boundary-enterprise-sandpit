locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "boundary_host_catalog_static" "linux_servers" {
  name        = "linux_servers"
  description = "Linux servers"
  scope_id    = var.project_id
}

resource "boundary_host_static" "linux_servers" {
  name            = "linux_server_1"
  description     = "Linux Instance #1"
  address         = aws_instance.linux.private_ip
  host_catalog_id = boundary_host_catalog_static.linux_servers.id
}

resource "boundary_host_set_static" "linux_servers" {
  name            = "linux_host_set"
  description     = "Host set for Linux servers"
  host_catalog_id = boundary_host_catalog_static.linux_servers.id
  host_ids        = [boundary_host_static.linux_servers.id]
}

resource "boundary_credential_library_vault" "vault-ssh-key" {
  name                = "vault-ssh-key"
  description         = "Vault SSH Key"
  credential_store_id = var.vault_credstore_id
  path                = "secret/data/backend-sshkey"
  http_method         = "GET"
  credential_type     = "ssh_private_key"
}

resource "boundary_credential_library_vault_ssh_certificate" "vault-ssh-client-cert" {
  name                = "vault-ssh-client-cert"
  description         = "Vault ssh-client certificate credentials"
  credential_store_id = var.vault_credstore_id
  path                = "ssh-client-signer/sign/boundary-client"
  username            = "ubuntu"
  key_type            = "rsa"
  key_bits            = 4096
  ttl                 = "300"

  extensions = {
    permit-pty = ""
  }
}

resource "boundary_role" "linux_admin" {
  name           = "linux_admin"
  description    = "Access to Linux hosts for admin role"
  scope_id       = var.org_id
  grant_scope_id = var.project_id
  grant_strings = [
    "id=${boundary_target.linux_admin.id};actions=read,authorize-session",
    "id=${boundary_host_static.linux_servers.id};actions=read",
    "id=${boundary_host_set_static.linux_servers.id};actions=read",
    "id=*;type=target;actions=list,no-op",
    "id=*;type=auth-token;actions=list,read:self,delete:self",
    "id=*;type=host;actions=list,read",
    "id=*;type=host-set;actions=list,read",
    "id=*;type=host-catalog;actions=list,read"
  ]
  principal_ids = [var.auth0_managed_group_admin_id, var.okta_managed_group_admin_id, var.azure_managed_group_admin_id]
}


resource "boundary_target" "linux_admin" {
  type                     = "ssh"
  name                     = "linux_admin"
  description              = "Linux host access for Admin"
  scope_id                 = var.project_id
  session_connection_limit = -1
  default_port             = 22
  ingress_worker_filter    = "\"ingress\" in \"/tags/type\""
  egress_worker_filter     = "\"egress\" in \"/tags/type\""

  host_source_ids = [
    boundary_host_set_static.linux_servers.id
  ]

  injected_application_credential_source_ids = [
    /* boundary_credential_library_vault.vault-ssh-key.id */
    boundary_credential_library_vault_ssh_certificate.vault-ssh-client-cert.id
  ]
  enable_session_recording = true
  storage_bucket_id        = boundary_storage_bucket.aws.id
}

/* resource "aws_iam_access_key" "boundary" {
  user = "demo-${local.my_email}-boundary"
} */

resource "boundary_storage_bucket" "aws" {
  name            = "global-session-recording-storage"
  description     = "Storage bucket to store session recording"
  scope_id        = var.org_id
  plugin_name     = "aws"
  bucket_name     = "${var.deployment_id}-session-storage-bucket"
  attributes_json = jsonencode({ "region" = data.aws_region.current.name, "disable_credential_rotation" = true, "role_arn" = var.session_storage_role_arn })

  # recommended to pass in aws secrets using a file() or using environment variables
  # the secrets below must be generated in aws by creating an aws iam user with programmatic access

  /* secrets_json = jsonencode({
    "access_key_id"     = aws_iam_access_key.boundary.id,
    "secret_access_key" = aws_iam_access_key.boundary.secret
  }) */
  secrets_json = jsonencode({})


  worker_filter = "\"egress\" in \"/tags/type\""
}
