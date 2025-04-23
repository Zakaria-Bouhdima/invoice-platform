resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = replace(var.s3_bucket_arn, "arn:aws:s3:::", "")
    origin_id   = "S3-${replace(var.s3_bucket_arn, "arn:aws:s3:::", "")}"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    forwarded_values {
      query_string = false
    cookies {
      forward = "none"
    }
  }
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${replace(var.s3_bucket_arn, "arn:aws:s3:::", "")}"

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}