variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "foundation_model_id" {
  description = "Bedrock foundation model ID for the agent"
  type        = string
}

variable "kb_id" {
  description = "Knowledge Base ID to associate with agent"
  type        = string
}

variable "agent_instruction" {
  description = "Instructions for the agent"
  type        = string
  default     = <<-EOT
    You are a helpful compliance assistant for water and wastewater utilities.
    Use the knowledge base to answer questions about regulations, standards, and compliance requirements.
    Always cite sources from the knowledge base when providing answers.
    If you don't find relevant information in the knowledge base, say so clearly.
  EOT
}