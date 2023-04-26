resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "secret" {
  mount               = vault_mount.kvv2.path
  name                = "backend-sshkey"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      username    = "ubuntu",
      private_key = file("${path.root}/generated/ssh_key")
    }
  )
}

resource "vault_mount" "ssh" {
  type = "ssh"
  path = "ssh-client-signer"
}

resource "vault_ssh_secret_backend_ca" "ssh" {
  backend              = vault_mount.ssh.path
  private_key          = tls_private_key.ssh-ca.private_key_openssh
  public_key           = tls_private_key.ssh-ca.public_key_openssh
  generate_signing_key = false
}

resource "vault_ssh_secret_backend_role" "boundary-client" {
  name                    = "boundary-client"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  default_user            = "ubuntu"
  allowed_users           = "*"
  allowed_extensions      = "*"
  allow_user_certificates = true
  default_extensions = {
    "permit-pty" = ""
  }
}
