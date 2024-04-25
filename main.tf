
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
  source                     = "./terraform/module_api"
  stack_base_name            = var.stack_base_name
  input_lambda_invoke_arn    = module.module_lambda.lambda_invoke_arn
  input_lambda_function_name = module.module_lambda.lambda_function_name
}

module "module_cognito" {
  source          = "./terraform/module_cognito"
  stack_base_name = var.stack_base_name
}
