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
