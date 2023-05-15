resource "random_id" "worker_auth_storage_kms" {
  byte_length = 32
}

resource "aws_instance" "ingress_worker" {
  ami             = data.aws_ami.an_image.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.this.key_name
  subnet_id       = element(module.vpc.public_subnets, 1)
  security_groups = [module.ingress_worker_sg.security_group_id]

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name  = "${var.deployment_id}-worker-ingress"
    owner = var.owner
  }

  provisioner "file" {
    content     = filebase64("${path.root}/files/boundary/install.sh")
    destination = "/tmp/install_base64.sh"
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/boundary/boundary-worker-ingress.hcl.tpl", {
      controller_lb_dns       = aws_lb.controller_internal_lb.dns_name,
      private_ip              = self.private_ip,
      public_ip               = self.public_ip,
      public_ip               = self.public_ip,
      worker_auth_storage_kms = random_id.worker_auth_storage_kms.b64_std,
    })
    destination = "/tmp/boundary-worker.hcl"
  }

  provisioner "file" {
    content     = tls_private_key.ssh.private_key_openssh
    destination = "/home/ubuntu/ssh_key"
  }

  provisioner "file" {
    source      = "${path.root}/files/observability/node-exporter.service"
    destination = "/tmp/node-exporter.service"
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

      "sudo mv /tmp/node-exporter.service /etc/systemd/system/node_exporter.service",
      "sudo groupadd -f node_exporter",
      "sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter",
      "sudo mkdir /etc/node_exporter.d",
      "sudo chown node_exporter:node_exporter /etc/node_exporter.d",
      "sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz",
      "sudo tar -xvf node_exporter-1.5.0.linux-amd64.tar.gz",
      "sudo mv node_exporter-1.5.0.linux-amd64 node_exporter-files",
      "sudo cp node_exporter-files/node_exporter /usr/local/bin/",
      "sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter",
      "sudo chmod 664 /etc/systemd/system/node_exporter.service",

      "sudo systemctl daemon-reload",
      "sudo systemctl start node_exporter",
      "sudo systemctl start boundary-worker",
      "sleep 10",
      "sudo chmod 664 /etc/boundary.d/auth_storage/auth_request_token",
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${path.root}/generated/${local.key_name} ubuntu@${self.public_ip}:/etc/boundary.d/auth_storage/auth_request_token ./generated/ingress_worker_auth_token"
  }

  connection {
    host        = self.public_ip
    user        = "ubuntu"
    agent       = false
    private_key = tls_private_key.ssh.private_key_openssh
  }

  depends_on = [
    module.vpc,
    local_file.private_key,
    aws_instance.controller
  ]
}

resource "null_resource" "register_worker_ingress" {

  provisioner "local-exec" {
    command = <<-EOD
      export BOUNDARY_ADDR=https://${aws_lb.controller_lb.dns_name}
      export BOUNDARY_RECOVERY_CONFIG=${path.root}/generated/kms_recovery.hcl
      export BOUNDARY_TLS_INSECURE=true
      boundary workers create worker-led -scope-id=global -worker-generated-auth-token=${trimspace(file("${path.root}/generated/ingress_worker_auth_token"))}
      echo "https://${aws_lb.controller_lb.dns_name}" > ${path.root}/generated/boundary_cluster_url
      EOD
    //command = "export BOUNDARY_ADDR=https://${aws_lb.controller_lb.dns_name} && export AUTH_ID=$(boundary auth-methods -keyring-type none -scope-id global -format json -tls-insecure true | jq \".items[].id\" -r) && export BOUNDARY_AUTHENTICATE_PASSWORD_PASSWORD=file() && boundary authenticate password -auth-method-id=$AUTH_ID -login-name=${var.hcp_boundary_admin} -password env://BOUNDARY_AUTHENTICATE_PASSWORD_PASSWORD && boundary workers create worker-led -scope-id global -worker-generated-auth-token=${trimspace(file("${path.root}/generated/worker_ingress_auth_request_token"))}"
  }

  depends_on = [
    aws_instance.ingress_worker
  ]
}

resource "null_resource" "delete_ingress_worker_auth_token" {

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOD
      rm ${path.root}/generated/ingress_worker_auth_token 
      rm ${path.root}/generated/boundary_cluster_url
      EOD
  }
}

/* resource "boundary_worker" "ingress_worker" {
  description                 = "ingress worker"
  name                        = "ingress-worker"
  scope_id                    = "global"
  worker_generated_auth_token = trimspace(file("${path.root}/generated/ingress_worker_auth_token"))
  depends_on = [
    aws_instance.controller,
    aws_instance.ingress_worker,
    aws_lb.controller_lb
  ]
} */
