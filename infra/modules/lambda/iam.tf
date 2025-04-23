# Allow Lambda to use Textract
 #data "aws_iam_policy_document" "lambda_perms" {
   #statement {
     #effect = "Allow"
    #"actions = [
      #"textract:DetectDocumentText",
     # "textract:StartDocumentAnalysis"
    #]
    #resources = ["*"]
  #}
  
  # Add SES permissions for distribution Lambda
  #statement {
   # effect = "Allow"
   # actions = [
    #  "ses:SendEmail",
     # "ses:SendRawEmail"
    #]
    #resources = ["*"]
  #}
#}

data "aws_iam_policy_document" "lambda_perms" {
  statement {
    effect = "Allow"
    actions = [
      "textract:DetectDocumentText",
      "textract:StartDocumentAnalysis"
    ]
    resources = ["*"]
  }

  # Add permissions for DynamoDB and S3
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_perms.json
}
