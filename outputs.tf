output "deployment_id" {
  value = local.deployment_id
}

output "bastion_ip" {
  value = module.boundary-cluster.bastion_ip
}

output "boundary_ips" {
  value = {
    controller_ips    = module.boundary-cluster.controller_ips,
    ingress_worker_ip = module.boundary-workers.ingress_worker_ip,
    egress_worker_ip  = module.boundary-workers.egress_worker_ip,
    vault_ip          = module.boundary-cluster.vault_ip
  }
}

output "boundary_cluster_url" {
  value = "https://${module.boundary-cluster.boundary_cluster_url}"
}

output "kibana_url" {
  value = module.k8s-target.kibana_url
}