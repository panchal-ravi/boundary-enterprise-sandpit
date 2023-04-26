module "private-rdp-inbound" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-private-rdp"
  description = "Allow RDP private inbound"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "rdp-tcp"
      source_security_group_id = var.worker_egress_security_group_id
    }
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}