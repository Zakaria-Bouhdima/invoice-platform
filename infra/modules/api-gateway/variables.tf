variable "api_name" {
  type        = string
  description = "API Gateway name"
}

variable "cognito_user_pool_arn" {
  type        = string
  description = "Cognito user pool ARN for the authorizer"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Lambda ingestion invoke ARN"
}

variable "lambda_function_name" {
  type        = string
  description = "Lambda ingestion function name"
}

variable "env" {
  type        = string
  description = "Deployment environment"
}
