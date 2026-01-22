output "id" {
  value       = module.s3_bucket.id
  description = "The ID of the s3 bucket."
}

output "arn" {
  value       = module.s3_bucket.arn
  description = "The ARN of the s3 bucket."
}

output "bucket_domain_name" {
  value       = module.s3_bucket.bucket_domain_name
  description = "The Domain of the s3 bucket."
}