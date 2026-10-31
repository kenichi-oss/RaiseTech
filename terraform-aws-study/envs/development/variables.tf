variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}
# IAM
variable "project_name" {
  type    = string
  default = "my-app"
}
# RDS
variable "db_name" {
  type    = string
  default = "kenichidb"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true # plan / apply の表示でも隠れる
}

#variable "instance_class" {
#  type    = string
#  default = "db.t3.micro"
#}

#variable "allocated_storage" {
#  type    = number
#  default = 20
#}
# EC2
variable "key_name" {
  type    = string
  default = "kenkey0915"
}

variable "app_repo_url" {
  type    = string
  default = "https://github.com/koujienami/aws-study.git"
}

variable "notification_email" {
  type = string
}

variable "name" {
  description = "Name tag override (optional)"
  type        = string
  default     = null
}