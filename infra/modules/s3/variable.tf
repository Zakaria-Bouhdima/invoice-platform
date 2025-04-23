variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
}

variable "enable_static_website" {
  description = "Whether to enable static website hosting for the bucket."
  type        = bool
  default     = false
}