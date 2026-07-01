provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.env
      ManagedBy   = "Terraform"
      Project     = "AWS-EKS-Free-Tier-Practice"
      ClusterName = var.cluster_name
    }
  }
}

locals {
  # If EKS is created, get its endpoint and certificate; otherwise, leave empty.
  cluster_endpoint = var.create_eks_cluster ? data.aws_eks_cluster.eks[0].endpoint : ""
  cluster_ca       = var.create_eks_cluster ? base64decode(data.aws_eks_cluster.eks[0].certificate_authority[0].data) : ""
}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = var.create_eks_cluster ? [
      "eks",
      "get-token",
      "--cluster-name",
      var.cluster_name,
      "--region",
      var.region
    ] : []
  }
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = var.create_eks_cluster ? [
        "eks",
        "get-token",
        "--cluster-name",
        var.cluster_name,
        "--region",
        var.region
      ] : []
    }
  }
}
