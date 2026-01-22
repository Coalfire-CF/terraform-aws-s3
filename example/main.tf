module "s3_bucket" {
  source = "git::https://github.com/Coalfire-CF/terraform-aws-s3?ref=vx.x.x"

  name                                 = "${var.resource_prefix}-bucket"
  enable_lifecycle_configuration_rules = var.enable_lifecycle_configuration_rules #true
  lifecycle_configuration_rules = [                                               # These are just example values. Discuss these values with the team.
    {
      id      = "test"
      prefix  = var.resource_prefix
      enabled = true
      tags    = null

      enable_glacier_transition            = true
      enable_deeparchive_transition        = false
      enable_standard_ia_transition        = false
      enable_current_object_expiration     = true
      enable_noncurrent_version_expiration = true

      abort_incomplete_multipart_upload_days         = 7
      noncurrent_version_glacier_transition_days     = 30
      noncurrent_version_deeparchive_transition_days = 90
      noncurrent_version_expiration_days             = 60

      standard_transition_days    = 7
      glacier_transition_days     = 30
      deeparchive_transition_days = 90
      expiration_days             = 366
    }
  ]

  enable_kms                    = var.enable_kms                    # true
  enable_server_side_encryption = var.enable_server_side_encryption # true
  kms_master_key_id             = var.kms_master_key_id

}