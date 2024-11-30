data "aws_availability_zones" "available" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}


# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "receipt_scanner_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true # DNSホスト名を有効化
  tags = {
    Name = "receipt-scanner"
  }
}

# ---------------------------
# Subnet
# ---------------------------
resource "aws_subnet" "receipt_scanner_sn" {
  count             = var.num_subnets
  vpc_id            = aws_vpc.receipt_scanner_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index % var.num_subnets)

  tags = {
    Name = "receipt-scanner"
  }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "receipt_scanner_igw" {
  vpc_id = aws_vpc.receipt_scanner_vpc.id
  tags = {
    Name = "receipt-scanner"
  }
}

# ---------------------------
# Route table
# ---------------------------
# Route table作成
resource "aws_route_table" "receipt_scanner_rt" {
  vpc_id = aws_vpc.receipt_scanner_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.receipt_scanner_igw.id
  }
  tags = {
    Name = "receipt-scanner"
  }
}

resource "aws_route_table_association" "receipt_scanner_rta" {
  count          = var.num_subnets
  subnet_id      = element(aws_subnet.receipt_scanner_sn.*.id, count.index)
  route_table_id = aws_route_table.receipt_scanner_rt.id
}

# ---------------------------
# Security Group
# ---------------------------
# 自分のパブリックIP取得
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

variable "allowed_cidr" {
  default = null
}

locals {
  myip         = chomp(data.http.ifconfig.body)
  allowed_cidr = (var.allowed_cidr == null) ? "${local.myip}/32" : var.allowed_cidr
}

# Security Group作成
resource "aws_security_group" "receipt_scanner_sg" {
  name        = "receipt-scanner-ec2-sg"
  description = "For EC2 Linux"
  vpc_id      = aws_vpc.receipt_scanner_vpc.id
  tags = {
    Name = "receipt-scanner"
  }

  # インバウンドルール
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
