
resource "aws_api_gateway_rest_api" "rest_api" {
  name = "${var.stack_base_name}_users_crud"
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Users Crud"
      version = "1.0"
    }
    paths = {
      "/users" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        }
        put = {
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        }
      },
      "/users/{userid}" = {
        put = {
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        },
        get = {
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        },
        delete = {
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "rest_api" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    "redeployment" = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "rest_api" {
  stage_name           = "Dev"
  xray_tracing_enabled = true
  deployment_id        = aws_api_gateway_deployment.rest_api.id
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.input_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*"
}
