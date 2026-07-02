# Free AMI lookup for Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  count       = var.create_eks_cluster ? 0 : 1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Dynamic query to fetch EKS details only if the cluster is being built
data "aws_eks_cluster" "eks" {
  count = var.create_eks_cluster ? 1 : 0
  name  = var.create_eks_cluster ? aws_eks_cluster.this[0].name : var.cluster_name
}
