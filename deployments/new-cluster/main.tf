# ==========================================
# VPC Networking (Created for both EC2 & EKS)
# ==========================================

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-vpc"
  })
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "${var.cluster_name}-public-${local.availability_zones[count.index]}"
    "kubernetes.io/role/elb" = "1" # Required if deploying Kubernetes LoadBalancers
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =======================================================
# Option A: AWS Free-Tier EC2 Instance (if EKS is disabled)
# =======================================================

resource "aws_security_group" "ec2" {
  count       = var.create_eks_cluster ? 0 : 1
  name        = "${var.cluster_name}-ec2-sg"
  description = "Allow inbound SSH and HTTP"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

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

resource "aws_instance" "web" {
  count         = var.create_eks_cluster ? 0 : 1
  ami           = data.aws_ami.amazon_linux[0].id
  instance_type = var.instance_type # Default is t2.micro (Free Tier)
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.ec2[0].id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from EKS Free Tier Practice Lab!</h1>" > /var/www/html/index.html
              EOF

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-free-tier-web"
  })
}

# ==========================================
# Option B: AWS EKS Cluster (if EKS is enabled)
# ==========================================

# 1. IAM Role for EKS Control Plane
resource "aws_iam_role" "eks_cluster" {
  count = var.create_eks_cluster ? 1 : 0
  name  = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.create_eks_cluster ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster[0].name
}

# 2. EKS Cluster Resource
resource "aws_eks_cluster" "this" {
  count    = var.create_eks_cluster ? 1 : 0
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster[0].arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = local.common_tags
}

# 3. IAM Role for EKS Managed Worker Nodes
resource "aws_iam_role" "eks_nodes" {
  count = var.create_eks_cluster ? 1 : 0
  name  = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.create_eks_cluster ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes[0].name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.create_eks_cluster ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes[0].name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.create_eks_cluster ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes[0].name
}

# 4. EKS Managed Node Group (Worker Nodes)
resource "aws_eks_node_group" "this" {
  count           = var.create_eks_cluster ? 1 : 0
  cluster_name    = aws_eks_cluster.this[0].name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes[0].arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = ["t3.micro"] # Low-cost instance for test deployment

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only
  ]

  tags = local.common_tags
}
