mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
    }
  }
}
# 必須の変数に、値を渡す(CI には terraform.tfvars が無いため)
variables {
  region               = "ap-northeast-1"
  env                  = "development"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  # instance_type は書かない(variables.tf の default を、テストの対象にするため)

  # 設計書の対象外だが、必須の変数(ダミー値。本物の値は入れない)
  db_password        = "dummy-password-1234"
  notification_email = "test@example.com"
}

# ここから下の run ブロックは、今のまま

run "valid_string_concat_ec2_instance_type" {
  command = plan

  assert {
    condition     = output.ec2_instance_type == "t3.micro"
    error_message = "EC2 instance type does not match the expected value."
  }
}
run "valid_string_concat_rds_storage_type" {
  command = plan
  assert {
    condition     = output.storage_type == "gp3"
    error_message = "RDS storage type does not match the expected value."
  }
}
run "valid_string_concat_rds_engine" {
  command = plan
  assert {
    condition     = output.engine == "mysql"
    error_message = "RDS engine does not match the expected value."
  }
}

