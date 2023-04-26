resource "aws_instance" "egress_worker" {
  ami             = data.aws_ami.an_image.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.this.key_name
  subnet_id       = element(module.vpc.private_subnets, 1)
  security_groups = [module.egress_worker_sg.security_group_id]

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name  = "${var.deployment_id}-worker-egress"
    owner = var.owner
  }

  provisioner "file" {
    content     = filebase64("${path.root}/files/boundary/install.sh")
    destination = "/tmp/install_base64.sh"
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/boundary/boundary-worker-egress.hcl.tpl", {
      private_ip         = self.private_ip,
      upstream_worker_ip = aws_instance.ingress_worker.private_ip,
      worker_auth_storage_kms = random_id.worker_auth_storage_kms.b64_std,
    })
    destination = "/tmp/boundary-worker.hcl"
  }

  provisioner "file" {
    content     = tls_private_key.ssh.private_key_openssh
    destination = "/home/ubuntu/ssh_key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo base64 -d /tmp/install_base64.sh > /tmp/install.sh",
      "sudo mkdir -p /etc/boundary.d/auth_storage",
      "sudo touch /etc/boundary.d/boundary.env",
      "sudo touch /etc/boundary.d/boundary-recovery-kms.hcl",
      "sudo chown -R boundary:boundary /etc/boundary.d",
      "sudo mv /tmp/install.sh /home/ubuntu/install.sh",
      "sudo chmod +x /home/ubuntu/install.sh",
      "sudo chmod 400 /home/ubuntu/ssh_key",
      "sudo mv /tmp/boundary-worker.hcl /etc/boundary.d/boundary-worker.hcl",
      "sudo /home/ubuntu/install.sh worker",
      "sudo systemctl start boundary-worker",
      "sleep 10",
      "sudo chmod 664 /etc/boundary.d/auth_storage/auth_request_token",
    ]
  }

  provisioner "local-exec" {
    command = <<-EOT
      ssh -o StrictHostKeyChecking=no -i ${path.root}/generated/${local.key_name} ubuntu@${aws_instance.bastion.public_ip} "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/ubuntu/ssh_key ubuntu@${self.private_ip}:/etc/boundary.d/auth_storage/auth_request_token /home/ubuntu/egress_worker_auth_token"
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${path.root}/generated/${local.key_name} ubuntu@${aws_instance.bastion.public_ip}:/home/ubuntu/egress_worker_auth_token ./generated/
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
    local_file.private_key,
    aws_instance.controller
  ]
}

resource "null_resource" "register_worker_egress" {

  provisioner "local-exec" {
    command = "export BOUNDARY_ADDR=https://${aws_lb.controller_lb.dns_name} && export BOUNDARY_RECOVERY_CONFIG=${path.root}/generated/kms_recovery.hcl && export BOUNDARY_TLS_INSECURE=true && boundary workers create worker-led -scope-id=global -worker-generated-auth-token=${trimspace(file("${path.root}/generated/egress_worker_auth_token"))}"
  }

  depends_on = [
    aws_instance.egress_worker
  ]
}

resource "null_resource" "delete_egress_worker_auth_token" {

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOD
      rm ${path.root}/generated/egress_worker_auth_token 
      EOD
  }
}
