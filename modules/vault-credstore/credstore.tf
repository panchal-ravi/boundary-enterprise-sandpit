/*
resource "vault_token" "boundary" {
  policies = [vault_policy.boundary-controller.name, vault_policy.db-read.name, vault_policy.kv-read.name, vault_policy.k8s-roles.name]

  no_parent         = true
  no_default_policy = true
  renewable         = true
  ttl               = "20m"
  period            = "20m"

  metadata = {
    "purpose" = "boundary-service-account"
  }
}

resource "boundary_credential_store_vault" "cred_store" {
  name        = "vault-cred-store"
  description = "Vault credential store!"
  address     = "http://${var.vault_ip}:8200"
  token       = vault_token.boundary.client_token
  scope_id    = var.project_id
}
*/

