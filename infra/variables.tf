variable "env" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "invoice"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for CloudFront custom domain. Leave empty to use the default *.cloudfront.net cert."
  default     = ""
}
