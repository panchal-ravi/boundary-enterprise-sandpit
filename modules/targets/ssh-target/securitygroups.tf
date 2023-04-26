module "private-ssh-inbound" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-private-ssh"
  description = "Allow ssh private inbound"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = var.worker_ingress_security_group_id
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = var.worker_egress_security_group_id
    },
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
