

  



   variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime for the Lambda function"
  type        = string
}

variable "handler" {
  description = "The handler for the Lambda function"
  type        = string
}

variable "code_path" {
  description = "Path to the Lambda function code"
  type        = string
}

variable "environment_vars" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
}