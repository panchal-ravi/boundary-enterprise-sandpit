output "ingress_worker_ip" {
  value = aws_instance.ingress_worker.public_ip
}

output "ingress_worker_private_ip" {
  value = aws_instance.ingress_worker.private_ip
}

output "egress_worker_ip" {
  value = aws_instance.egress_worker.private_ip
}


output "boundary_workers" {
  value = {
    ingress_worker_public_ip  = aws_instance.ingress_worker.public_ip,
    ingress_worker_private_ip = aws_instance.ingress_worker.private_ip,
    egress_worker_private_ip  = aws_instance.egress_worker.private_ip
  }
}
