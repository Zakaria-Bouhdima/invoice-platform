resource "aws_dynamodb_table" "table" {
   point_in_time_recovery {
    enabled = true
  }
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = var.hash_key
  range_key      = var.range_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  attribute {
    name = var.range_key
    type = "S"
  }
  ttl {
  attribute_name = "expiration_time"
  enabled         = true
}
}

