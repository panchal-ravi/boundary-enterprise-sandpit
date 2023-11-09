/*
output "controller_ips" {
  value = aws_instance.controller[*].private_ip
}

output "controller_ops_address" {
  value = [for instance in aws_instance.controller : "${instance.private_ip}:9203"]
}

output "boundary_cluster_url_internal" {
  value = aws_lb.controller_internal_lb.dns_name
}

output "controller_internal_dns" {
  value = aws_lb.controller_internal_lb.dns_name
} 

output "controller_node_exporter_address" {
  value = [for instance in aws_instance.controller : "${instance.private_ip}:9100"]
}
*/

output "infra_aws" {
  value = {
    vpc_cidr_block                   = module.vpc.vpc_cidr_block
    vpc_id                           = module.vpc.vpc_id
    public_subnets                   = module.vpc.public_subnets
    private_subnets                  = module.vpc.private_subnets
    aws_keypair_key_name             = aws_key_pair.this.key_name
    controller_ips                   = aws_instance.controller[*].private_ip
    controller_internal_dns          = aws_lb.controller_internal_lb.dns_name
    controller_node_exporter_address = [for instance in aws_instance.controller : "${instance.private_ip}:9100"]
    controller_ops_address           = [for instance in aws_instance.controller : "${instance.private_ip}:9203"]
    boundary_cluster_url_internal    = aws_lb.controller_internal_lb.dns_name
    bastion_ip                       = aws_instance.bastion.public_ip
    vault_ip                         = aws_instance.vault.private_ip
    bastion_security_group_id        = module.bastion_sg.security_group_id
    vault_security_group_id          = module.vault_sg.security_group_id
    worker_ingress_security_group_id = module.ingress_worker_sg.security_group_id
    worker_egress_security_group_id  = module.egress_worker_sg.security_group_id
    boundary_cluster_url             = aws_lb.controller_lb.dns_name
    worker_instance_profile          = aws_iam_instance_profile.worker_instance_profile.name
    session_storage_role_arn         = aws_iam_role.session_storage_role.arn
  }
}
