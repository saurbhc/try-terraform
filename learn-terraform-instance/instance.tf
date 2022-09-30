data "aws_ami" "ububtu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  # ami           = data.aws_ami.ububtu.id
  ami           = "ami-096800910c1b781ba"
  instance_type = "t2.micro"

  user_data_replace_on_change = true
  user_data                   = file("user_data.tpl")

  associate_public_ip_address = true
  key_name                    = aws_key_pair.saurabh_public_key.key_name
  vpc_security_group_ids      = [aws_security_group.my_vpc_security_group_http_https_ssh.id]
  subnet_id                   = aws_subnet.my_vpc_public_subnet.id
  # network_interface {
  #   network_interface_id = aws_network_interface.my_vpc_network_interface_public.id
  #   device_index         = 0
  # }

  tags = {
    Name = "Instance-Web-InPublicSubnet"
  }
}

# AWS Instance Create
# - Name and tags DONE
# - AMI DONE
# - Instance Type DONE
# - Key Pair
# - Network Settings
#   - VPC
#   - Subnet
#   - Auto-assign public IP - Enable
#   - Firewall (security groups) - Create with rules
#   - Configure storage
# - Advance
#   - Request Spot?
#   - User data
