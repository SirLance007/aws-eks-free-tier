variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster or VPC resources"
  type        = string
}

variable "env" {
  description = "Deployment environment name (e.g. dev, test)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "create_eks_cluster" {
  description = "Whether to create EKS cluster (costs $0.10/hr). If false, deploys a free VPC and EC2 instance."
  type        = bool
  default     = false
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "instance_type" {
  description = "EC2 / Node Group instance type"
  type        = string
  default     = "t2.micro" # Free Tier eligible
}
