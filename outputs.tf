output "cluster_name" {
  description = "Name of the Cluster created"
  value       = module.eks.cluster_name
}

output "EC2_public_ip" {
  description = "The public IP address assigned to the instance"
  value       = module.ec2-instance.public_ip
}
