# Allow Lambda to use Textract
data "aws_iam_policy_document" "lambda_perms" {
  statement {
    effect = "Allow"
    actions = [
      "textract:DetectDocumentText",
      "textract:StartDocumentAnalysis"
    ]
    resources = ["*"]
  }
  
  # Add SES permissions for distribution Lambda
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}


#####

