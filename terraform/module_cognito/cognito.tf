
resource "aws_cognito_user_pool" "cognito" {
  name = "${var.stack_base_name}_UsersPool"

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  username_attributes = ["email"]

  auto_verified_attributes = ["email"]
  mfa_configuration        = "OFF"

  tags = {
    Name = "User Pool"
  }

  lifecycle {
    ignore_changes = [schema]
  }
}

resource "aws_cognito_user_pool_client" "cognito" {

  name         = "${var.stack_base_name}_UsersPoolClient"
  user_pool_id = aws_cognito_user_pool.cognito.id
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  supported_identity_providers  = ["COGNITO"]
  generate_secret               = false
  refresh_token_validity        = 30
  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  callback_urls = ["http://localhost"]
  logout_urls   = ["http://localhost"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid"]


}

resource "aws_cognito_user_pool_domain" "cognito" {
  user_pool_id = aws_cognito_user_pool.cognito.id
  domain       = aws_cognito_user_pool_client.cognito.id
}

resource "aws_cognito_user_group" "cognito" {
  user_pool_id = aws_cognito_user_pool.cognito.id
  name         = "${var.stack_base_name}_AdminGroupName"
  description  = "Grupo de usuários para administradores da API!"
  precedence   = 0
}

resource "aws_cognito_user" "cognito_user" {
  user_pool_id = aws_cognito_user_pool.cognito.id
  username     = "admin-noreply@testadmin.com"
  password     = "admin@123M"

  attributes = {
    email          = "admin-noreply@testadmin.com"
    email_verified = true
  }
}

resource "aws_cognito_user_in_group" "cognito_user_in_admin_group" {
  user_pool_id = aws_cognito_user_pool.cognito.id
  group_name   = aws_cognito_user_group.cognito.name
  username     = aws_cognito_user.cognito_user.username
}
