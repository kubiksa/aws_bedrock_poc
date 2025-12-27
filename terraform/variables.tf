variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "project_name" {
  type        = string
  description = "Name prefix for all resources"
  default     = "compliance-copilot"
}

variable "kb_s3_bucket_name" {
  type        = string
  description = "Existing bucket for compliance docs (optional)"
  default     = "compliance-copilot-kb-docs"
}

variable "kb_id" {
  type        = string
  description = "Knowledge Base ID"
  default     = "GEY4CRP1FJ"
}
variable "foundation_model_id" {
  type        = string
  description = "Bedrock FM for Q&A"
  default     = "amazon.nova-lite-v1:0" # or another cheap model
}

variable "embedding_model_id" {
  type        = string
  description = "Bedrock embedding model for KB"
  default     = "amazon.titan-embed-text-v2:0"
}
