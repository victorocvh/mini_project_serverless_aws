
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
