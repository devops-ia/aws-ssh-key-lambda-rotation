## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.9.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_sample_rotate"></a> [ec2\_sample\_rotate](#module\_ec2\_sample\_rotate) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_log_group_from_ssm"></a> [log\_group\_from\_ssm](#module\_log\_group\_from\_ssm) | terraform-aws-modules/cloudwatch/aws//modules/log-group | 3.2.0 |
| <a name="module_sg_sample_rotate"></a> [sg\_sample\_rotate](#module\_sg\_sample\_rotate) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_sns_lambda_failed"></a> [sns\_lambda\_failed](#module\_sns\_lambda\_failed) | terraform-aws-modules/sns/aws | ~> 3.0 |
| <a name="module_sns_rotate_function_success"></a> [sns\_rotate\_function\_success](#module\_sns\_rotate\_function\_success) | terraform-aws-modules/sns/aws | ~> 3.0 |
| <a name="module_sns_ssm_run_command"></a> [sns\_ssm\_run\_command](#module\_sns\_ssm\_run\_command) | terraform-aws-modules/sns/aws | ~> 3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.event_rule_deploy_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.event_rule_rotate_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.event_target_deploy_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event_target_rotate_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_metric_filter.lambda_error_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.lambda_error_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.instances_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_role_ssh_rotate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sns_role_ssh_rotate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.instances_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_policy_ssh_rotate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sns_policy_ssh_rotate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_key_pair.testing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_lambda_layer_version.lambda_layers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_s3_bucket.ssh_rotate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_public_access_block.bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.libs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_sns_topic_subscription.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.rotate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.sns_ssm_run_command](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.sqs_deploy_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.sqs_rotate_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [null_resource.build_lambda_layers](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.testing](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [template_file.event_pattern](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.sqs_policy_deploy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.sqs_policy_rotate](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cw_metric_alarm"></a> [cw\_metric\_alarm](#input\_cw\_metric\_alarm) | AWS Cloudwatch Metric Alarm | <pre>map(object({<br>    complementary_alarm_name        = string<br>    comparison_operator             = string<br>    evaluation_periods              = number<br>    complementary_namespace_name    = string<br>    period                          = number<br>    statistic                       = string<br>    threshold                       = number<br>    complementary_alarm_description = string<br>    insufficient_data_actions       = list(string)<br>    datapoints_to_alarm             = number<br>    treat_missing_data              = string<br>  }))</pre> | `{}` | no |
| <a name="input_event_rule_deploy_function"></a> [event\_rule\_deploy\_function](#input\_event\_rule\_deploy\_function) | AWS EventBridge Deploy Function | <pre>map(object({<br>    enabled = bool<br>  }))</pre> | `{}` | no |
| <a name="input_event_rule_rotate_function"></a> [event\_rule\_rotate\_function](#input\_event\_rule\_rotate\_function) | AWS EventBridge Rotate Function | <pre>map(object({<br>    enabled    = bool<br>    expression = string<br>  }))</pre> | `{}` | no |
| <a name="input_lambda_function"></a> [lambda\_function](#input\_lambda\_function) | AWS Lambda Function values | <pre>map(object({<br>    lambda_handler          = string<br>    lambda_description      = string<br>    lambda_runtime          = string<br>    lambda_publish          = bool<br>    lambda_timeout          = number<br>    lambda_cw_log_retention = number<br>    lambda_s3_prefix        = string<br>    lambda_admin_user       = string<br>    lambda_script_loop      = number<br>    lambda_script_sleep     = number<br>  }))</pre> | `{}` | no |
| <a name="input_lambda_layer"></a> [lambda\_layer](#input\_lambda\_layer) | AWS Lambda layer | <pre>map(object({<br>    compatible_runtimes = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_log_group_from_ssm_retention"></a> [log\_group\_from\_ssm\_retention](#input\_log\_group\_from\_ssm\_retention) | AWS Cloudwatch Logs Retention for SSM Run Command | `number` | `30` | no |
| <a name="input_my_ip"></a> [my\_ip](#input\_my\_ip) | My IP | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region | `string` | `null` | no |
| <a name="input_sns_config"></a> [sns\_config](#input\_sns\_config) | AWS SNS Configuration | `any` | `{}` | no |
| <a name="input_sqs_config"></a> [sqs\_config](#input\_sqs\_config) | AWS SQS Configuration | <pre>map(object({<br>    delay_seconds              = number<br>    visibility_timeout_seconds = number<br>    managed_sse_enabled        = bool<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Service tags | `map(string)` | `null` | no |
| <a name="input_tags_rotate"></a> [tags\_rotate](#input\_tags\_rotate) | Service tags | `map(string)` | `null` | no |
| <a name="input_testing_enabled"></a> [testing\_enabled](#input\_testing\_enabled) | Create testing resources | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cw_log_group"></a> [cw\_log\_group](#output\_cw\_log\_group) | AWS Cloudwatch Log Group name |
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | AWS EC2 Instances ID |
| <a name="output_ec2_instance_key_pair"></a> [ec2\_instance\_key\_pair](#output\_ec2\_instance\_key\_pair) | AWS EC2 Key Pair ID |
| <a name="output_eventbridge_rules"></a> [eventbridge\_rules](#output\_eventbridge\_rules) | AWS EventBridge Rules |
| <a name="output_iam_instance_profile"></a> [iam\_instance\_profile](#output\_iam\_instance\_profile) | AWS IAM Instance Profile |
| <a name="output_iam_policies"></a> [iam\_policies](#output\_iam\_policies) | AWS IAM Policies |
| <a name="output_iam_roles"></a> [iam\_roles](#output\_iam\_roles) | AWS IAM Roles |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | AWS Lambda function name |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | AWS S3 name |
| <a name="output_sg_ids"></a> [sg\_ids](#output\_sg\_ids) | AWS EC2 Security Group IDs |
| <a name="output_sns_names"></a> [sns\_names](#output\_sns\_names) | AWS SQS name |
| <a name="output_sqs_names"></a> [sqs\_names](#output\_sqs\_names) | AWS SQS name |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | AWS VPC ID |