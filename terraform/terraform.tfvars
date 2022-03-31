# Lambda
lambda_handler          = "main.main"
lambda_runtime          = "python3.8"
lambda_timeout          = 120
lambda_s3_prefix        = "current"
lambda_private_key_name = "key.pem"
lambda_public_key_name  = "key.pub"
lambda_tag_key          = "provisioning"
lambda_function         = "DEPLOY"

# Lambda Layer
lambda_layer_package = "libs"
lambda_layer_runtime = ["python3.8", "python3.9"]

# System Manager Run Command
loggroup_ssh_rotate_retention = 365

# SQS
sqs_delay_seconds              = 60
sqs_visibility_timeout_seconds = 180

# TAGS
tags = {
  "environment" = "Dev",
  "service"     = "ssm-rotate"
}