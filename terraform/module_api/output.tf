
output "stage_invoke_url" {
  value = aws_api_gateway_stage.rest_api.invoke_url
}

output "aws_api_gateway_rest_api_id" {
  value = aws_api_gateway_rest_api.rest_api.id
}
