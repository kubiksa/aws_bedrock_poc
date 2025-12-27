output "api_endpoint" {
  value       = aws_apigatewayv2_api.api.api_endpoint
  description = "API Gateway endpoint URL"
}

output "api_url" {
  value       = "${aws_apigatewayv2_api.api.api_endpoint}/query"
  description = "Full API URL to call"
}

output "lambda_function_name" {
  value       = aws_lambda_function.agent_api.function_name
  description = "Lambda function name"
}