resource "vault_policy" "boundary-controller" {
  name = "boundary-controller"

  policy = <<EOT
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}

path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOT
}

resource "vault_policy" "kv-read" {
  name = "kv-read"

  policy = <<EOT
path "secret/data/backend-sshkey" {
  capabilities = ["read"]
}
path "secret/data/app-secret" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "db-read" {
  name = "db-read"

  policy = <<EOT
path "db/creds/admin" {
  capabilities = ["read"]
}
path "db/creds/analyst" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "k8s-roles" {
  name = "k8s-roles"

  policy = <<EOT
path "kubernetes/creds/my-role" {
  capabilities = ["read", "update", "create"]
}
EOT
}

resource "vault_policy" "boundary-client" {
  name = "boundary-client"

  policy = <<EOT
path "ssh-client-signer/issue/boundary-client" {
  capabilities = ["create", "update"]
}

path "ssh-client-signer/sign/boundary-client" {
  capabilities = ["create", "update"]
}
EOT
}