# Global Config
variable "my_ip" {
  description = "My IP"
  type        = string
  default     = ""
}
variable "region" {
  description = "The AWS region"
  type        = string
  default     = null
}

variable "tags" {
  description = "Service tags"
  type        = map(string)
  default     = null
}

variable "tags_rotate" {
  description = "Service tags"
  type        = map(string)
  default     = null
}

# Enable Testing Resources
variable "testing_enabled" {
  description = "Create testing resources"
  type        = bool
  default     = false
}

# AWS Cloudwatch 
## Logs
variable "log_group_from_ssm_retention" {
  description = "AWS Cloudwatch Logs Retention for SSM Run Command"
  type        = number
  default     = 30
}

## Alarm
variable "cw_metric_alarm" {
  description = "AWS Cloudwatch Metric Alarm"
  type = map(object({
    complementary_alarm_name        = string
    comparison_operator             = string
    evaluation_periods              = number
    complementary_namespace_name    = string
    period                          = number
    statistic                       = string
    threshold                       = number
    complementary_alarm_description = string
    insufficient_data_actions       = list(string)
    datapoints_to_alarm             = number
    treat_missing_data              = string
  }))
  default = {}
}

# AWS EC2

# AWS EventBridge
variable "event_rule_deploy_function" {
  description = "AWS EventBridge Deploy Function"
  type = map(object({
    enabled = bool
  }))
  default = {}
}

variable "event_rule_rotate_function" {
  description = "AWS EventBridge Rotate Function"
  type = map(object({
    enabled    = bool
    expression = string
  }))
  default = {}
}

# AWS Lambda
variable "lambda_function" {
  description = "AWS Lambda Function values"
  type = map(object({
    lambda_handler          = string
    lambda_description      = string
    lambda_runtime          = string
    lambda_publish          = bool
    lambda_timeout          = number
    lambda_cw_log_retention = number
    lambda_s3_prefix        = string
    lambda_admin_user       = string
    lambda_script_loop      = number
    lambda_script_sleep     = number
  }))
  default = {}
}

## Layer
variable "lambda_layer" {
  description = "AWS Lambda layer"
  type = map(object({
    compatible_runtimes = list(string)
  }))
  default = {}
}

# AWS SNS
variable "sns_config" {
  description = "AWS SNS Configuration"
  type        = any
  default     = {}
}

# AWS SQS
variable "sqs_config" {
  description = "AWS SQS Configuration"
  type = map(object({
    delay_seconds              = number
    visibility_timeout_seconds = number
    managed_sse_enabled        = bool
  }))
  default = {}
}
