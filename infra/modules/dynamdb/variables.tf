variable "table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "The hash key for the DynamoDB table"
  type        = string
}

variable "range_key" {
  description = "The range key for the DynamoDB table"
  type        = string
}