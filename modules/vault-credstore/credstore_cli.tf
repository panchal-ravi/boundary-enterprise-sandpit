/*
resource "null_resource" "cred_store" {

  connection {
    host        = var.bastion_ip
    user        = "ubuntu"
    agent       = false
    private_key = file("${path.root}/generated/ssh_key")
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/boundary/create-vault-credstore.sh.tpl", {
      boundary_cluster_url = "https://${var.boundary_cluster_url}",
      boundary_password    = var.boundary_password,
      vault_ip             = var.vault_ip,
      boundary_token       = vault_token.boundary.client_token //trimspace(file("${path.root}/generated/boundary-token"))
    })
    destination = "/home/ubuntu/create-vault-credstore.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/create-vault-credstore.sh",
      "/home/ubuntu/create-vault-credstore.sh"
    ]
  }
  depends_on = [
    vault_token.boundary
  ]
}


resource "null_resource" "cred_store_id" {

  connection {
    host        = var.bastion_ip
    user        = "ubuntu"
    agent       = false
    private_key = file("${path.root}/generated/ssh_key")
  }

  provisioner "local-exec" {
    command = <<-EOT
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${path.root}/generated/ssh_key ubuntu@${var.bastion_ip}:/home/ubuntu/vault_credstore_id ./generated/vault_credstore_id
      EOT
  }

  depends_on = [
    null_resource.cred_store
  ]
}

resource "vault_token" "boundary" {
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
    "purpose" = "boundary-service-account"
  }
}
*/