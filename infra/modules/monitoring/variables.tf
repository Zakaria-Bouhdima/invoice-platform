variable "env" {
  type = string
}

variable "lambda_ingestion_name" {
  type = string
}

variable "lambda_transformation_name" {
  type = string
}

variable "lambda_distribution_name" {
  type = string
}

variable "sqs_transform_name" {
  type = string
}

variable "sqs_distribute_name" {
  type = string
}

variable "dlq_transform_name" {
  type = string
}

variable "dlq_distribute_name" {
  type = string
}
