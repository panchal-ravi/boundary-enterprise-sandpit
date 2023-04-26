resource "boundary_target" "vault_target" {
  name                  = "vault_enterprise"
  description           = "Vault in private network"
  type                  = "tcp"
  default_port          = "8200"
  scope_id              = boundary_scope.project.id
  address               = var.vault_ip
  ingress_worker_filter = "\"ingress\" in \"/tags/type\""
}

