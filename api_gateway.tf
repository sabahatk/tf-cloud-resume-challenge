resource "aws_api_gateway_rest_api" "main_rest_api" {
  name        = var.rest_api_name
  description = var.rest_api_desc
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  parent_id   = aws_api_gateway_rest_api.main_rest_api.root_resource_id
  path_part   = var.upd_path
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = var.any_http_method
  authorization = var.auth_none
}

resource "aws_api_gateway_method" "cors_options" {
  rest_api_id   = aws_api_gateway_rest_api.main_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = local.cors_options_method_values.http_method
  authorization = local.cors_options_method_values.authorization
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.cors_options.http_method
  type        = var.type_mock

  request_templates = local.cors_request_template
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.cors_options.http_method
  status_code = var.status_code

  response_parameters = local.cors_response_headers
  depends_on          = [aws_api_gateway_integration.cors_integration]
}

resource "aws_api_gateway_method_response" "cors_method_response" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.cors_options.http_method
  status_code = var.status_code

  response_models     = local.empty_json_response_model
  response_parameters = local.cors_method_response_parameters
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = var.post_http_method
  type                    = var.proxy
  uri                     = aws_lambda_function.update_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "upd_api_deploy" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.ret_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.main_rest_api.id
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.upd_api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.main_rest_api.id
  stage_name    = var.stage
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = var.lambda_api_permission_id
  action        = var.lambda_api_action
  function_name = aws_lambda_function.update_lambda.function_name
  principal     = var.lambda_api_principal

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.main_rest_api.execution_arn}/*/*"
}

resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name     = var.api_domain
  certificate_arn = aws_acm_certificate.api_cert.arn
  endpoint_configuration {
    types = var.endpoint_configuration_type
  }
  depends_on = [aws_acm_certificate.api_cert, aws_acm_certificate_validation.api_cert_valid]
}

resource "aws_api_gateway_base_path_mapping" "upd_mapping" {
  api_id      = aws_api_gateway_rest_api.main_rest_api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain.domain_name
}
