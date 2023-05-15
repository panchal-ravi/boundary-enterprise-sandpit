module "controller_db_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-controller-db"
  description = "boundary controller database inbound sg"
  vpc_id      = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "RDS port"
      source_security_group_id = module.controller_sg.security_group_id // Only egress worker should be allowed to connect to DB.
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "bastion_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.deployment_id}-bastion"
  description = "bastion inbound sg"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}


module "controller_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.deployment_id}-controller"
  description = "boundary-controller inbound sg"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Bastion to SSH"
      source_security_group_id = module.bastion_sg.security_group_id
    },
    {
      from_port                = 9200
      to_port                  = 9200
      protocol                 = "tcp"
      description              = "LB to Controller API"
      source_security_group_id = module.web_sg.security_group_id
    },
    {
      from_port                = 9203
      to_port                  = 9203
      protocol                 = "tcp"
      description              = "LB to Controller Health Check"
      source_security_group_id = module.web_sg.security_group_id
    },
    /*
    {
      from_port   = 9201
      to_port     = 9201
      protocol    = "tcp"
      description = "boundary-cluster ports for internal network"
      source_security_group_id = module.web_internal_sg.security_group_id
    },
    */
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      description = "boundary-controller api port access for VPC network"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 9203
      to_port     = 9203
      protocol    = "tcp"
      description = "boundary-controller ops port access for VPC network"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "node-metrics prometheus exporter"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 9201
      to_port     = 9201
      protocol    = "tcp"
      description = "boundary-controller cluster port used by worker to connect within VPC network"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "web_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.deployment_id}-controller-api"
  description = "Allow all web traffic"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "ingress_worker_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.deployment_id}-ingress-worker"
  description = "Traffic to ingress worker"
  vpc_id      = module.vpc.vpc_id

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
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "node-metrics prometheus exporter"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "egress_worker_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-egress-worker"
  description = "traffic to egress worker"
  vpc_id      = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9203
      to_port     = 9203
      protocol    = "tcp"
      description = "boundary-worker ops port"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "node-metrics prometheus exporter"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}


module "vault_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-vault"
  description = "vault inbound"
  vpc_id      = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    },
    {
      from_port                = 8200
      to_port                  = 8200
      protocol                 = "tcp"
      description              = "vault api ports"
      source_security_group_id = module.ingress_worker_sg.security_group_id
    },
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

/*
module "web_internal_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.deployment_id}-controller-api"
  description = "Allow all web traffic internal"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 9201
      to_port     = 9201
      protocol    = "tcp"
      description = "boundary-controller cluster port access for VPC network"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
*/
