
resource "aws_api_gateway_rest_api" "rest_api" {
  name = "${var.stack_base_name}_users_crud"
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Users Crud"
      version = "1.0"
    }
    components = {
      securitySchemes = {
        lambdaTokenAuthorizer = {
          type                         = "apiKey"
          name                         = "Authorization"
          in                           = "header"
          x-amazon-apigateway-authtype = "custom"
          x-amazon-apigateway-authorizer = {
            authorizerUri                = var.input_lambda_authorizer_arn
            authorizerResultTtlInSeconds = 300
            type                         = "token"
          }
        }
      }
    }
    paths = {
      "/users" = {
        get = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        }
        post = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        }
      },
      "/users/{userid}" = {
        put = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        },
        get = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "${var.input_lambda_invoke_arn}"
          }
        },
        delete = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
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

resource "aws_lambda_permission" "allow_apigateway_auth" {
  statement_id  = "AllowFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.input_lambda_authorizer_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*"
}
