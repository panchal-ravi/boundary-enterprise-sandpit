output "controller_ips" {
  value = aws_instance.controller[*].private_ip
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "ingress_worker_ip" {
  value = aws_instance.ingress_worker.public_ip
}

output "egress_worker_ip" {
  value = aws_instance.egress_worker.private_ip
}

output "vault_ip" {
  value = aws_instance.vault.private_ip
}

output "boundary_cluster_url" {
  value = aws_lb.controller_lb.dns_name
}

output "boundary_cluster_url_internal" {
  value = aws_lb.controller_internal_lb.dns_name
}

output "auth0_client" {
  value = {
    client_id     = auth0_client.my_client.client_id,
    client_secret = auth0_client.my_client.client_secret
  }
}

output "okta_client" {
  value = {
    client_id     = okta_app_oauth.my_client.client_id,
    client_secret = okta_app_oauth.my_client.client_secret
  }
}

output "worker_egress_security_group_id" {
  value = module.egress_worker_sg.security_group_id
}

output "vault_security_group_id" {
  value = module.vault_sg.security_group_id
}

output "worker_ingress_security_group_id" {
  value = module.ingress_worker_sg.security_group_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "aws_keypair_keyname" {
  value = aws_key_pair.this.key_name
}
