locals {
  prefix = "${var.project}-${var.env}"
}

module "cognito" {
  source         = "./modules/cognito"
  user_pool_name = "${local.prefix}-pool"
  env            = var.env
}

module "api_gateway" {
  source                = "./modules/api-gateway"
  api_name              = "${local.prefix}-api"
  cognito_user_pool_arn = module.cognito.user_pool_arn
  lambda_invoke_arn     = module.lambda_ingestion.invoke_arn
  lambda_function_name  = module.lambda_ingestion.function_name
  env                   = var.env
}

module "invoice_storage" {
  source      = "./modules/s3"
  bucket_name = "${local.prefix}-invoices"
  env         = var.env
}

module "frontend_bucket" {
  source                = "./modules/s3"
  bucket_name           = "${local.prefix}-frontend"
  enable_static_website = true
  env                   = var.env
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "${local.prefix}-client-rules"
  env        = var.env
}

module "sqs_transform" {
  source     = "./modules/sqs"
  queue_name = "${local.prefix}-transform"
  env        = var.env
}

module "sqs_distribute" {
  source     = "./modules/sqs"
  queue_name = "${local.prefix}-distribute"
  env        = var.env
}

module "lambda_ingestion" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-ingestion"
  runtime       = "python3.13"
  handler       = "main.handler"
  code_path     = "${path.module}/../lambdas/ingestion"
  env           = var.env

  environment_vars = {
    S3_BUCKET     = module.invoice_storage.bucket_name
    SQS_QUEUE_URL = module.sqs_transform.queue_url
  }

  s3_bucket_arn  = module.invoice_storage.bucket_arn
  sqs_queue_arns = [module.sqs_transform.queue_arn]
}

module "lambda_transformation" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-transformation"
  runtime       = "python3.13"
  handler       = "main.handler"
  code_path     = "${path.module}/../lambdas/transformation"
  env           = var.env

  environment_vars = {
    S3_BUCKET      = module.invoice_storage.bucket_name
    DYNAMODB_TABLE = module.dynamodb.table_name
    SQS_QUEUE_URL  = module.sqs_distribute.queue_url
  }

  s3_bucket_arn      = module.invoice_storage.bucket_arn
  dynamodb_table_arn = module.dynamodb.table_arn
  sqs_queue_arns     = [module.sqs_distribute.queue_arn]
  sqs_source_arns    = [module.sqs_transform.queue_arn]
}

module "lambda_distribution" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-distribution"
  runtime       = "python3.13"
  handler       = "main.handler"
  code_path     = "${path.module}/../lambdas/distribution"
  env           = var.env

  environment_vars = {
    S3_BUCKET = module.invoice_storage.bucket_name
    THIRD_PARTY_APIS = jsonencode({
      "api1" = "https://api.example.com/v1/invoices"
      "api2" = "https://api.partner.com/v1/invoices"
    })
  }

  s3_bucket_arn   = module.invoice_storage.bucket_arn
  sqs_source_arns = [module.sqs_distribute.queue_arn]
}

resource "aws_lambda_event_source_mapping" "transform_trigger" {
  event_source_arn = module.sqs_transform.queue_arn
  function_name    = module.lambda_transformation.function_name
  batch_size       = 1
}

resource "aws_lambda_event_source_mapping" "distribute_trigger" {
  event_source_arn = module.sqs_distribute.queue_arn
  function_name    = module.lambda_distribution.function_name
  batch_size       = 1
}

module "cdn" {
  source              = "./modules/cdn"
  bucket_id           = module.frontend_bucket.bucket_id
  bucket_arn          = module.frontend_bucket.bucket_arn
  bucket_domain_name  = module.frontend_bucket.bucket_regional_domain_name
  acm_certificate_arn = var.acm_certificate_arn
  env                 = var.env
}

module "monitoring" {
  source                     = "./modules/monitoring"
  env                        = var.env
  lambda_ingestion_name      = module.lambda_ingestion.function_name
  lambda_transformation_name = module.lambda_transformation.function_name
  lambda_distribution_name   = module.lambda_distribution.function_name
  sqs_transform_name         = module.sqs_transform.queue_name
  sqs_distribute_name        = module.sqs_distribute.queue_name
  dlq_transform_name         = module.sqs_transform.dlq_name
  dlq_distribute_name        = module.sqs_distribute.dlq_name
}
