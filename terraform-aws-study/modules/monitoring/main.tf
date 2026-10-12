data "aws_region" "current" {}

# --- SNS(通知の送り先) ---
resource "aws_sns_topic" "main" {
  name = "${var.project_name}-alarm-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# --- EC2 の CPU アラーム ---
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "CPUAlarm"
  alarm_description   = "CPU alarm for my instance"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  unit                = "Percent"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = var.instance_id
  }

  alarm_actions = [aws_sns_topic.main.arn]
}

# --- WAF のブロック件数アラーム ---
resource "aws_cloudwatch_metric_alarm" "waf_blocked" {
  alarm_name          = "WAFBlockRequestsAlarm"
  alarm_description   = "WAF Blocked Requests Alarm"
  namespace           = "AWS/WAFV2"
  metric_name         = "BlockedRequests"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    WebACL = var.web_acl_name
    Rule   = "ALL" # Web ACL 全体の合計(全ルールの合計は大文字の ALL)
    Region = data.aws_region.current.region
  }

  alarm_actions = [aws_sns_topic.main.arn]
}

# --- アプリログの ERROR をメトリクス化 ---
resource "aws_cloudwatch_log_metric_filter" "app_error" {
  name           = "${var.project_name}-app-error"
  log_group_name = var.app_log_group_name
  pattern        = "\"ERROR\""

  metric_transformation {
    name          = "AppErrors"
    namespace     = "${var.project_name}-app"
    value         = "1"
    default_value = "0"
  }
}

# --- ERROR 検知のアラーム ---
resource "aws_cloudwatch_metric_alarm" "app_error" {
  alarm_name          = "${var.project_name}-app-errors"
  alarm_description   = "アプリケーションログにERRORが出た場合に通知"
  namespace           = "${var.project_name}-app"
  metric_name         = "AppErrors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.main.arn]
}