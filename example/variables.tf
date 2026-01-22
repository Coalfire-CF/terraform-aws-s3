variable "resource_prefix" {
  description = "The prefix for resources"
  type        = string
}

variable "enable_lifecycle_configuration_rules" {
  description = "Whether or not to enable lifecycle configuration rules"
  type        = bool
  default     = true
}

variable "enable_kms" {
  description = "Whether or not to enable KMS on the bucket"
  type        = bool
  default     = true
}

variable "enable_server_side_encryption" {
  description = "Whether or not to enable server side encryption"
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "profile" {
  description = "The AWS profile aligned with the AWS environment to deploy to"
  type        = string
}