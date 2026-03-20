output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.x3_tier_vpc.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public_subnet.id
}

output "private_app_subnet_id" {
  description = "App subnet ID"
  value       = aws_subnet.private_app_subnet.id
}

output "private_db_subnet_id" {
  description = "DB subnet ID"
  value       = aws_subnet.private_db_subnet.id
}

output "web_instance_public_ip" {
  description = "Public IP of Web server"
  value       = aws_instance.web.public_ip
}

output "web_instance_id" {
  description = "Web EC2 instance ID"
  value       = aws_instance.web.id
}

output "app_instance_private_ip" {
  description = "Private IP of App server"
  value       = aws_instance.app.private_ip
}

output "db_instance_private_ip" {
  description = "Private IP of DB server"
  value       = aws_instance.db.private_ip
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat.id
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}