resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "Invoice Processing API"
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.cognito_user_pool_arn]
}

resource "aws_api_gateway_resource" "invoices" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "invoices"
}

# Add method and integration configurations here


# POST /invoices endpoint
resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.invoices.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  
  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

# Lambda Integration
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.invoices.id
  http_method = aws_api_gateway_method.post.http_method
  
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_ingestion.invoke_arn
}




#################""""
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "API for invoice processing"
}

resource "aws_api_gateway_resource" "invoices" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "invoices"
}

resource "aws_api_gateway_method" "post_invoices" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.invoices.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "CognitoAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.cognito_user_pool_arn]
}