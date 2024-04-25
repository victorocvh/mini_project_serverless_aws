
# Output modulo ddb 
output "module_ddb_table_id" {
  value = module.module_ddb.users_table_id
}

output "module_ddb_table_arn" {
  value = module.module_ddb.users_table_arn
}

# Modulo Lambda 

output "module_lambda_invoke_arn" {
  value = module.module_lambda.lambda_invoke_arn
}

output "module_lambda_function_name" {
  value = module.module_lambda.lambda_function_name
}

# Modulo API 
output "module_api_invoke_url" {
  value = module.module_api.stage_invoke_url
}


# Modulo Cognito 

output "module_cognito_user_pool" {
  value = module.module_cognito.user_pool
}

output "module_cognito_user_pool_client" {
  value = module.module_cognito.user_pool_client
}

output "module_cognito_user_pool_admin_group" {
  value = module.module_cognito.user_pool_admin_group
}

output "module_cognito_cognito_login_url" {
  value = module.module_cognito.cognito_login_url
}

output "module_cognito_cognito_login_auth_command" {
  value = module.module_cognito.cognito_login_auth_command
}
