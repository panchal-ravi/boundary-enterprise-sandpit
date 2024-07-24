output "kibana_url" {
  value = "${data.kubernetes_service_v1.kibana.status.0.load_balancer.0.ingress.0.hostname}:5601"
}

output "controller_generated_activation_token" {
  value = boundary_worker.k8s_worker.controller_generated_activation_token
}