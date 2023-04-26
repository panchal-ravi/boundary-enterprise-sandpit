source "amazon-ebs" "ubuntu-image" {
  ami_name = "${var.owner}-boundary-enterprise-{{timestamp}}"
  region = "${var.aws_region}"
  instance_type = var.aws_instance_type
  tags = {
    Name = "${var.owner}-boundary-enterprise"
  }
  source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
        // name = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
        root-device-type = "ebs"
      }
      owners = ["099720109477"]
      most_recent = true
  }
  communicator = "ssh"
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu-image"
  ]
  /* provisioner "file" {
    source      = "../../files/consul.service"
    destination = "/tmp/consul.service"
  } */
  provisioner "shell" {
    inline = [
      "sleep 10",
      "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
      "sudo apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
      "sudo apt update",
      /* "sudo apt install boundary-enterprise", */ //this did not work
      "sudo apt install unzip -y",
      "sudo apt install default-jre -y",
      "sudo apt install net-tools -y",
      "sudo apt install postgresql-client -y",
      "sudo apt install jq -y",
      "curl -k -O \"https://releases.hashicorp.com/boundary-worker/${var.boundary_version}/boundary-worker_${var.boundary_version}_linux_amd64.zip\"",
      "unzip boundary-worker_${var.boundary_version}_linux_amd64.zip",
      "sudo mv boundary-worker /usr/local/bin/boundary"
    ]
  }

}
