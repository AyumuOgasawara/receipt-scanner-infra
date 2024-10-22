# ---------------------------
# EC2 Key pair
# ---------------------------
variable "key_name" {
  default = "receipt-scanner-keypair"
}

# 秘密鍵のアルゴリズム設定
resource "tls_private_key" "receipt_scanner_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# クライアントPCにKey pair（秘密鍵と公開鍵）を作成
# - Windowsの場合はフォルダを"\\"で区切る（エスケープする必要がある）
# - [terraform apply] 実行後はクライアントPCの公開鍵は自動削除される
locals {
  public_key_file  = "/Users/ayumu/.ssh/aws/${var.key_name}.id_rsa.pub"
  private_key_file = "/Users/ayumu/.ssh/aws/${var.key_name}.id_rsa"
}

resource "local_file" "receipt_scanner_private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.receipt_scanner_private_key.private_key_pem
}

# 上記で作成した公開鍵をAWSのKey pairにインポート
resource "aws_key_pair" "receipt_scanner_keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.receipt_scanner_private_key.public_key_openssh
}

# ---------------------------
# EC2
# ---------------------------
# ubuntu-jammy-22.04-amd64-server
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# EC2作成
resource "aws_instance" "receipt_scanner_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.receipt_scanner_sg.id]
  subnet_id                   = aws_subnet.receipt_scanner_sn[0].id
  associate_public_ip_address = "true"
  key_name                    = var.key_name
  tags = {
    Name = "receipt-scanner"
  }
}
