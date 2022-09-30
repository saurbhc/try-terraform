output "instance_public_dns" {
  value       = aws_instance.web.public_dns
  description = "AWS EC2 Instance Public DNS"
}

output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "AWS EC2 Instance Public IP"
}
