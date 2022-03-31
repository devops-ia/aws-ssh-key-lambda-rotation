# Outputs
## CloudwatchLogGroup
output "loggroup_ssh_rotate_name" {
  description = "AWS Cloudwatch Log Group name for System Manager Run Command ssh rotate"
  value       = module.loggroup_ssh_rotate.cloudwatch_log_group_name
}

## EventBridge
output "eventbridge_aws_cloudwatch_event_rule" {
  description = "Trigger to launch ssh-rotate Lambda"
  value       = aws_cloudwatch_event_rule.event_rule_ssh_rotate.name
}

output "eventbridge_aws_cloudwatch_event_target" {
  description = "Target to sent Events Trigger"
  value       = aws_cloudwatch_event_target.event_target_ssh_rotate.arn
}

## IAM
output "lambda_policy_ssh_rotate_name" {
  description = "AWS IAM Policy name for ssh rotate"
  value       = aws_iam_role_policy.lambda_policy_ssh_rotate.name
}

output "lambda_role_ssh_rotate_name" {
  description = "AWS IAM Role name for ssh rotate"
  value       = aws_iam_role.lambda_role_ssh_rotate.name
}

## Lambda
output "lambda_function_ssh_rotate_name" {
  description = "AWS Lambda function name for ssh rotate"
  value       = module.lambda_ssh_rotate.lambda_function_name
}

output "lambda_cw_lgroup_ssh_rotate_name" {
  description = "AWS Cloudwatch Log Group Name"
  value       = module.lambda_ssh_rotate.lambda_cloudwatch_log_group_name
}

## s3
output "s3_ssh_rotate_name" {
  description = "AWS S3 name"
  value       = aws_s3_bucket.ssh_rotate.id
}

## SQS
output "sqs_ssh_rotate_name" {
  description = "AWS SQS name"
  value       = aws_sqs_queue.sqs_ssh_rotate.name
}