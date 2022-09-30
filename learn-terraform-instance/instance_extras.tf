resource "aws_key_pair" "saurabh_public_key" {
  key_name   = "saurabh-dev-temp-instance-id-rsa-pub"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrYqiqIsiNa2+FrEc2aJVEhJB/RId9rRv/flMhNSFjhT91HvJONUso4IGXgfD3U4Y3mchDfhsSeuqyLCyiGKOr9fpIpvt9tWkQ70Fmaj/4RtV/JYU7JmBHHrVhBtvL+NFtCa9EzgxQrqfKIA83wMpxt0qNfDz3BUVTWSvXsMBbDhi2uQ/mokkOuJktjPtjJYIpQ3brORLHou4ykzcUx7zrOJfN5/icqyTVLnTtGJLkxxF2TyHN9u/ejbWXA5/ntzXaiu45WKcE95b3O+pe+vZkjqqIlw+BamlwZEFFsHu6lt1zKChiWjg2OZCB/Dm7BrKqoe3OuHNbjitZdA9fFxC1gD9APDJW9tN4rHvQd64eY4cFeRm1tg/4u5wbuwpZjLGwk6m/0qQxyqCBGAGahxYIdFL40NPXhw8Cac3dIU8hRNYld1lcDA4uilHJAUW22Ph4Q1/8ftjrAFfhjKt6QX36WMybmicgaGCNoybDkkpukN3196UPa8m1/95KtM+ns9Y0PIpkqj7fQDY4LXuTq9C0B7mXIWN+oH5SBA5OhD7CqolW/P2PXLuOwaSqj2dw32gzwGq5phM3bEMSCKnz1K90dKXIHpVdumoxu0cHLsJssoYqoFrN6lsy93HcQswMVaxlhnj6FaVSGy9Ype7cXnKv1U0sbGzDyN/VRnnBBBz4wQ== ubuntu@ip-172-31-7-169"
}

# ---

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_internet_gateway" "my_vpc_ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    "Name" = "MyVPC-InternetGateway"
  }
}

# ---

# Public
resource "aws_subnet" "my_vpc_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "MyVPC-Public-Subnet"
  }
}
resource "aws_route_table" "my_vpc_route_table_public" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.my_vpc_ig.id
  }

  tags = {
    "Name" = "MyVPC-Public-RouteTable"
  }
}
resource "aws_route_table_association" "my_vpc_route_table_association_public" {
  subnet_id      = aws_subnet.my_vpc_public_subnet.id
  route_table_id = aws_route_table.my_vpc_route_table_public.id
}

# ---

# Private
resource "aws_subnet" "my_vpc_private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "MyVPC-Private-Subnet"
  }
}
resource "aws_eip" "my_vpc_elastic_ip" {
  vpc        = true
  depends_on = [aws_internet_gateway.my_vpc_ig]

  tags = {
    "Name" = "MyVPC-ElasticIP"
  }
}
resource "aws_nat_gateway" "my_vpc_nat_gateway" {
  allocation_id = aws_eip.my_vpc_elastic_ip.id
  subnet_id     = aws_subnet.my_vpc_public_subnet.id

  tags = {
    "Name" = "MyVPC-NATGateway"
  }
}
resource "aws_route_table" "my_vpc_route_table_private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0" # Traffic from Private Subnet reaches Internet via NAT Gateway    
    nat_gateway_id = aws_nat_gateway.my_vpc_nat_gateway.id
  }

  tags = {
    "Name" = "MyVPC-Private-Subnet"
  }
}
resource "aws_route_table_association" "my_vpc_route_table_association_private" {
  subnet_id      = aws_subnet.my_vpc_private_subnet.id
  route_table_id = aws_route_table.my_vpc_route_table_private.id
}

# ---

resource "aws_security_group" "my_vpc_security_group_http_https_ssh" {
  name        = "my_vpc_security_group_http_https_ssh"
  description = "Allow http/https/ssh inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyVPC-SecurityGroup-http-https-ssh"
  }
}

# ---

# resource "aws_network_interface" "my_vpc_network_interface_public" {
#   subnet_id       = aws_subnet.my_vpc_public_subnet.id
#   security_groups = [aws_security_group.my_vpc_security_group_http_https_ssh.id]

#   tags = {
#     Name = "MyVPC-NetworkInterface-Public"
#   }
# }

# resource "aws_network_interface" "my_vpc_network_interface_private" {
#   subnet_id       = aws_subnet.my_vpc_private_subnet.id
#   security_groups = [aws_security_group.my_vpc_security_group_http_https_ssh.id]

#   tags = {
#     Name = "MyVPC-NetworkInterface-Private"
#   }
# }
