resource "aws_cloudwatch_event_bus" "bus" {
  name = "InvoiceProcessingBus"
}

resource "aws_cloudwatch_event_rule" "transformation_trigger" {
  name        = "TransformationTrigger"
  description = "Triggers the transformation Lambda after ingestion"
  event_pattern = jsonencode({
    source = ["aws.lambda"]
  })
}

resource "aws_cloudwatch_event_target" "transformation_target" {
  rule      = aws_cloudwatch_event_rule.transformation_trigger.name
  arn       = module.lambda_transformation.lambda_arn
  target_id = "TransformationTarget"
}