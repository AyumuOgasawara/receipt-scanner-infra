# ---------------------------
# 変数設定
# ---------------------------
variable "az_a" {
  default = "ap-northeast-1a"
}

variable "num_subnets" {
  type    = number
  default = "2"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "key_file_path" {
  type = string
}

variable "rds_db_name" {
  type = string
}

variable "rds_user_name" {
  type = string
}

variable "rds_password" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}
