# AWS Lambda
## Function
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.14.0"

  function_name                     = lower(local.global_name)
  description                       = var.lambda_function.default.lambda_description
  handler                           = var.lambda_function.default.lambda_handler
  runtime                           = var.lambda_function.default.lambda_runtime
  publish                           = var.lambda_function.default.lambda_publish
  timeout                           = var.lambda_function.default.lambda_timeout
  cloudwatch_logs_retention_in_days = var.lambda_function.default.lambda_cw_log_retention
  create_role                       = false
  lambda_role                       = aws_iam_role.lambda_role_ssh_rotate.arn

  source_path = [
    "src/main.py"
  ]

  store_on_s3 = false

  layers = [
    aws_lambda_layer_version.lambda_layers.arn,
  ]

  allowed_triggers = {

    SQSDeploy = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.sqs_deploy_function.arn
    }
    SQSRotate = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.sqs_rotate_function.arn
    }
  }

  environment_variables = {
    ARN_SQS_ROTATE              = aws_sqs_queue.sqs_rotate_function.arn
    ARN_SQS_DEPLOY              = aws_sqs_queue.sqs_deploy_function.arn
    AWS_LOG_GROUP_NAME          = module.log_group_from_ssm.cloudwatch_log_group_name
    AWS_S3_BUCKET               = aws_s3_bucket.ssh_rotate.id
    AWS_S3_PREFIX               = var.lambda_function.default.lambda_s3_prefix
    SCRIPT_LOOP                 = var.lambda_function.default.lambda_script_loop
    SCRIPT_SLEEP                = var.lambda_function.default.lambda_script_sleep
    SNS_ROTATE_NOTIFICATION_ARN = module.sns_rotate_function_success.sns_topic_arn
    SNS_NOTIFICATION_ARN        = module.sns_ssm_run_command.sns_topic_arn
    SNS_ROLE_ARN                = aws_iam_role.sns_role_ssh_rotate.arn
    TAG_VALUE_ENVIRONMENT       = var.tags["environment"]
    TAG_VALUE_ROTATE            = var.tags_rotate["rotate"]
  }

  tags = merge(var.tags)
}

## Layer
resource "aws_lambda_layer_version" "lambda_layers" {
  layer_name  = "${lower(local.global_name)}-layer"
  description = "Libraries (deployed on AWS S3)"

  compatible_architectures = ["x86_64"]
  compatible_runtimes      = var.lambda_layer.default.compatible_runtimes
  skip_destroy             = false

  s3_bucket = aws_s3_bucket.ssh_rotate.id
  s3_key    = aws_s3_object.libs.id

  depends_on = [
    aws_s3_bucket.ssh_rotate
  ]
}
