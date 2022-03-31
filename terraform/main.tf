# S3 Resources
## S3 Bucket
resource "aws_s3_bucket" "ssh_rotate" {

  bucket        = "rotate-${lower(var.tags["environment"])}"
  force_destroy = true

  tags = merge(var.tags)
}

## S3 Bucket Block Public Access
resource "aws_s3_bucket_public_access_block" "bucket_versioning" {
  bucket                  = aws_s3_bucket.ssh_rotate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.ssh_rotate.id
  versioning_configuration {
    status = "Suspended"
  }
}

## S3 Bucket ACL
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.ssh_rotate.id
  acl    = "private"
}

## S3 Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.ssh_rotate.id
  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Cloudwatch Logs for AWS SSM Run Command output
module "loggroup_ssh_rotate" {
  source = "terraform-aws-modules/cloudwatch/aws//modules/log-group"

  name              = "/aws/ssm/ssh-rotate-${lower(var.tags["environment"])}"
  retention_in_days = var.loggroup_ssh_rotate_retention

  tags = merge(var.tags)
}

# EventBridge (Rule)
resource "aws_cloudwatch_event_rule" "event_rule_ssh_rotate" {
  name        = "ssh-rotate-${lower(var.tags["environment"])}"
  description = "Trigger to launch ssh-rotate-${lower(var.tags["environment"])} Lambda"

  event_pattern = file("${path.module}/policies/event_pattern.json")

  tags = merge(var.tags)
}

# EventBridge (Target)
resource "aws_cloudwatch_event_target" "event_target_ssh_rotate" {
  rule      = aws_cloudwatch_event_rule.event_rule_ssh_rotate.name
  target_id = "SendToSQS"
  input     = file("${path.module}/policies/event_input.json")
  arn       = aws_sqs_queue.sqs_ssh_rotate.arn
}

# Lambda
module "lambda_ssh_rotate" {
  source = "terraform-aws-modules/lambda/aws"

  function_name                     = "ssh-rotate-${lower(var.tags["environment"])}"
  description                       = "Lambda to rotate the SSH keys of the tag instances"
  handler                           = var.lambda_handler
  runtime                           = var.lambda_runtime
  publish                           = true
  timeout                           = var.lambda_timeout
  cloudwatch_logs_retention_in_days = 365
  create_role                       = false
  lambda_role                       = aws_iam_role.lambda_role_ssh_rotate.arn

  source_path = "../src/main.py"

  store_on_s3 = false

  layers = [
    aws_lambda_layer_version.ssh_rotate.arn,
  ]

  allowed_triggers = {
    EventBridge = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.sqs_ssh_rotate.arn
    }
  }

  environment_variables = {
    AWS_S3_BUCKET      = aws_s3_bucket.ssh_rotate.id
    AWS_LOG_GROUP_NAME = module.loggroup_ssh_rotate.cloudwatch_log_group_name
    AWS_S3_PREFIX      = var.lambda_s3_prefix
    PRIVATE_KEY_NAME   = var.lambda_private_key_name
    PUBLIC_KEY_NAME    = var.lambda_public_key_name
    TAG_KEY            = var.lambda_tag_key
  }

  tags = merge(var.tags)
}

# Lambda Layer
resource "aws_lambda_layer_version" "ssh_rotate" {
  layer_name  = "ssh-rotate-crypto"
  description = "crypto library (deployed from S3)"

  compatible_architectures = ["x86_64"]
  compatible_runtimes      = var.lambda_layer_runtime
  skip_destroy             = false

  s3_bucket = aws_s3_bucket.ssh_rotate.id
  s3_key    = "dependencies/${var.lambda_layer_package}.zip"

  depends_on = [
    aws_s3_bucket.ssh_rotate
  ]
}

# IAM Role Policy
resource "aws_iam_role_policy" "lambda_policy_ssh_rotate" {
  name = "LAMBDA_SSH_ROTATE_POLICY_${upper(var.tags["environment"])}"
  role = aws_iam_role.lambda_role_ssh_rotate.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*"
        "Resource" : aws_s3_bucket.ssh_rotate.arn
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:*"
        "Resource" : "${aws_s3_bucket.ssh_rotate.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "logs:*",
        "Resource" : "arn:aws:logs:*:*:log-group:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:ReceiveMessage",
        ]
        "Resource" : [
          aws_sqs_queue.sqs_ssh_rotate.arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:SendCommand",
          "ssm:ListCommands",
        ]
        "Resource" : "*"
      },
    ]
  })
}

# IAM Role
resource "aws_iam_role" "lambda_role_ssh_rotate" {
  name                 = "LAMBDA_SSH_ROTATE_${upper(var.tags["environment"])}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags)
}

# SQS
resource "aws_sqs_queue" "sqs_ssh_rotate" {
  name                       = "ssh-rotate-${lower(var.tags["environment"])}"
  delay_seconds              = var.sqs_delay_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds

  policy = file("${path.module}/policies/sqs_policy.json")

  sqs_managed_sse_enabled = true

  tags = merge(var.tags)
}
