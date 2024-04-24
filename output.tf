
output "module_ddb_table_id" {
  value = module.module_ddb.users_table_id
}

output "module_ddb_table_arn" {
  value = module.module_ddb.users_table_arn
}

output "module_lambda_invoke_arn" {
  value = module.module_lambda.lambda_invoke_arn
}

output "module_lambda_function_name" {
  value = module.module_lambda.lambda_function_name
}

output "module_api_invoke_url" {
  value = module.module_api.stage_invoke_url
}
