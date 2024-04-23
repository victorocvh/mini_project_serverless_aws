
output "users_table_id" {
  value = aws_dynamodb_table.users_table.id
}

output "users_table_arn" {
  value = aws_dynamodb_table.users_table.arn
}
