
variable "stack_base_name" {
  type    = string
  default = "dev"
}

variable "input_aws_cognito_user_pool_id" {
  type = string
}

variable "input_aws_cognito_user_pool_client_id" {
  type = string
}

variable "input_aws_cognito_admin_group_name" {
  type = string
}
