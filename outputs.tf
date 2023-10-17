output "Connect_to_instance" {
  description = "The public IP address assigned to the instance"
  value       = "ssh -i ${var.path}/${var.private_key_name} ec2-user@${module.ec2-instance.public_ip}"
}

output "cluster_name" {
  description = "Name of the Cluster created"
  value       = module.eks.cluster_name
}

output "EC2_public_ip" {
  description = "The public IP address assigned to the instance"
  value       = module.ec2-instance.public_ip
}

output "current_ipv4_json" {
  value = data.external.current_ipv4.result["ip"]
}

