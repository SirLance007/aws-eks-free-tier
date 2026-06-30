# ==========================================
# VPC Outputs
# ==========================================

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# ==========================================
# Free-Tier EC2 Output (Conditional)
# ==========================================

output "ec2_public_ip" {
  description = "Public IP of the EC2 web server (if EKS is disabled)"
  value       = var.create_eks_cluster ? "N/A (EKS is enabled)" : aws_instance.web[0].public_ip
}

output "ec2_web_url" {
  description = "HTTP URL to access the EC2 web page"
  value       = var.create_eks_cluster ? "N/A (EKS is enabled)" : "http://${aws_instance.web[0].public_ip}"
}

# ==========================================
# EKS Outputs (Conditional)
# ==========================================

output "cluster_name" {
  description = "Name of the EKS cluster (if enabled)"
  value       = var.create_eks_cluster ? aws_eks_cluster.this[0].name : "N/A (EKS is disabled)"
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS control plane"
  value       = var.create_eks_cluster ? aws_eks_cluster.this[0].endpoint : "N/A (EKS is disabled)"
}

output "configure_kubectl" {
  description = "Run this command to configure kubectl locally to connect to EKS"
  value       = var.create_eks_cluster ? "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.this[0].name}" : "N/A"
}
