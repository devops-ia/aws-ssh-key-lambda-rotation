# AWS SNS
## AWS Run Command Failed
module "sns_ssm_run_command" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name         = "${lower(local.global_name)}-ssm-run-command-failed"
  display_name = "[${upper(var.tags["environment"])}] ${var.sns_config.sns_ssm_run_command.display_name}"

  tags = merge(var.tags)
}

## AWS SSM Run Command Subscriptions
resource "aws_sns_topic_subscription" "sns_ssm_run_command" {
  for_each = var.sns_config.sns_ssm_run_command.subscriptions

  topic_arn                       = module.sns_ssm_run_command.sns_topic_arn
  confirmation_timeout_in_minutes = each.value["confirmation_timeout_in_minutes"]
  endpoint_auto_confirms          = each.value["endpoint_auto_confirms"]
  protocol                        = each.value["protocol"]
  endpoint                        = each.key
}

## AWS Lambda Failed
module "sns_lambda_failed" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name         = "${lower(local.global_name)}-lambda-failed"
  display_name = "[${upper(var.tags["environment"])}] ${var.sns_config.sns_lambda_failed.display_name}"

  tags = merge(var.tags)
}

## AWS Lambda Failed Subscriptions
resource "aws_sns_topic_subscription" "lambda" {
  for_each = var.sns_config.sns_lambda_failed.subscriptions

  topic_arn                       = module.sns_lambda_failed.sns_topic_arn
  confirmation_timeout_in_minutes = each.value["confirmation_timeout_in_minutes"]
  endpoint_auto_confirms          = each.value["endpoint_auto_confirms"]
  protocol                        = each.value["protocol"]
  endpoint                        = each.key
}

## When Rotate Function Success
module "sns_rotate_function_success" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name         = "${lower(local.global_name)}-rotate-function-success"
  display_name = "[${upper(var.tags["environment"])}] ${var.sns_config.sns_rotate_function_success.display_name}"

  tags = merge(var.tags)
}

## When Rotate Function Success Subscriptions
resource "aws_sns_topic_subscription" "rotate" {
  for_each = var.sns_config.sns_rotate_function_success.subscriptions

  topic_arn                       = module.sns_rotate_function_success.sns_topic_arn
  confirmation_timeout_in_minutes = each.value["confirmation_timeout_in_minutes"]
  endpoint_auto_confirms          = each.value["endpoint_auto_confirms"]
  protocol                        = each.value["protocol"]
  endpoint                        = each.key
}