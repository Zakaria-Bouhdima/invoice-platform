resource "aws_cloudwatch_event_bus" "bus" {
  name = "InvoiceProcessingBus"
}

resource "aws_cloudwatch_event_rule" "transformation_trigger" {
  name        = "TransformationTrigger"
  description = "Triggers the transformation Lambda after ingestion"
  event_pattern = jsonencode({
    source     = ["aws.lambda"]
    detail-type = ["Lambda Function Invocation Result - Success"]
    resources  = [module.lambda_ingestion.lambda_arn]
  })
}

resource "aws_cloudwatch_event_target" "transformation_target" {
  rule      = aws_cloudwatch_event_rule.transformation_trigger.name
  arn       = module.lambda_transformation.lambda_arn
  target_id = "TransformationTarget"
   retry_policy {
    maximum_event_age_in_seconds = 60
    maximum_retry_attempts       = 3
  }
}