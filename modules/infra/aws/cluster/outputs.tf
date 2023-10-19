output "controller_ips" {
  value = aws_instance.controller[*].private_ip
}

output "controller_ops_address" {
  value = [for instance in aws_instance.controller: "${instance.private_ip}:9203"]
}

output "controller_node_exporter_address" {
  value = [for instance in aws_instance.controller: "${instance.private_ip}:9100"]
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
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

output "bastion_security_group_id" {
  value = module.bastion_sg.security_group_id
}

output "vault_security_group_id" {
  value = module.vault_sg.security_group_id
}

output "worker_ingress_security_group_id" {
  value = module.ingress_worker_sg.security_group_id
}

output "worker_egress_security_group_id" {
  value = module.egress_worker_sg.security_group_id
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

output "controller_internal_dns" {
  value = aws_lb.controller_internal_lb.dns_name
}

output "azure_client" {
  value = {
    client_id = azuread_application.client_app.application_id,
    client_secret = azuread_application_password.client_app.value
  }
}
output "az_ad_group_admin_id" {
  value = azuread_group.admin.object_id
}
output "az_ad_group_analyst_id" {
  value = azuread_group.analyst.object_id
}

output "worker_instance_profile" {
  value = aws_iam_instance_profile.worker_instance_profile.name
}

output "session_storage_role_arn" {
  value = aws_iam_role.session_storage_role.arn
}