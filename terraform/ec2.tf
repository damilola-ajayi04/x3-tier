# ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "flask-cicd-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

# Web EC2
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = "demo_app_key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = { Name = "web-tier" }
}

# App EC2
resource "aws_instance" "app_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_app_subnet.id
  key_name               = "demo_app_key"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io awscli
              EOF

  tags = { Name = "flask-app-instance" }
}

# DB EC2
resource "aws_instance" "db" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_db_subnet.id
  key_name               = "demo_app_key"
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = { Name = "db-tier" }
}