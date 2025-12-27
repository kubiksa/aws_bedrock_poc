variable "project_name" {
  type = string
}

variable "kb_s3_bucket_name" {
  type    = string
  default = ""
}

variable "embedding_model_id" {
  type = string
}

variable "kb_id" {
  description = "Knowledge Base ID (created manually via console)"
  type        = string
  default     = ""
}