resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "invoice-platform-${var.env}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "Lambda Errors"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_ingestion_name],
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_transformation_name],
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_distribution_name],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "Lambda Duration (p99)"
          period = 300
          stat   = "p99"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_ingestion_name],
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_transformation_name],
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_distribution_name],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "SQS Queue Depth"
          period = 300
          stat   = "Maximum"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.sqs_transform_name],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.sqs_distribute_name],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "DLQ Messages (failures)"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.dlq_transform_name],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.dlq_distribute_name],
          ]
        }
      },
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = toset([
    var.lambda_ingestion_name,
    var.lambda_transformation_name,
    var.lambda_distribution_name,
  ])

  alarm_name          = "${each.key}-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5

  dimensions = { FunctionName = each.key }

  tags = { Environment = var.env }
}

resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  for_each = toset([var.dlq_transform_name, var.dlq_distribute_name])

  alarm_name          = "${each.key}-not-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0

  dimensions = { QueueName = each.key }

  tags = { Environment = var.env }
}
