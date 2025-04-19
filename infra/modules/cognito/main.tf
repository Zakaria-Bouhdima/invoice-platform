resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                = "${var.user_pool_name}-client"
  user_pool_id        = aws_cognito_user_pool.pool.id
  generate_secret     = true
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH"]
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = var.user_pool_name
  user_pool_id = aws_cognito_user_pool.pool.id
}



########

resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  schema {
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable               = true
    name                  = "email"
    required              = true
    string_attribute_constraints {
      min_length = 5
      max_length = 2048
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                = "${var.user_pool_name}-client"
  user_pool_id        = aws_cognito_user_pool.pool.id
  generate_secret     = true
  allowed_oauth_flows = ["code"]
}







