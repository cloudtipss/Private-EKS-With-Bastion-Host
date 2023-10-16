provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_eks_cluster" "this" {
  name = local.cluster_name
  depends_on = [
    module.eks.eks_managed_node_groups,
  ]
}

data "aws_eks_cluster_auth" "this" {
  name = local.cluster_name
  depends_on = [
    module.eks.eks_managed_node_groups,
  ]
}

output "jhfhjf" {
  description = "The public IP address assigned to the instance"
  value       = data.aws_eks_cluster.this.endpoint
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
}
