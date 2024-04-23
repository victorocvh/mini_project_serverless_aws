
module "module_ddb" {
  source          = "./terraform/module_ddb"
  stack_base_name = var.stack_base_name
}
