
module "module_ddb" {
  source          = "./terraform/module_ddb"
  stack_base_name = var.stack_base_name
}

module "module_lambda" {
  source                = "./terraform/module_lambda"
  stack_base_name       = var.stack_base_name
  input_users_table_id  = module.module_ddb.users_table_id
  input_users_table_arn = module.module_ddb.users_table_arn
  depends_on            = [module.module_ddb]
}

module "module_api" {
  source                                = "./terraform/module_api"
  stack_base_name                       = var.stack_base_name
  input_lambda_invoke_arn               = module.module_lambda.lambda_invoke_arn
  input_lambda_function_name            = module.module_lambda.lambda_function_name
  input_lambda_authorizer_arn           = module.module_authorizer.authorizer_invoke_arn
  input_lambda_authorizer_function_name = module.module_authorizer.authorizer_function_name
  depends_on                            = [module.module_lambda, module.module_cognito]
}

module "module_cognito" {
  source          = "./terraform/module_cognito"
  stack_base_name = var.stack_base_name
}

module "module_authorizer" {
  source                                = "./terraform/module_authorizer"
  stack_base_name                       = var.stack_base_name
  input_aws_cognito_user_pool_client_id = module.module_cognito.user_pool_client
  input_aws_cognito_user_pool_id        = module.module_cognito.user_pool
  input_aws_cognito_admin_group_name    = module.module_cognito.user_pool_admin_group

  depends_on = [module.module_cognito]
}
