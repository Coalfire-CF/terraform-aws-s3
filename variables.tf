variable "name" {
  type        = string
  description = "Name of S3 bucket"
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "create_bucket" {
  type        = bool
  default     = true
  description = "Conditionally create S3 bucket."
}

variable "versioning" {
  type        = bool
  default     = true
  description = "Enable Versioning of S3."
}

variable "enable_server_side_encryption" {
  type        = bool
  default     = true
  description = "Enable enable_server_side_encryption"
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms."
}

variable "enable_kms" {
  type        = bool
  default     = true
  description = "Enable KMS key for enable_server_side_encryption"
}

variable "kms_master_key_id" {
  type        = string
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  default     = null
}

variable "enable_lifecycle_configuration_rules" {
  type        = bool
  default     = true
  description = "enable or disable lifecycle_configuration_rules"
}

variable "lifecycle_configuration_rules" {
  type = list(object({
    id      = string
    prefix  = optional(string, null)
    enabled = bool
    tags    = optional(map(string), null)

    enable_glacier_transition            = optional(bool, true)
    enable_deeparchive_transition        = optional(bool, false)
    enable_standard_ia_transition        = optional(bool, false)
    enable_current_object_expiration     = optional(bool, true)
    enable_noncurrent_version_expiration = optional(bool, true)

    abort_incomplete_multipart_upload_days         = optional(number, null)
    noncurrent_version_glacier_transition_days     = optional(number, null)
    noncurrent_version_deeparchive_transition_days = optional(number, null)
    noncurrent_version_expiration_days             = optional(number, null)

    standard_transition_days    = optional(number, null)
    glacier_transition_days     = optional(number, null)
    deeparchive_transition_days = optional(number, null)
    expiration_days             = optional(number, null)
  }))
  default = [
    {
      id      = "default"
      enabled = true

      enable_glacier_transition            = true
      enable_current_object_expiration     = true
      enable_noncurrent_version_expiration = true

      abort_incomplete_multipart_upload_days     = 1
      noncurrent_version_glacier_transition_days = 90
      noncurrent_version_expiration_days         = 365
      glacier_transition_days                    = 90
      expiration_days                            = 365
    }
  ]
  description = "A list of lifecycle rules"
}


# Module      : S3 BUCKET POLICY
# Description : Terraform S3 Bucket Policy module variables.
variable "aws_iam_policy_document" {
  type        = string
  default     = ""
  sensitive   = true
  description = "The text of the policy. Although this is a bucket policy rather than an IAM policy, the aws_iam_policy_document data source may be used, so long as it specifies a principal. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. Note: Bucket policies are limited to 20 KB in size."
  #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
}

variable "bucket_policy" {
  type        = bool
  default     = false
  description = "Conditionally create S3 bucket policy."
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
}

variable "website_config_enable" {
  type        = bool
  default     = false
  description = "enable or disable aws_s3_bucket_website_configuration"
}

variable "index_document" {
  type        = string
  default     = "index.html"
  description = "The name of the index document for the website"
}
variable "error_document" {
  type        = string
  default     = "error.html"
  description = "he name of the error document for the website "
}
variable "routing_rule" {
  type        = string
  default     = "docs/"
  description = "List of rules that define when a redirect is applied and the redirect behavior "
}
variable "redirect" {
  type        = string
  default     = "documents/"
  description = "The redirect behavior for every request to this bucket's website endpoint "
}

variable "logging" {
  type        = bool
  default     = false
  description = "Logging Object to enable and disable logging"
}

variable "target_bucket" {
  type        = string
  default     = ""
  description = "The bucket where you want Amazon S3 to store server access logs."
}

variable "target_prefix" {
  type        = string
  default     = ""
  description = "A prefix for all log object keys."
}

variable "acceleration_status" {
  type        = bool
  default     = false
  description = "Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended"
}

variable "request_payer" {
  type        = bool
  default     = false
  description = "Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer"
}


variable "object_lock_configuration" {
  type = object({
    mode  = string #Valid values are GOVERNANCE and COMPLIANCE.
    days  = number
    years = number
  })
  default     = null
  description = "With S3 Object Lock, you can store objects using a write-once-read-many (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely."

}

variable "cors_rule" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default     = null
  description = "CORS Configuration specification for this bucket"
}

variable "attach_public_policy" {
  description = "Controls if a user defined public bucket policy will be attached (set to `false` to allow upstream to apply defaults to the bucket)"
  type        = bool
  default     = true
}
variable "attach_elb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ELB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_lb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ALB/NLB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_insecure_transport_policy" {
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached"
  type        = bool
  default     = false
}

variable "attach_require_latest_tls_policy" {
  description = "Controls if S3 bucket should require the latest version of TLS"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL."
  type        = string
  default     = "ObjectWriter"
}
variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}
