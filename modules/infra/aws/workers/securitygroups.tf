module "ingress_worker_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.deployment_id}-ingress-worker"
  description = "Traffic to ingress worker"
  vpc_id      =  var.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 9202
      to_port     = 9202
      protocol    = "tcp"
      description = "boundary-worker proxy port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9203
      to_port     = 9203
      protocol    = "tcp"
      description = "boundary-worker ops port"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "node-metrics prometheus exporter"
      cidr_blocks = var.vpc_cidr_block
    }
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "egress_worker_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-egress-worker"
  description = "traffic to egress worker"
  vpc_id      = var.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = var.bastion_security_group_id
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9203
      to_port     = 9203
      protocol    = "tcp"
      description = "boundary-worker ops port"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "node-metrics prometheus exporter"
      cidr_blocks = var.vpc_cidr_block
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
