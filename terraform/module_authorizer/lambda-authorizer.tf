data "aws_iam_policy_document" "authorizer_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "authorizer" {
  name               = "${var.stack_base_name}_AuthorizerRole"
  assume_role_policy = data.aws_iam_policy_document.authorizer_assume.json

  depends_on = [data.aws_iam_policy_document.authorizer_assume]
}

resource "aws_lambda_function" "authorizer" {
  function_name    = "${var.stack_base_name}_authorizer"
  role             = aws_iam_role.authorizer.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  architectures    = ["x86_64"]
  filename         = "${path.module}/../../src/authorizer/package.zip"
  source_code_hash = filebase64sha256("${path.module}/../../src/authorizer/package.zip")

  environment {
    variables = {
      "USER_POOL_ID"          = "${var.input_aws_cognito_user_pool_id}"
      "APPLICATION_CLIENT_ID" = "${var.input_aws_cognito_user_pool_client_id}"
      "ADMIN_GROUP_NAME"      = "${var.input_aws_cognito_admin_group_name}"
    }
  }
}

data "aws_iam_policy_document" "authorizer_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["xray:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }

  depends_on = [aws_lambda_function.authorizer]
}

resource "aws_iam_policy" "authorizer_permissions" {
  name        = "${var.stack_base_name}_AuthorizerPolicyPermissions"
  policy      = data.aws_iam_policy_document.authorizer_permissions.json
  description = "Authorizer Permissions"
}

resource "aws_iam_role_policy_attachment" "authorizer_permissions" {
  role       = aws_iam_role.authorizer.name
  policy_arn = aws_iam_policy.authorizer_permissions.arn
}
