resource "aws_security_group" "k3s_sg" {
  name        = "k3s_sg"
  description = "Security Group for Kubernetes cluster"
  vpc_id      = var.vpc_id

  # Allow access to Kubernetes API from external sources
  ingress {
    description = "Allow access to Kubernetes API"
    from_port   = 6443  # Port used by the Kubernetes API Server
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow kubelet API traffic for communication between master and worker nodes within the VPC
  ingress {
    description = "Allow access to Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow NodePort range for services to be accessed externally
  ingress {
    description = "Allow NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow VXLAN (Flannel network overlay) for internal Kubernetes networking
  ingress {
    description = "Allow VXLAN for Flannel networking"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (required for nodes to communicate externally)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s_sg"
  }
}
