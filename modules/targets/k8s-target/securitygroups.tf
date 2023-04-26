module "private-ssh" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.deployment_id}-private-ssh"
  description = "Allow ssh private inbound"
  vpc_id      = var.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = [var.vpc_cidr]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
} 