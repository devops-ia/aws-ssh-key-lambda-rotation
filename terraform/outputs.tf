# Outputs
## AWS Cloudwatch
output "cw_log_group" {
  description = "AWS Cloudwatch Log Group name"
  value = [
    module.log_group_from_ssm.cloudwatch_log_group_name,
    module.lambda_function.lambda_cloudwatch_log_group_name
  ]
}

## AWS EC2
output "ec2_instance_id" {
  description = "AWS EC2 Instances ID"
  value       = module.ec2_sample_rotate.*.id
}

output "ec2_instance_key_pair" {
  description = "AWS EC2 Key Pair ID"
  value       = aws_key_pair.testing.*.id
}

## AWS EventBridge
output "eventbridge_rules" {
  description = "AWS EventBridge Rules"
  value = [
    aws_cloudwatch_event_rule.event_rule_deploy_function.name,
    aws_cloudwatch_event_rule.event_rule_rotate_function.name,
  ]
}

## AWS IAM
output "iam_policies" {
  description = "AWS IAM Policies"
  value = [
    aws_iam_role_policy.lambda_policy_ssh_rotate.name,
    aws_iam_role_policy.sns_policy_ssh_rotate.name,
    aws_iam_role_policy.instances_policy.*.name
  ]
}

output "iam_roles" {
  description = "AWS IAM Roles"
  value = [
    aws_iam_role.lambda_role_ssh_rotate.name,
    aws_iam_role.sns_role_ssh_rotate.name,
    aws_iam_role.instances.*.name
  ]
}

output "iam_instance_profile" {
  description = "AWS IAM Instance Profile"
  value       = aws_iam_instance_profile.instances_profile.*.name
}

## AWS Lambda
output "lambda_function_name" {
  description = "AWS Lambda function name"
  value       = module.lambda_function.lambda_function_name
}

## AWS S3
output "s3_bucket_name" {
  description = "AWS S3 name"
  value       = aws_s3_bucket.ssh_rotate.id
}

## AWS SG
output "sg_ids" {
  description = "AWS EC2 Security Group IDs"
  value       = module.sg_sample_rotate.*.security_group_id
}

## AWS SNS
output "sns_names" {
  description = "AWS SQS name"
  value = [
    module.sns_ssm_run_command.sns_topic_name,
    module.sns_lambda_failed.sns_topic_name,
    module.sns_rotate_function_success.sns_topic_name
  ]
}

## AWS SQS
output "sqs_names" {
  description = "AWS SQS name"
  value = [
    aws_sqs_queue.sqs_deploy_function.name,
    aws_sqs_queue.sqs_rotate_function.name
  ]
}

## AWS VPC
output "vpc_id" {
  description = "AWS VPC ID"
  value       = module.vpc.*.vpc_id
}
