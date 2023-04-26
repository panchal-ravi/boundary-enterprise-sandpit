module "rds-inbound-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "${var.deployment_id}-rds-allow_inbound"
  description         = "RDS inbound sg"
  vpc_id              = var.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = var.worker_egress_security_group_id
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = var.worker_ingress_security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "RDS port"
      source_security_group_id = var.worker_egress_security_group_id // Only egress worker should be allowed to connect to DB.
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "RDS port"
      source_security_group_id = var.worker_ingress_security_group_id //This is not required. It is used here to configure test database.
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "RDS port"
      source_security_group_id = var.vault_security_group_id //This is required by Vault to generate dynamic credentials
    },
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
