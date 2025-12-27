# IAM Role ARN - Use this when creating KB in console
output "kb_role_arn" {
  value       = aws_iam_role.kb_role.arn
  description = "IAM role ARN to use when creating Knowledge Base in console"
}

# S3 Bucket Name
output "bucket_name" {
  value       = local.bucket_name
  description = "S3 bucket name for knowledge base documents"
}

# S3 URI - Copy/paste this into console
output "kb_s3_bucket_uri" {
  value       = "s3://${local.bucket_name}/"
  description = "S3 URI to use as data source in Bedrock console"
}

# Knowledge Base ID - Only available after manual creation
output "kb_id" {
  value       = var.kb_id != "" ? var.kb_id : "NOT_CREATED_YET"
  description = "Knowledge Base ID (set this in terraform.tfvars after console creation)"
}
