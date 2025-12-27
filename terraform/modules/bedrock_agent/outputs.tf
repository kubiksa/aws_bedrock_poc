output "agent_id" {
  value       = aws_bedrockagent_agent.agent.id
  description = "Bedrock Agent ID"
  depends_on  = [null_resource.wait_for_alias]
}

output "agent_alias_id" {
  value       = aws_bedrockagent_agent_alias.agent_alias.agent_alias_id
  description = "Bedrock Agent Alias ID"
  depends_on  = [null_resource.wait_for_alias]
}

output "agent_arn" {
  value       = aws_bedrockagent_agent.agent.agent_arn
  description = "Bedrock Agent ARN"
}