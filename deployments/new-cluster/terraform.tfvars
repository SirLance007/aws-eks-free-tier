# AWS Provider Configuration
region       = "us-east-1"
cluster_name = "new-cluster"
env          = "dev"

# Free-Tier configuration (Switch to true to test EKS at $0.10/hr)
create_eks_cluster = false

# Network configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# Low cost instance type for testing
instance_type = "t3.micro"
