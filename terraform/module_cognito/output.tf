
output "user_pool" {
  value = aws_cognito_user_pool.cognito.id
}

output "user_pool_client" {
  value = aws_cognito_user_pool_client.cognito.id
}

output "user_pool_admin_group" {
  value = aws_cognito_user_group.cognito.name
}

output "cognito_login_url" {
  value = "https://${aws_cognito_user_pool_domain.cognito.domain}.auth.us-east-1.amazoncognito.com"
}

output "cognito_login_auth_command" {
  value = "aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH --client-id ${aws_cognito_user_pool_client.cognito.id} --region us-east-1 --auth-parameters USERNAME=<user@example.com>,PASSWORD=<password>"
}
