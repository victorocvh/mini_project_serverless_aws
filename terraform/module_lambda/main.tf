

data "archive_file" "usersfn_lambda_zip" {
  type        = "zip"
  output_path = "./tmp/usersfunctions_lambda.zip"
  source_file = "${path.module}/../../src/users/lambda_function.py"
}

data "aws_iam_policy_document" "users_lambda_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "users_lambda_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable",
      "dynamodb:ConditionCheckItem"
    ]
    resources = ["${var.input_users_table_arn}"]
  }
  statement {
    actions   = ["logs:*", "xray:*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "users_lambda_policy" {
  name        = "${var.stack_base_name}_users_lambda_policy"
  description = "Policy that allow users lambda to interact with others services."
  policy      = data.aws_iam_policy_document.users_lambda_permissions.json
}

resource "aws_iam_role" "users_lambda" {
  name               = "${var.stack_base_name}_users_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.users_lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "users_lambda" {
  role       = aws_iam_role.users_lambda.name
  policy_arn = aws_iam_policy.users_lambda_policy.arn
}

resource "aws_lambda_function" "users_lambda" {
  function_name = "${var.stack_base_name}_user_lambda"
  filename      = data.archive_file.usersfn_lambda_zip.output_path
  description   = "All users operation (GET,POST,UPDATE,DELETE)"
  role          = aws_iam_role.users_lambda.arn
  handler       = "lambda_function.lambda_handler"
  architectures = ["x86_64"]
  runtime       = "python3.11"

  source_code_hash = data.archive_file.usersfn_lambda_zip.output_base64sha256
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      USERS_TABLE = "${var.input_users_table_id}"
    }
  }

}
