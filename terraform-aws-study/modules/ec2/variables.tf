variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "project_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ec2_sg_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "app_repo_url" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "cw_agent_config_name" {
  description = "SSM parameter name for CloudWatch Agent config"
  type        = string
  default     = "AmazonCloudWatch-linux-config"
}
variable "ansible_repo_url" {
  type    = string
  default = "https://github.com/kenichi-oss/RaiseTech.git"
}

variable "ansible_repo_branch" {
  type    = string
  default = "feature/ansible" # main にマージする前に "main" へ戻す
}

variable "run_db_init" {
  description = "Run create.sql from this instance (only one instance should do this)"
  type        = bool
  default     = true
}
