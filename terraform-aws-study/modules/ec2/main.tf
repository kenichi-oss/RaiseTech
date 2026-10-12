# 最新の Amazon Linux 2023 の AMI を取得
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# --- CloudWatch Logs のロググループ ---
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.project_name}/app"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "user_data" {
  name              = "/${var.project_name}/user-data"
  retention_in_days = 1
}

# --- CloudWatch Agent の設定(SSM パラメータ) ---
resource "aws_ssm_parameter" "cw_agent" {
  name = "AmazonCloudWatch-linux-config"
  type = "String"

  # jsonencode を使うと、JSON の文法を Terraform が正しく作ってくれる
  value = jsonencode({
    metrics = {
      metrics_collected = {
        mem  = { measurement = ["mem_used_percent"] }
        disk = { measurement = ["used_percent"], resources = ["/"] }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/user-data.log"
              log_group_name  = aws_cloudwatch_log_group.user_data.name
              log_stream_name = "{instance_id}"
            },
            {
              file_path       = "/home/ec2-user/aws-study/app.log"
              log_group_name  = aws_cloudwatch_log_group.app.name
              log_stream_name = "{instance_id}"
            }
          ]
        }
      }
    }
  })
}

# --- EC2 本体 ---
resource "aws_instance" "main" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.ec2_sg_id]
  iam_instance_profile   = var.instance_profile_name
  monitoring             = false

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    cw_agent_config_name = aws_ssm_parameter.cw_agent.name
    app_repo_url         = var.app_repo_url
    db_endpoint          = var.db_endpoint
    db_name              = var.db_name
    db_username          = var.db_username
    db_password          = var.db_password
  })

  tags = {
    Name = "${var.project_name}-ec2"
  }
}