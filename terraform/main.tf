data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 1) Knowledge base + data source
module "bedrock_kb" {
  source = "./modules/bedrock_kb"

  project_name       = var.project_name
  kb_s3_bucket_name  = var.kb_s3_bucket_name
  embedding_model_id = var.embedding_model_id
}

# 2) Agent wired to the KB
module "bedrock_agent" {
  source = "./modules/bedrock_agent"

  project_name       = var.project_name
  foundation_model_id = var.foundation_model_id
  kb_id              = module.bedrock_kb.kb_id
}

# 3) Lambda + API that calls the Agent
module "api_lambda" {
  source = "./modules/api_lambda"

  project_name   = var.project_name
  agent_id       = module.bedrock_agent.agent_id
  agent_alias_id = module.bedrock_agent.agent_alias_id
  region         = data.aws_region.current.name
}