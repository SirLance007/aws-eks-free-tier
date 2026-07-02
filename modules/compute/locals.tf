locals {
  common_tags = {
    Environment = var.env
    Project     = "AWS-EKS-Free-Tier-Practice"
    ManagedBy   = "Terraform"
    Owner       = "beginner-practice"
  }
}
