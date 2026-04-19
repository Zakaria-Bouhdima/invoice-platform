output "api_url" {
  description = "API Gateway invoke URL"
  value       = module.api_gateway.api_url
}

output "cloudfront_url" {
  description = "CloudFront URL for the frontend"
  value       = module.cdn.cloudfront_url
}

output "cognito_user_pool_id" {
  description = "Cognito user pool ID — use as VITE_COGNITO_USER_POOL_ID"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "Cognito app client ID — use as VITE_COGNITO_CLIENT_ID"
  value       = module.cognito.client_id
}
