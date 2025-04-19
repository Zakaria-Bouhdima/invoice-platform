resource "aws_s3_bucket" "bucket" {
  bucket = "invoice-storage-${var.environment}"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}




#####################"
resource "aws_s3_bucket" "bucket" {
  bucket = "invoice-storage-${random_string.suffix.result}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}"