output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.x3_tier_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_app_subnet_id" {
  value = aws_subnet.private_app_subnet.id
}

output "private_db_subnet_id" {
  value = aws_subnet.private_db_subnet.id
}

output "web_instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "app_instance_private_ip" {
  value = aws_instance.app_instance.private_ip
}

output "db_instance_private_ip" {
  value = aws_instance.db.private_ip
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}