locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = {
    Environment = var.env
    Project     = "AWS-EKS-Free-Tier-Practice"
    ManagedBy   = "Terraform"
    Owner       = "beginner-practice"
  }
}
