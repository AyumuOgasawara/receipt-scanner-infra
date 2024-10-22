# 作成したEC2のパブリックIPアドレスを出力
output "ec2_global_ips" {
  value = aws_instance.receipt_scanner_ec2.*.public_ip
}
