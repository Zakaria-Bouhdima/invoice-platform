variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  type        = string
}