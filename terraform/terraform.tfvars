# Global Vars
my_ip = "<your-public-ip>"
## Region
region = "eu-west-1"

## Tags
tags = {
  "environment" = "Develop"
  "project"     = "ssh-rotate"
}

tags_rotate = {
  "rotate" = "instances"
}

## Enable Testing Resources
testing_enabled = true

## AWS Cloudwatch
### Log Group
log_group_from_ssm_retention = 30

### Alarm
cw_metric_alarm = {
  default = {
    complementary_alarm_name        = "LambdaRotateError"
    comparison_operator             = "GreaterThanOrEqualToThreshold"
    evaluation_periods              = 1
    complementary_namespace_name    = "LogMetrics"
    period                          = 120
    statistic                       = "Average"
    threshold                       = 1
    complementary_alarm_description = "Error on Lambda SSH Rotate"
    insufficient_data_actions       = []
    datapoints_to_alarm             = 1
    treat_missing_data              = "notBreaching"
  }
}

## AWS EventBridge
### Deploy Function
event_rule_deploy_function = {
  default = {
    enabled = false
  }
}

### Rotate Function
event_rule_rotate_function = {
  default = {
    enabled    = false
    expression = "cron(45 15 4 * ? *)" # UTC
  }
}

## AWS Lambda
### Function
lambda_function = {
  default = {
    lambda_description      = "Lambda to rotate the SSH keys of the platform instances"
    lambda_handler          = "main.main"
    lambda_runtime          = "python3.8"
    lambda_publish          = true
    lambda_timeout          = 120
    lambda_cw_log_retention = 30
    lambda_s3_prefix        = "current"
    lambda_admin_user       = "ec2-user"
    lambda_script_loop      = 10
    lambda_script_sleep     = 10
  }
}

### Layer
lambda_layer = {
  default = {
    compatible_runtimes = ["python3.8"]
  }
}

## AWS SNS
sns_config = {
  sns_ssm_run_command = {
    display_name = "AWS SSM Run Command has failed on at least one instance during the key rotation process."
    subscriptions = {
      "default@default.org" = {
        confirmation_timeout_in_minutes = 1
        endpoint_auto_confirms          = false
        protocol                        = "email"
      }
      "default@default.org" = {
        confirmation_timeout_in_minutes = 1
        endpoint_auto_confirms          = false
        protocol                        = "email"
      }
    }
  }
  sns_lambda_failed = {
    display_name = "AWS Lambda has failed on at least one instance during the key rotation process."
    subscriptions = {
      "default@default.org" = {
        confirmation_timeout_in_minutes = 1
        endpoint_auto_confirms          = false
        protocol                        = "email"
      }
    }
  }
  sns_rotate_function_success = {
    display_name = "Rotate function has success."
    subscriptions = {
      "default@default.org" = {
        confirmation_timeout_in_minutes = 1
        endpoint_auto_confirms          = false
        protocol                        = "email"
      }
    }
  }
}

## AWS SQS
sqs_config = {
  deploy = {
    delay_seconds              = 120
    visibility_timeout_seconds = 180
    managed_sse_enabled        = true
  }
  rotate = {
    delay_seconds              = 0
    visibility_timeout_seconds = 180
    managed_sse_enabled        = true
  }
}
