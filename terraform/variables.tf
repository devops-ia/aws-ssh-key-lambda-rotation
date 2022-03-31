# GENERAL

variable "tags" {
  description = "Service tags"
  type        = map(string)
  default     = null
}

# LAMBDA
variable "lambda_handler" {
  description = "Lambda handler init"
  type        = string
  default     = "main.main"
}

variable "lambda_runtime" {
  description = "Lambda program runtime"
  type        = string
  default     = "python3.8"
}

variable "lambda_timeout" {
  description = "Lambda timeout"
  type        = number
  default     = 60
}

variable "lambda_s3_prefix" {
  description = "Bucket S3 Prefix"
  type        = string
  default     = "current"
}

variable "lambda_private_key_name" {
  description = "Private Key Name"
  type        = string
  default     = "tag.pem"
}

variable "lambda_public_key_name" {
  description = "Public Key Name"
  type        = string
  default     = "tag.pub"
}

variable "lambda_tag_key" {
  description = "Tag Key"
  type        = string
  default     = "provisioning"
}

# LAMBDA LAYER
variable "lambda_layer_package" {
  description = "Lambda layer package"
  type        = string
  default     = "crypto"
}

variable "lambda_layer_runtime" {
  description = "List of layer runtime compatible"
  type        = list(any)
  default     = ["python3.8", "python3.9"]
}

# Cloudwatch Logs
variable "loggroup_ssh_rotate_retention" {
  description = "AWS Cloudwatch Logs Retention for SSM Run Command"
  type        = number
  default     = 365
}

# SQS
variable "sqs_delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)"
  type        = number
  default     = 60
}

variable "sqs_visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)"
  type        = number
  default     = 180
}