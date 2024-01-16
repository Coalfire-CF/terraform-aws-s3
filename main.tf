resource "aws_s3_bucket" "s3_default" {
  count = var.create_bucket == true ? 1 : 0

  bucket        = var.name
  force_destroy = var.force_destroy
  tags          = var.tags

}

resource "aws_s3_bucket_policy" "s3_default" {
  count  = var.bucket_policy == true ? 1 : 0
  bucket = join("", aws_s3_bucket.s3_default[*].id)
  policy = var.aws_iam_policy_document
}

resource "aws_s3_bucket_accelerate_configuration" "example" {
  count = var.create_bucket && var.acceleration_status == true ? 1 : 0

  bucket = join("", aws_s3_bucket.s3_default[*].id)
  status = "Enabled"
}

resource "aws_s3_bucket_request_payment_configuration" "example" {
  count = var.create_bucket && var.request_payer == true ? 1 : 0

  bucket = join("", aws_s3_bucket.s3_default[*].id)
  payer  = "Requester"
}

resource "aws_s3_bucket_versioning" "example" {
  count = var.create_bucket && var.versioning == true ? 1 : 0

  bucket = join("", aws_s3_bucket.s3_default[*].id)
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "example" {
  count  = var.create_bucket && var.logging == true ? 1 : 0
  bucket = join("", aws_s3_bucket.s3_default[*].id)

  target_bucket = var.target_bucket
  target_prefix = var.target_prefix
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  count  = var.create_bucket && var.enable_server_side_encryption == true ? 1 : 0
  bucket = join("", aws_s3_bucket.s3_default[*].id)

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms == true ? "aws:kms" : var.sse_algorithm
      kms_master_key_id = var.kms_master_key_id
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "example" {
  count = var.create_bucket && var.object_lock_configuration != null ? 1 : 0

  bucket = join("", aws_s3_bucket.s3_default[*].id)

  object_lock_enabled = "Enabled"

  rule {
    default_retention {
      mode  = var.object_lock_configuration.mode
      days  = var.object_lock_configuration.days
      years = var.object_lock_configuration.years
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  count = var.create_bucket && var.cors_rule != null ? 1 : 0

  bucket = join("", aws_s3_bucket.s3_default[*].id)

  dynamic "cors_rule" {
    for_each = var.cors_rule == null ? [] : var.cors_rule

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  count = var.create_bucket && var.website_config_enable == true ? 1 : 0

  bucket = join("", aws_s3_bucket.s3_default[*].id)

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }

  routing_rule {
    condition {
      key_prefix_equals = var.routing_rule
    }
    redirect {
      replace_key_prefix_with = var.redirect
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "default" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads" - False Positive due to dynamic block

  count  = var.create_bucket && var.enable_lifecycle_configuration_rules == true ? 1 : 0
  bucket = join("", aws_s3_bucket.s3_default[*].id)

  dynamic "rule" {
    for_each = var.lifecycle_configuration_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled == true ? "Enabled" : "Disabled"

      # Filter is always required due to https://github.com/hashicorp/terraform-provider-aws/issues/23299
      filter {
        dynamic "and" {
          for_each = (try(length(rule.value.prefix), 0) + try(length(rule.value.tags), 0)) > 0 ? [1] : []
          content {
            prefix = rule.value.prefix == null ? "" : rule.value.prefix
            tags   = try(length(rule.value.tags), 0) > 0 ? rule.value.tags : {}
          }
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(tonumber(rule.value.abort_incomplete_multipart_upload_days), null) != null ? [1] : []
        content {
          days_after_initiation = rule.value.abort_incomplete_multipart_upload_days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.enable_noncurrent_version_expiration ? [1] : []

        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.enable_glacier_transition ? [1] : []

        content {
          noncurrent_days = rule.value.noncurrent_version_glacier_transition_days
          storage_class   = "GLACIER"
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.enable_deeparchive_transition ? [1] : []

        content {
          noncurrent_days = rule.value.noncurrent_version_deeparchive_transition_days
          storage_class   = "DEEP_ARCHIVE"
        }
      }

      dynamic "transition" {
        for_each = rule.value.enable_glacier_transition ? [1] : []

        content {
          days          = rule.value.glacier_transition_days
          storage_class = "GLACIER"
        }
      }

      dynamic "transition" {
        for_each = rule.value.enable_deeparchive_transition ? [1] : []

        content {
          days          = rule.value.deeparchive_transition_days
          storage_class = "DEEP_ARCHIVE"
        }
      }

      dynamic "transition" {
        for_each = rule.value.enable_standard_ia_transition ? [1] : []

        content {
          days          = rule.value.standard_transition_days
          storage_class = "STANDARD_IA"
        }
      }

      dynamic "expiration" {
        for_each = rule.value.enable_current_object_expiration ? [1] : []

        content {
          days = rule.value.expiration_days
        }
      }
    }
  }

  depends_on = [
    # versioning must be set before lifecycle configuration
    aws_s3_bucket_versioning.example[0]
  ]
}

locals {
  attach_policy = var.attach_require_latest_tls_policy || var.attach_elb_log_delivery_policy || var.attach_lb_log_delivery_policy || var.attach_deny_insecure_transport_policy || var.attach_policy

}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create_bucket && var.attach_public_policy ? 1 : 0

  bucket = local.attach_policy ? aws_s3_bucket_policy.s3_default[0].id : aws_s3_bucket.s3_default[0].id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.create_bucket && var.control_object_ownership ? 1 : 0

  bucket = local.attach_policy ? aws_s3_bucket_policy.s3_default[0].id : aws_s3_bucket.s3_default[0].id

  rule {
    object_ownership = var.object_ownership
  }

  # This `depends_on` is to prevent "A conflicting conditional operation is currently in progress against this resource."
  depends_on = [
    aws_s3_bucket_policy.s3_default[0],
    aws_s3_bucket_public_access_block.this[0],
    aws_s3_bucket.s3_default[0]
  ]
}