# Outputs
output "api_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}