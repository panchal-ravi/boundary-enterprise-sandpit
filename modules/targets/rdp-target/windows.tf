# Get latest Windows Server 2016 AMI
data "aws_ami" "windows-2022" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}

resource "aws_instance" "windows" {
  ami                    = data.aws_ami.windows-2022.id //"ami-0b204ba02c86d0218"
  instance_type          = "t3.micro"
  key_name               = var.aws_keypair_keyname
  subnet_id              = var.private_subnets[0]
  vpc_security_group_ids = [module.private-rdp-inbound.security_group_id]
  get_password_data      = true

  tags = {
    Name  = "${var.deployment_id}-windows"
    owner = var.owner
  }
}

resource "local_file" "windows_password" {
  content  = rsadecrypt(aws_instance.windows.password_data, file("${path.root}/generated/rsa_key"))
  filename = "${path.root}/generated/windows_password"
}