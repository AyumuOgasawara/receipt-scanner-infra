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
  vpc_id            = aws_vpc.receipt_scanner_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_a

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

# SubnetとRoute tableの関連付け
resource "aws_route_table_association" "receipt_scanner_rt_associate" {
  subnet_id      = aws_subnet.receipt_scanner_sn.id
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
resource "aws_security_group" "receipt_scanner_ec2_sg" {
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
    cidr_blocks = [local.allowed_cidr]
  }

  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
