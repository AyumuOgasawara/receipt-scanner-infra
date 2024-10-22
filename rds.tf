#
# RDS
#
resource "aws_db_instance" "rds" {
  db_name                             = var.rds_db_name
  engine                              = "postgres"
  engine_version                      = "16.3"
  instance_class                      = "db.t3.micro"
  storage_type                        = "gp2"
  port                                = 5432
  username                            = var.rds_user_name
  password                            = var.rds_password
  parameter_group_name                = aws_db_parameter_group.rds-pg.name
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = true
  multi_az                            = false
  publicly_accessible                 = false
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.rds_storage.arn
  vpc_security_group_ids = [
    aws_security_group.rds-sg.id
  ]
  db_subnet_group_name = aws_db_subnet_group.rds-sng.name

  # 割り当てストレージサイズ(GB)
  allocated_storage = 10
  # メジャーバージョンの更新許可
  allow_major_version_upgrade = false
  # マイナーバージョンの自動更新
  auto_minor_version_upgrade = true
}

resource "aws_db_parameter_group" "rds-pg" {
  name   = "rds-pg"
  family = "postgres16"
}

resource "aws_db_subnet_group" "rds-sng" {
  name = "db"
  subnet_ids = [
    for value in aws_subnet.receipt_scanner_sn : value.id
  ]
}

resource "aws_kms_key" "rds_storage" {
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_security_group" "rds-sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.receipt_scanner_vpc.id

  tags = {
    Name = "rds"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds-ingress-sgr" {
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.rds-sg.id
  cidr_ipv4         = "10.0.0.0/16"
}

resource "aws_vpc_security_group_egress_rule" "rds-egress-sgr" {
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.rds-sg.id
}
