data "aws_region" "current" {}

# IAM role for Bedrock Agent
resource "aws_iam_role" "agent_role" {
  name = "${var.project_name}-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "bedrock.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
        ArnLike = {
          "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:agent/*"
        }
      }
    }]
  })
}

data "aws_caller_identity" "current" {}

# IAM policy for agent to invoke foundation model
resource "aws_iam_role_policy" "agent_model_policy" {
  name = "${var.project_name}-agent-model-policy"
  role = aws_iam_role.agent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          # Inference profiles (for Nova, Claude with profiles)
          "arn:aws:bedrock:${data.aws_region.current.region}::inference-profile/*",
          # Direct model access (fallback)
          "arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/*"
        ]
      }
    ]
  })
}

# IAM policy for agent to access knowledge base
resource "aws_iam_role_policy" "agent_kb_policy" {
  name = "${var.project_name}-agent-kb-policy"
  role = aws_iam_role.agent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve"
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:knowledge-base/${var.kb_id}"
      }
    ]
  })
}

# Bedrock Agent
resource "aws_bedrockagent_agent" "agent" {
  agent_name              = "${var.project_name}-agent"
  agent_resource_role_arn = aws_iam_role.agent_role.arn
  foundation_model        = var.foundation_model_id
  description             = "Compliance copilot agent for water utilities"

  instruction = var.agent_instruction

  idle_session_ttl_in_seconds = 600

  depends_on = [
    aws_iam_role_policy.agent_model_policy,
    aws_iam_role_policy.agent_kb_policy
  ]
}

# Associate Knowledge Base with Agent
resource "aws_bedrockagent_agent_knowledge_base_association" "kb_assoc" {
  agent_id             = aws_bedrockagent_agent.agent.id
  knowledge_base_id    = var.kb_id
  description          = "Compliance documentation knowledge base"
  knowledge_base_state = "ENABLED"
}

# Prepare the agent (required before creating alias)
resource "null_resource" "prepare_agent" {
  triggers = {
    agent_id = aws_bedrockagent_agent.agent.id
    kb_id    = var.kb_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for agent to be ready..."
      sleep 60
      
      echo "Preparing agent..."
      aws bedrock-agent prepare-agent \
        --agent-id ${aws_bedrockagent_agent.agent.id} \
        --region ${data.aws_region.current.region}
      
      echo "Waiting for prepare to complete..."
      sleep 30
      
      echo "Agent prepared successfully"
    EOT
  }

  depends_on = [
    aws_bedrockagent_agent_knowledge_base_association.kb_assoc
  ]
}

# Agent Alias - created AFTER agent is prepared
resource "aws_bedrockagent_agent_alias" "agent_alias" {
  agent_alias_name = "live"
  agent_id         = aws_bedrockagent_agent.agent.id
  description      = "Production alias for agent"

  # Wait for prepare to finish
  depends_on = [null_resource.prepare_agent]
  
  # Add lifecycle to prevent recreation on every apply
  lifecycle {
    create_before_destroy = false
  }
}

# Additional wait after alias creation
resource "null_resource" "wait_for_alias" {
  triggers = {
    alias_id = aws_bedrockagent_agent_alias.agent_alias.agent_alias_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for alias to be fully ready..."
      sleep 15
    EOT
  }

  depends_on = [aws_bedrockagent_agent_alias.agent_alias]
}