variable "bucket_id" {
  type        = string
  description = "S3 bucket ID"
}

variable "bucket_arn" {
  type        = string
  description = "S3 bucket ARN"
}

variable "bucket_domain_name" {
  type        = string
  description = "S3 bucket regional domain name"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN. Leave empty for default CloudFront cert."
  default     = ""
}

variable "env" {
  type        = string
  description = "Deployment environment"
}
