# Query the active AWS Account Details (Account ID, ARN, etc.)
data "aws_caller_identity" "current" {}

# Query all available Availability Zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Dynamic query to fetch EKS details only if the cluster is being built
data "aws_eks_cluster" "eks" {
  count = var.create_eks_cluster ? 1 : 0
  name  = var.create_eks_cluster ? aws_eks_cluster.this[0].name : var.cluster_name
}
