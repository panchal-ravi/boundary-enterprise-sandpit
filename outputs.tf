output "deployment_id" {
  value = local.deployment_id
}

output "bastion_ip" {
  value = module.boundary-cluster.bastion_ip
}

output "boundary_ips" {
  value = {
    controller_ips    = module.boundary-cluster.controller_ips,
    ingress_worker_ip = module.boundary-cluster.ingress_worker_ip,
    egress_worker_ip  = module.boundary-cluster.egress_worker_ip,
    vault_ip          = module.boundary-cluster.vault_ip
  }
}

output "boundary_cluster_url" {
  value = module.boundary-cluster.boundary_cluster_url
}
