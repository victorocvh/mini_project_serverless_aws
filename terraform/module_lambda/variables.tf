
variable "stack_base_name" {
  type    = string
  default = "dev"
}

variable "input_users_table_id" {
  type        = string
  description = "Módulo lambda precisa receber o ID da tabela do DynamoDB no qual ele vai interagir"
}

variable "input_users_table_arn" {
  type        = string
  description = "Módulo lambda precisa receber o ARN da tabela do DynamoDB no qual ele vai interagir"
}
