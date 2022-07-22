# AWS EventBridge
## Rule - Deploy Function
resource "aws_cloudwatch_event_rule" "event_rule_deploy_function" {
  name        = local.deploy_name
  description = "Event trigger to AWS SQS ${local.deploy_name}"

  is_enabled    = var.event_rule_deploy_function.default.enabled
  event_pattern = data.template_file.event_pattern.rendered

  tags = merge(var.tags)
}

## Target - Deploy Function
resource "aws_cloudwatch_event_target" "event_target_deploy_function" {
  rule      = aws_cloudwatch_event_rule.event_rule_deploy_function.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.sqs_deploy_function.arn
}

## Rule - Deploy Rotate
resource "aws_cloudwatch_event_rule" "event_rule_rotate_function" {
  name        = local.rotate_name
  description = "Event trigger to AWS SQS ${local.rotate_name}"

  is_enabled          = var.event_rule_rotate_function.default.enabled
  schedule_expression = var.event_rule_rotate_function.default.expression

  tags = merge(var.tags)
}

## Target - Deploy Rotate
resource "aws_cloudwatch_event_target" "event_target_rotate_function" {
  rule      = aws_cloudwatch_event_rule.event_rule_rotate_function.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.sqs_rotate_function.arn
}