resource "vault_token" "boundary" {
  for_each = var.projects
  policies = [vault_policy.boundary-controller.name,
    vault_policy.db-read.name,
    vault_policy.kv-read.name,
    vault_policy.k8s-roles.name,
    vault_policy.boundary-client.name
  ]

  no_parent         = true
  no_default_policy = true
  renewable         = true
  ttl               = "20m"
  period            = "20m"

  metadata = {
    "purpose" = "boundary-service-account-${each.key}"
  }
}

resource "boundary_credential_store_vault" "cred_store" {
  for_each      = var.projects
  name          = "vault-cred-store-${each.key}"
  description   = "Vault credential store!"
  address       = "http://${var.vault_ip}:8200"
  token         = vault_token.boundary[each.key].client_token
  scope_id      = each.value.id
  worker_filter = "\"ingress\" in \"/tags/type\""
}


