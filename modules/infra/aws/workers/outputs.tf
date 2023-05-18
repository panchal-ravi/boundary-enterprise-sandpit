output "worker_ingress_security_group_id" {
  value = module.ingress_worker_sg.security_group_id
}

output "worker_egress_security_group_id" {
  value = module.egress_worker_sg.security_group_id
}

output "ingress_worker_ip" {
  value = aws_instance.ingress_worker.public_ip
}

output "ingress_worker_private_ip" {
  value = aws_instance.ingress_worker.private_ip
}

output "egress_worker_ip" {
  value = aws_instance.egress_worker.private_ip
}
