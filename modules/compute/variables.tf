variable "region" {
  type        = string
  description = "The AWS region"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "env" {
  type        = string
  description = "The environment name"
}

variable "create_eks_cluster" {
  type        = bool
  default     = false
  description = "Whether to create EKS cluster"
}

variable "cluster_version" {
  type        = string
  default     = "1.30"
  description = "EKS version"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
}
