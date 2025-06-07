resource "aws_api_gateway_resource" "ret_proxy" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  parent_id   = aws_api_gateway_rest_api.main_rest_api.root_resource_id
  path_part   = var.ret_path
}

resource "aws_api_gateway_method" "ret_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main_rest_api.id
  resource_id   = aws_api_gateway_resource.ret_proxy.id
  http_method   = var.get_http_method
  authorization = var.auth_none
}

resource "aws_api_gateway_integration" "ret_lambda" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  resource_id = aws_api_gateway_method.ret_proxy.resource_id
  http_method = aws_api_gateway_method.ret_proxy.http_method

  integration_http_method = var.post_http_method
  type                    = var.proxy
  uri                     = aws_lambda_function.retrieve_lambda.invoke_arn
}


resource "aws_api_gateway_method" "ret_cors_options" {
  rest_api_id   = aws_api_gateway_rest_api.main_rest_api.id
  resource_id   = aws_api_gateway_resource.ret_proxy.id
  http_method   = local.cors_options_method_values.http_method
  authorization = local.cors_options_method_values.authorization
}

resource "aws_api_gateway_integration" "ret_cors_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  resource_id = aws_api_gateway_resource.ret_proxy.id
  http_method = aws_api_gateway_method.ret_cors_options.http_method
  type        = var.type_mock

  request_templates = local.cors_request_template
}

resource "aws_api_gateway_integration_response" "ret_cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  resource_id = aws_api_gateway_resource.ret_proxy.id
  http_method = aws_api_gateway_method.ret_cors_options.http_method
  status_code = var.status_code

  response_parameters = local.cors_response_headers
  depends_on          = [aws_api_gateway_integration.ret_cors_integration]
}

resource "aws_api_gateway_method_response" "ret_cors_method_response" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  resource_id = aws_api_gateway_resource.ret_proxy.id
  http_method = aws_api_gateway_method.ret_cors_options.http_method
  status_code = var.status_code

  response_models     = local.empty_json_response_model
  response_parameters = local.cors_method_response_parameters
}

resource "aws_lambda_permission" "ret_apigw" {
  statement_id  = var.lambda_api_permission_id
  action        = var.lambda_api_action
  function_name = aws_lambda_function.retrieve_lambda.function_name
  principal     = var.lambda_api_principal

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.main_rest_api.execution_arn}/*/*"
}