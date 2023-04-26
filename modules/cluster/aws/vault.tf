resource "aws_instance" "vault" {
  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [module.vault_sg.security_group_id]
  subnet_id              = element(module.vpc.private_subnets, 0)

  tags = {
    Name  = "${var.deployment_id}-vault"
    owner = var.owner
  }

  provisioner "file" {
    content     = filebase64("${path.root}/files/vault/vault.service")
    destination = "/tmp/vault_base64.service"
  }

  provisioner "file" {
    content     = filebase64("${path.root}/files/vault/vault-config.hcl")
    destination = "/tmp/vault-config-base64.hcl"
  }

  provisioner "remote-exec" {
    inline = [
      "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt update && sudo apt install vault",
      "sudo adduser --system --group vault || true",
      "sudo mkdir -p /opt/vault/data",
      "sudo base64 -d /tmp/vault-config-base64.hcl > /tmp/vault-config.hcl",
      "sudo mv /tmp/vault-config.hcl /opt/vault/vault-config.hcl",
      "sudo base64 -d /tmp/vault_base64.service > /tmp/vault.service",
      "sudo mv /tmp/vault.service /etc/systemd/system/vault.service",
      "sudo chown -R vault:vault /opt/vault/data",
      "sudo chmod 664 /etc/systemd/system/vault.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable vault",
      "sudo systemctl start vault",
      "sleep 20",
      "export VAULT_ADDR=http://127.0.0.1:8200",
      "sudo -E vault operator init -n 1 -t 1 -format=json > /home/ubuntu/init.json",
      "sudo -E vault operator unseal \"`jq -r '.unseal_keys_b64[0]' init.json`\"",
      "sudo jq -r .root_token init.json > /home/ubuntu/vault_token",
      "echo \".................................Done setup.........................................\""
    ]
  }

  provisioner "local-exec" {
    command = <<-EOT
      ssh -o StrictHostKeyChecking=no -i ${path.root}/generated/${local.key_name} ubuntu@${aws_instance.bastion.public_ip} "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/ubuntu/ssh_key ubuntu@${self.private_ip}:/home/ubuntu/vault_token /home/ubuntu/vault_token"  
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${path.root}/generated/${local.key_name} ubuntu@${aws_instance.bastion.public_ip}:/home/ubuntu/vault_token ./generated/
      EOT
  }

  connection {
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    agent               = false
    bastion_private_key = tls_private_key.ssh.private_key_openssh

    host        = self.private_ip
    user        = "ubuntu"
    private_key = tls_private_key.ssh.private_key_openssh
  }

  depends_on = [
    module.vpc,
    local_file.private_key
  ]
}

resource "null_resource" "delete_vault_token" {

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOD
      rm ${path.root}/generated/vault_token 
      EOD
  }
}