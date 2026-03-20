# VPC

resource "aws_vpc" "x3_tier_vpc" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "x3-tier-vpc"
  }
}

# Subnets

# public subnet web

resource "aws_subnet" "public_subnet" {

  vpc_id                  = aws_vpc.x3_tier_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "web-public-subnet"
  }
}

# private subnet app

resource "aws_subnet" "private_app_subnet" {

  vpc_id            = aws_vpc.x3_tier_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "app-private-subnet"
  }
}

# private subnet db

resource "aws_subnet" "private_db_subnet" {

  vpc_id            = aws_vpc.x3_tier_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "db-private-subnet"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.x3_tier_vpc.id

  tags = {
    Name = "x3-tier-igw"
  }
}

# NAT Gateway

# Nat EIP

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Nat Gateway

resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "x3-tier-nat"
  }
}

# Route Tables

# Public Route Table Web

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.x3_tier_vpc.id
}

resource "aws_route" "public_internet" {

  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_assoc" {

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table App

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.x3_tier_vpc.id
}

resource "aws_route" "private_nat" {

  route_table_id         = aws_route_table.private_rt.id
  nat_gateway_id         = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "app_assoc" {

  subnet_id      = aws_subnet.private_app_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Private Route Table Db

resource "aws_route_table_association" "db_assoc" {

  subnet_id      = aws_subnet.private_db_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Groups

# Web SG
resource "aws_security_group" "web_sg" {

  name   = "web-sg"
  vpc_id = aws_vpc.x3_tier_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

# App SG
resource "aws_security_group" "app_sg" {

  name   = "app-sg"
  vpc_id = aws_vpc.x3_tier_vpc.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# DB SG
resource "aws_security_group" "db_sg" {

  name   = "db-sg"
  vpc_id = aws_vpc.x3_tier_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
}

# Network ACLs

# Public Nacl

resource "aws_network_acl" "public_nacl" {

  vpc_id = aws_vpc.x3_tier_vpc.id

  subnet_ids = [
    aws_subnet.public_subnet.id
  ]

  tags = {
    Name = "public-nacl"
  }
}

resource "aws_network_acl_rule" "allow_http" {

  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false

  cidr_block = "0.0.0.0/0"

  from_port = 80
  to_port   = 80
}

# Private Nacl

resource "aws_network_acl" "private_nacl" {

  vpc_id = aws_vpc.x3_tier_vpc.id

  subnet_ids = [
    aws_subnet.private_app_subnet.id,
    aws_subnet.private_db_subnet.id
  ]

  tags = {
    Name = "private-nacl"
  }
}

# EC2 Instances

# Web Instance

resource "aws_instance" "web" {

  ami           = "ami-087c9ba923d9765d8"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  key_name = ""

  tags = {
    Name = "web-tier"
  }
}

# App Instance

resource "aws_instance" "app" {

  ami           = "ami-087c9ba923d9765d8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_app_subnet.id

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  key_name = ""

  tags = {
    Name = "app-tier"
  }
}

# DB Instance

resource "aws_instance" "db" {

  ami           = "ami-087c9ba923d9765d8"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_db_subnet.id

  vpc_security_group_ids = [
    aws_security_group.db_sg.id
  ]

  key_name = ""

  tags = {
    Name = "db-tier"
  }
}