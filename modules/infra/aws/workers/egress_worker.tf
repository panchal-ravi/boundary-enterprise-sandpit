resource "aws_instance" "egress_worker" {
  ami             = data.aws_ami.worker_image.id
  instance_type   = var.instance_type
  key_name        = var.aws_keypair_key_name
  subnet_id       = element(var.private_subnets, 1)
  security_groups = [var.worker_egress_security_group_id]

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
      private_ip              = self.private_ip,
      upstream_worker_ip      = aws_instance.ingress_worker.private_ip,
      worker_auth_storage_kms = random_id.worker_auth_storage_kms.b64_std,
      activation_token        = boundary_worker.egress_worker.controller_generated_activation_token
    })
    destination = "/tmp/boundary-worker.hcl"
  }

  provisioner "file" {
    content     = file("${path.root}/generated/ssh_key")
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
    ]
  }


  connection {
    bastion_host        = var.bastion_ip 
    bastion_user        = "ubuntu"
    agent               = false
    bastion_private_key = file("${path.root}/generated/ssh_key") 

    host        = self.private_ip
    user        = "ubuntu"
    private_key = file("${path.root}/generated/ssh_key") 
  }

}

resource "boundary_worker" "egress_worker" {
  description                 = "egress worker"
  name                        = "egress-worker"
  scope_id                    = "global"
  worker_generated_auth_token = "" 
}