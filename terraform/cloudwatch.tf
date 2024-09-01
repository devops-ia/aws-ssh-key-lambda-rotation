# AWS Cloudwatch
## Cloudwatch Logs for AWS SSM Run Command output
module "log_group_from_ssm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "5.5.0"

  name              = "/aws/ssm/${lower(local.global_name)}"
  retention_in_days = var.log_group_from_ssm_retention

  tags = merge(var.tags)
}

## Cloudwatch Pattern Filter to AWS CW Log Group
resource "aws_cloudwatch_log_metric_filter" "lambda_error_filter" {
  name           = "LambdaRotateError-${lower(var.tags["environment"])}"
  pattern        = "ERROR"
  log_group_name = module.lambda_function.lambda_cloudwatch_log_group_name

  metric_transformation {
    name      = "lambdaRotateError-${lower(var.tags["environment"])}"
    namespace = "LogMetrics-${lower(var.tags["environment"])}"
    value     = "1"
  }

  depends_on = [
    module.sns_lambda_failed
  ]
}

## Cloudwatch Alarm when Pattern Filter match
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name                = "${var.cw_metric_alarm.default.complementary_alarm_name}-${lower(local.global_name)}"
  comparison_operator       = var.cw_metric_alarm.default.comparison_operator
  evaluation_periods        = var.cw_metric_alarm.default.evaluation_periods
  metric_name               = "${var.cw_metric_alarm.default.complementary_alarm_name}-${lower(local.global_name)}"
  namespace                 = "${var.cw_metric_alarm.default.complementary_namespace_name}-${lower(local.global_name)}"
  period                    = var.cw_metric_alarm.default.period
  statistic                 = var.cw_metric_alarm.default.statistic
  threshold                 = var.cw_metric_alarm.default.threshold
  alarm_description         = "[${upper(local.global_name)}] ${var.cw_metric_alarm.default.complementary_alarm_description}"
  insufficient_data_actions = var.cw_metric_alarm.default.insufficient_data_actions
  datapoints_to_alarm       = var.cw_metric_alarm.default.datapoints_to_alarm
  treat_missing_data        = var.cw_metric_alarm.default.treat_missing_data

  alarm_actions = [module.sns_lambda_failed.sns_topic_arn]

  tags = merge(var.tags)
}