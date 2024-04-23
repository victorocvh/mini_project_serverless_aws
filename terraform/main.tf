terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.46.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "serveless_aws" {
  name           = "serveless-aws"
  billing_mode   = "PROVISIONED"
  read_capacity  = 25
  write_capacity = 25
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }
}

data "aws_iam_policy_document" "create_user" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "create_user" {
  name               = "iam_create_user"
  assume_role_policy = data.aws_iam_policy_document.create_user.json
}

data "aws_iam_policy_document" "create_user_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    resources = ["arn:aws:dynamodb:us-east-1:767398079178:table/serveless-aws"]
  }
}

resource "aws_iam_policy" "create_user" {
  name        = "create-user-policy"
  description = "Policy to allow create user na tabela dynamodb."
  policy      = data.aws_iam_policy_document.create_user_permissions.json
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  role       = aws_iam_role.create_user.name
  policy_arn = aws_iam_policy.create_user.arn

  depends_on = [
    aws_iam_role.create_user,
    aws_iam_policy.create_user
  ]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.cwd}/../src/m1-add-sample-data.py"
  output_path = "${path.cwd}/../src/m1-add-sample-data.zip"
}

resource "aws_lambda_function" "create_user" {
  filename      = "${path.cwd}/../src/m1-add-sample-data.zip"
  function_name = "create_user"
  role          = aws_iam_role.create_user.arn
  handler       = "m1-add-sample-data.lambda_handler"
  architectures = ["x86_64"]
  runtime       = "python3.11"

  source_code_hash = data.archive_file.lambda.output_base64sha256
}

data "archive_file" "lambda_getusers" {
  type        = "zip"
  source_file = "${path.cwd}/../src/m1-get-users.py"
  output_path = "${path.cwd}/../src/m1-get-users.zip"
}

resource "aws_lambda_function" "get_users" {
  filename      = "${path.cwd}/../src/m1-get-users.zip"
  function_name = "get_users"
  role          = aws_iam_role.create_user.arn
  handler       = "m1-get-users.lambda_handler"
  architectures = ["x86_64"]
  runtime       = "python3.11"

  source_code_hash = data.archive_file.lambda.output_base64sha256
}
