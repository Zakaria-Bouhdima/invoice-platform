data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.code_path  # Path to your Lambda code
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler
  role          = aws_iam_role.lambda_exec.arn
  filename      = data.archive_file.lambda_zip.output_path
  #source_code_hash = filebase64sha256("${path.module}/lambda.zip")
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)


  environment {
    variables = var.environment_vars
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}