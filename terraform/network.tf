# =========================
# VPC
# =========================
resource "aws_vpc" "x3_tier_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "x3-tier-vpc"
  }
}

# =========================
# SUBNETS
# =========================
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.x3_tier_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "web-public-subnet"
  }
}

resource "aws_subnet" "private_app_subnet" {
  vpc_id            = aws_vpc.x3_tier_vpc.id
  cidr_block        = var.private_app_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "app-private-subnet"
  }
}

resource "aws_subnet" "private_db_subnet" {
  vpc_id            = aws_vpc.x3_tier_vpc.id
  cidr_block        = var.private_db_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "db-private-subnet"
  }
}

# =========================
# INTERNET GATEWAY
# =========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.x3_tier_vpc.id

  tags = {
    Name = "x3-tier-igw"
  }
}

# =========================
# ROUTE TABLES
# =========================
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

# Private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.x3_tier_vpc.id
}

resource "aws_route_table_association" "app_assoc" {
  subnet_id      = aws_subnet.private_app_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "db_assoc" {
  subnet_id      = aws_subnet.private_db_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# =========================
# SECURITY GROUPS
# =========================
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

resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.x3_tier_vpc.id

  ingress {
    from_port       = 5000
    to_port         = 5000
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

resource "aws_security_group" "db_sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.x3_tier_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# =========================
# NETWORK ACLs
# =========================

# Public NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.x3_tier_vpc.id

  subnet_ids = [
    aws_subnet.public_subnet.id
  ]

  tags = {
    Name = "public-nacl"
  }
}

# Inbound rules
resource "aws_network_acl_rule" "allow_http" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "allow_ssh" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "allow_ephemeral_in" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Outbound rule
resource "aws_network_acl_rule" "allow_all_out" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
}

# Private NACL
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