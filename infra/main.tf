# ============================
# COGNITO (Authentication)
# ============================
module "cognito" {
  source = "./modules/cognito"
  user_pool_name = "invoice-pool"
}

# ============================
# API GATEWAY
# ============================
module "api_gateway" {
  source = "./modules/api-gateway"
  cognito_user_pool_arn = module.cognito.user_pool_arn
  api_name              = "invoice-api"
}

# ============================
# S3 (For storing raw JSON and original documents)
# ============================
module "s3" {
  source = "./modules/s3"
}

# ============================
# DYNAMODB (For storing transformation rules)
# ============================
module "dynamodb" {
  source = "./modules/dynamodb"
  table_name = "ClientRules"
  hash_key   = "clientId"
  range_key  = "version"
}

# ============================
# EVENTBRIDGE (Orchestration between Lambdas)
# ============================
module "eventbridge" {
  source = "./modules/eventbridge"
}

# ============================
# LAMBDA: INGESTION
# ============================
module "lambda_ingestion" {
  source = "./modules/lambda"
  function_name    = "invoice-ingestion"
  runtime          = "python3.9"
  handler          = "main.handler"
  code_path        = "../../lambdas/ingestion"
  environment_vars = {
    S3_BUCKET       = module.s3.bucket_name
    EVENT_BUS_NAME  = module.eventbridge.bus_name
  }
}

# ============================
# LAMBDA: TRANSFORMATION
# ============================
module "lambda_transformation" {
  source = "./modules/lambda"
  function_name    = "invoice-transformation"
  runtime          = "python3.9"
  handler          = "main.handler"
  code_path        = "../../lambdas/transformation"
  environment_vars = {
    DYNAMODB_TABLE = module.dynamodb.table_name
    S3_BUCKET      = module.s3.bucket_name
    EVENT_BUS_NAME = module.eventbridge.bus_name
  }
}

# ============================
# LAMBDA: DISTRIBUTION
# ============================
module "lambda_distribution" {
  source = "./modules/lambda"
  function_name    = "invoice-distribution"
  runtime          = "python3.9"
  handler          = "main.handler"
  code_path        = "../../lambdas/distribution"
  environment_vars = {
    THIRD_PARTY_API_URLS = jsonencode({
      "api1" = "https://api.example.com/v1"
      "api2" = "https://api.anotherexample.com/v1"
    })
    RETRY_ATTEMPTS = 3
  }
}

# CLOUDFRONT (CDN for frontend assets)
module "cloudfront" {
  source = "./modules/cloudfront"
  s3_bucket_arn       = module.s3.bucket_arn
  acm_certificate_arn = var.acm_certificate_arn
}