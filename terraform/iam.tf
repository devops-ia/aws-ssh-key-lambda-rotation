# AWS IAM
## Lambda Policy
resource "aws_iam_role_policy" "lambda_policy_ssh_rotate" {
  name = "LAMBDA_POLICY_${upper(local.global_name)}"
  role = aws_iam_role.lambda_role_ssh_rotate.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:CopyObject",
          "s3:DeleteObject",
          "s3:DeleteObjects",
          "s3:Get*",
          "s3:Head*",
          "s3:List*",
          "S3:PutObject",
          "S3:UploadPart",
          "S3:UploadPartCopy"
        ],
        "Resource" : [
          "${aws_s3_bucket.ssh_rotate.arn}",
          "${aws_s3_bucket.ssh_rotate.arn}/*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutRetentionPolicy",
          "logs:CreateLogGroup",
          "logs:GetLogEvents",
          "logs:PutLogEvents"
        ],
        "Resource" : "${module.lambda_function.lambda_cloudwatch_log_group_arn}:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ],
        "Resource" : [
          aws_sqs_queue.sqs_deploy_function.arn,
          aws_sqs_queue.sqs_rotate_function.arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:SendCommand",
          "ssm:ListCommands",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish"
        ],
        "Resource" : [
          module.sns_ssm_run_command.sns_topic_arn,
          module.sns_rotate_function_success.sns_topic_arn
        ],
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : aws_iam_role.sns_role_ssh_rotate.arn
      }
    ]
  })
}

## Lambda Role
resource "aws_iam_role" "lambda_role_ssh_rotate" {
  name = "LAMBDA_ROLE_${upper(local.global_name)}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "lambda.amazonaws.com",
            "ssm.amazonaws.com"
          ]
        },
        "Action" : [
          "sts:AssumeRole"
        ]
      }
    ]
  })

  tags = merge(var.tags)
}

## SNS Policy
resource "aws_iam_role_policy" "sns_policy_ssh_rotate" {
  name = "SNS_POLICY_${upper(local.global_name)}"
  role = aws_iam_role.sns_role_ssh_rotate.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish"
        ],
        "Resource" : module.sns_ssm_run_command.sns_topic_arn
      }
    ]
  })
}

## SNS Role
resource "aws_iam_role" "sns_role_ssh_rotate" {
  name = "SNS_ROLE_${upper(local.global_name)}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ssm.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags)
}

# Testing Resources
## Instance Policy
resource "aws_iam_role_policy" "instances_policy" {
  count = var.testing_enabled ? 1 : 0
  name  = "INSTANCES_POLICY_${upper(local.global_name)}"
  role  = aws_iam_role.instances[0].id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dms:DescribeReplicationInstances",
          "dms:DescribeReplicationTasks",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:Describe*",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeAssociation",
          "ssm:DescribeDocument",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:PutInventory",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "tag:GetResources",
        ],
        "Resource" : "*"
      },
      {
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "${module.log_group_from_ssm.cloudwatch_log_group_arn}:*"
      }
    ]
  })
}

## Instance Role
resource "aws_iam_role" "instances" {
  count = var.testing_enabled ? 1 : 0
  name  = "INSTANCES_ROLE_${upper(local.global_name)}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  tags = var.tags
}

## Instance Profile
resource "aws_iam_instance_profile" "instances_profile" {
  count = var.testing_enabled ? 1 : 0
  name  = "INSTANCES_PROFILE_${upper(local.global_name)}"
  role  = aws_iam_role.instances[0].name

  tags = var.tags
}