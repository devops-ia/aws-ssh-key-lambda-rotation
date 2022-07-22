# Data Sources

data "aws_caller_identity" "current" {}

## Data rendered files
### SQS Deploy Policy
data "template_file" "sqs_policy_deploy" {
  template = file("${path.module}/policies/sqs_policy_tpl.json")

  vars = {
    env               = "${lower(var.tags["environment"])}"
    resource          = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.deploy_name}"
    conditionResource = "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:rule/${local.deploy_name}"
  }
}

### SQS Rotate Policy
data "template_file" "sqs_policy_rotate" {
  template = file("${path.module}/policies/sqs_policy_tpl.json")

  vars = {
    env               = "${lower(var.tags["environment"])}"
    resource          = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.rotate_name}"
    conditionResource = "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:rule/${local.rotate_name}"
  }
}

### EventPattern to EventBridge
data "template_file" "event_pattern" {
  template = file("${path.module}/policies/event_pattern_tpl.json")

  vars = {
    state = "running"
  }
}

## Get AMI ID
data "aws_ami" "ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}