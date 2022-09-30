#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "EKS-VPC-terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_subnet" "eks_vpc_subnet_public" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.eks_vpc.id

  tags = tomap({
    "Name"                                      = "EKS-VPC-Subnet-Public-terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_internet_gateway" "eks_vpc_internet_gateway" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "EKS-VPC-IG-terraform-eks-demo"
  }
}

resource "aws_route_table" "eks_vpc_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_vpc_internet_gateway.id
  }
}

resource "aws_route_table_association" "eks_vpc_route_table_association" {
  count = 2

  subnet_id      = aws_subnet.eks_vpc_subnet_public.*.id[count.index]
  route_table_id = aws_route_table.eks_vpc_route_table.id
}
