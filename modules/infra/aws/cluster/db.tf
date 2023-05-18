resource "aws_db_subnet_group" "this" {
  name       = "${var.deployment_id}-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "boundary-enterprise-database"
  }
}

resource "aws_db_instance" "this" {
  identifier             = "${var.deployment_id}-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  engine                 = "postgres"
  db_name                = "boundary"
  engine_version         = "13.7"
  username               = var.controller_db_username
  password               = var.controller_db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [module.controller_db_sg.security_group_id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.deployment_id}-grp"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}