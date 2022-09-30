#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "iam_role_eks_demo" {
  name = "IAM-Role-terraform-eks-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "iam_role_eks_policy_attachment-demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam_role_eks_demo.name
}

resource "aws_iam_role_policy_attachment" "iam_role_eks_policy_attachment-demo-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.iam_role_eks_demo.name
}

resource "aws_security_group" "eks_sg_demo-cluster" {
  name        = "eks-sg-terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-sg-terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "eks-sg-rule-demo-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_sg_demo-cluster.id
  type              = "ingress"
}

resource "aws_eks_cluster" "eks-cluster-demo" {
  name     = var.cluster_name
  role_arn = aws_iam_role.iam_role_eks_demo.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_sg_demo-cluster.id]
    subnet_ids         = aws_subnet.eks_vpc_subnet_public[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.iam_role_eks_policy_attachment-demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.iam_role_eks_policy_attachment-demo-cluster-AmazonEKSVPCResourceController,
  ]
}
