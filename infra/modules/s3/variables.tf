variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "enable_static_website" {
  type        = bool
  description = "Enable static website hosting"
  default     = false
}

variable "env" {
  type        = string
  description = "Deployment environment"
}
