# AWS SQS
## Deploy function
resource "aws_sqs_queue" "sqs_deploy_function" {

  name                       = local.deploy_name
  delay_seconds              = var.sqs_config.deploy.delay_seconds
  visibility_timeout_seconds = var.sqs_config.deploy.visibility_timeout_seconds
  sqs_managed_sse_enabled    = var.sqs_config.deploy.managed_sse_enabled

  policy = data.template_file.sqs_policy_deploy.rendered

  tags = merge(var.tags)
}

## Rotate function
resource "aws_sqs_queue" "sqs_rotate_function" {

  name                       = local.rotate_name
  delay_seconds              = var.sqs_config.rotate.delay_seconds
  visibility_timeout_seconds = var.sqs_config.rotate.visibility_timeout_seconds
  sqs_managed_sse_enabled    = var.sqs_config.rotate.managed_sse_enabled

  policy = data.template_file.sqs_policy_rotate.rendered

  tags = merge(var.tags)
}