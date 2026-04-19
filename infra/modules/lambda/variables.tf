variable "function_name" {
  type        = string
  description = "Lambda function name"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.13"
}

variable "handler" {
  type        = string
  description = "Lambda handler"
  default     = "main.handler"
}

variable "code_path" {
  type        = string
  description = "Path to the Lambda source code directory"
}

variable "timeout" {
  type        = number
  description = "Lambda timeout in seconds"
  default     = 30
}

variable "memory_size" {
  type        = number
  description = "Lambda memory in MB"
  default     = 256
}

variable "environment_vars" {
  type        = map(string)
  description = "Lambda environment variables"
  default     = {}
}

variable "env" {
  type        = string
  description = "Deployment environment"
}

variable "s3_bucket_arn" {
  type        = string
  description = "S3 bucket ARN for IAM policy"
  default     = ""
}

variable "dynamodb_table_arn" {
  type        = string
  description = "DynamoDB table ARN for IAM policy"
  default     = ""
}

variable "sqs_queue_arns" {
  type        = list(string)
  description = "SQS queue ARNs this function can send to"
  default     = []
}

variable "sqs_source_arns" {
  type        = list(string)
  description = "SQS queue ARNs this function receives from"
  default     = []
}
