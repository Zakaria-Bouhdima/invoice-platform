
# ============================
# MODULES
# ============================

# Cognito for Authentication
module "cognito" {
  source = "./modules/cognito"
  user_pool_name = "invoice-pool"
}

# API Gateway
module "api_gateway" {
  source = "./modules/api-gateway"
  cognito_user_pool_arn = module.cognito.user_pool_arn
  api_name              = "invoice-api"
}


module "frontend" {
  source = "./modules/frontend"
  bucket_name             = "invoice-platform-frontend"
  enable_static_website   = true
  acm_certificate_arn = var.acm_certificate_arn

   index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}


# ============================
# S3 (For storing raw JSON and original documents)
# ============================
module "invoice_storage" {
  source = "./modules/s3"
  bucket_name             = "invoice-backend-storage"
  enable_static_website   = false
}

# DynamoDB for Transformation Rules
module "dynamodb" {
  source = "./modules/dynamodb"
  table_name = "ClientRules"
  hash_key   = "clientId"
  range_key  = "version"
}

# EventBridge for Orchestration
module "eventbridge" {
  source = "./modules/eventbridge"
}

# Lambda Functions
module "lambda_ingestion" {
  source = "./modules/lambda"
  function_name    = "invoice-ingestion"
  runtime          = "python3.9"
  handler          = "main.handler"
  code_path        = "../../lambdas/ingestion"
  environment_vars = {
    S3_BUCKET       = module.backend_storage.bucket_name
    EVENT_BUS_NAME  = module.eventbridge.bus_name
  }
}

module "lambda_transformation" {
  source = "./modules/lambda"
  function_name    = "invoice-transformation"
  runtime          = "python3.9"
  handler          = "main.handler"
  code_path        = "../../lambdas/transformation"
  environment_vars = {
    DYNAMODB_TABLE = module.dynamodb.table_name
    S3_BUCKET      = module.backend_storage.bucket_name
    EVENT_BUS_NAME = module.eventbridge.bus_name
  }
}

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