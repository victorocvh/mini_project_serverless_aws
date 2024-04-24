
variable "stack_base_name" {
  type    = string
  default = "dev"
}

variable "input_lambda_invoke_arn" {
  type        = string
  description = "Lambda URL that will be called by api-gateway."
}

variable "input_lambda_function_name" {
  type        = string
  description = "Lambda Name that will be called by api-gateway"
}
