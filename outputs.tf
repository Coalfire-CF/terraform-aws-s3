output "id" {
  value       = join("", aws_s3_bucket.s3_default.*.id)
  description = "The ID of the s3 bucket."
}

output "arn" {
  value       = join("", aws_s3_bucket.s3_default.*.arn)
  description = "The ARN of the s3 bucket."
}

output "bucket_domain_name" {
  value       = join("", aws_s3_bucket.s3_default.*.bucket_domain_name)
  description = "The Domain of the s3 bucket."
}

output "key_iam" {
  value       = join("", aws_s3_bucket.s3_default.*.bucket_domain_name)
  description = "The Domain of the s3 bucket."
}