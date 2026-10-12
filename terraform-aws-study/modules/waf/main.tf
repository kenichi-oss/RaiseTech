data "aws_caller_identity" "current" {}

# --- Web ACL ---
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project_name}-waf"
  scope       = "REGIONAL" # ALB に紐付けるので REGIONAL
  description = "only AWSManagedRulesCommonRuleSet"

  # ルールに一致しない通常のリクエストは許可
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "${var.project_name}-waf-metric"
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 0

    # none {} = マネージドルールの判定(Block/Allow)をそのまま適用
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.project_name}-waf-rule-metric"
    }
  }
}

# --- ALB に WAF を関連付け ---
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# --- WAF ログの出力先 ---
resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.project_name}" # 必ず aws-waf-logs- で始める
  retention_in_days = 7
}

locals {
  # ARN の末尾の ":*" の有無がプロバイダのバージョンで違うため、いったん外してそろえる
  waf_log_group_arn = trimsuffix(aws_cloudwatch_log_group.waf.arn, ":*")
}

# WAF(delivery.logs.amazonaws.com)がロググループに書き込めるようにする
resource "aws_cloudwatch_log_resource_policy" "waf" {
  policy_name = "${var.project_name}-waf-logs-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource  = "${local.waf_log_group_arn}:*"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

# Web ACL とロググループを紐付ける(これがないとログは出ない)
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  resource_arn            = aws_wafv2_web_acl.main.arn
  log_destination_configs = [local.waf_log_group_arn] # 末尾に :* を付けない

  depends_on = [aws_cloudwatch_log_resource_policy.waf]
}