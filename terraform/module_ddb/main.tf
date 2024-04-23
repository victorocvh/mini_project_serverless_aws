
resource "aws_dynamodb_table" "users_table" {
  name           = "${var.stack_base_name}_Users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "userid"

  attribute {
    name = "userid"
    type = "S"
  }
}

