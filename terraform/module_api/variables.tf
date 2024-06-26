
variable "stack_base_name" {
  type    = string
  default = "dev"
}

variable "user_pool_admin_group_name" {
  default = "dev_AdminGroupName"
}

variable "input_lambda_invoke_arn" {
  type        = string
  description = "Lambda URL that will be called by api-gateway."
}

variable "input_lambda_function_name" {
  type        = string
  description = "Lambda Name that will be called by api-gateway"
}

variable "input_lambda_authorizer_arn" {
  type        = string
  description = "ARN para o Authorizer Lambda."
}

variable "input_lambda_authorizer_function_name" {
  type        = string
  description = "Function Name for API Gateway Authorizer!"
}
