data "aws_region" "current" {}

# 1) Knowledge Base
module "bedrock_kb" {
  source = "./modules/bedrock_kb"

  project_name        = var.project_name
  embedding_model_id  = var.embedding_model_id
  kb_id               = var.kb_id  # Set this after console creation
}

# 2) Agent wired to the KB
module "bedrock_agent" {
  source = "./modules/bedrock_agent"

  project_name        = var.project_name
  foundation_model_id = var.foundation_model_id
  kb_id               = var.kb_id
}

# 3) Lambda + API that calls the Agent
module "api_lambda" {
  source = "./modules/api_lambda"

  project_name   = var.project_name
  agent_id       = module.bedrock_agent.agent_id
  agent_alias_id = module.bedrock_agent.agent_alias_id
  region         = data.aws_region.current
}