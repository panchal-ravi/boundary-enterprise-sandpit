data "aws_ami" "an_image" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["099720109477"]
}

resource "tls_private_key" "ssh-ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}


resource "aws_instance" "linux" {
  ami                    = data.aws_ami.an_image.id
  instance_type          = "t3.micro"
  key_name               = var.aws_keypair_keyname
  subnet_id              = var.private_subnets[0]
  vpc_security_group_ids = [module.private-ssh-inbound.security_group_id]

  provisioner "file" {
    content     = tls_private_key.ssh-ca.public_key_openssh
    destination = "/tmp/ca.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/ca.pub /etc/ssh",
      "echo \"TrustedUserCAKeys /etc/ssh/ca.pub\" | sudo tee -a /etc/ssh/sshd_config",
      "sudo systemctl restart sshd",
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

  tags = {
    Name  = "${var.deployment_id}-linux"
    owner = var.owner
  }
}