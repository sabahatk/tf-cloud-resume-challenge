variable "region_name" {
  type    = string
  default = "us-east-1"
}

variable "s3_bucket_names" {
  type = list(string)
  default = ["sabahatresume.com",
    "www.sabahatresume.com"
  ]
}

variable "rootdomain" {
  type    = string
  default = "sabahatresume.com"
}

variable "subdomain" {
  type    = string
  default = "www.sabahatresume.com"
}

variable "api_domain" {
  type    = string
  default = "api.sabahatresume.com"
}

variable "s3_objects" {
  type    = set(string)
  default = ["index.html", "styles.css", "index.js", "error.html", "favicon.ico"]
}

variable "cf_hosted_zone" {
  type    = string
  default = "Z2FDTNDATAQYW2"
}

variable "table_name" {
  type    = string
  default = "VisitCounterDB"
}

variable "table_id" {
  type    = string
  default = "counter-id"
}

variable "rest_api_name" {
  type    = string
  default = "APILambdaTrigger"
}

variable "rest_api_desc" {
  type    = string
  default = "Terraform API Trigger"
}

variable "upd_path" {
  type    = string
  default = "update"
}

variable "ret_path" {
  type    = string
  default = "retrieve"
}

variable "any_http_method" {
  type    = string
  default = "ANY"
}

variable "options_http_method" {
  type    = string
  default = "OPTIONS"
}

variable "post_http_method" {
  type    = string
  default = "POST"
}

variable "get_http_method" {
  type    = string
  default = "GET"
}

variable "proxy" {
  type    = string
  default = "AWS_PROXY"
}

variable "auth_none" {
  type    = string
  default = "NONE"
}

variable "type_mock" {
  type    = string
  default = "MOCK"
}

variable "status_code" {
  type    = string
  default = "200"
}

variable "stage" {
  type    = string
  default = "prod"
}

variable "lambda_api_permission_id" {
  type    = string
  default = "AllowAPIGatewayInvoke"
}

variable "lambda_api_action" {
  type    = string
  default = "lambda:InvokeFunction"
}

variable "lambda_api_principal" {
  type    = string
  default = "apigateway.amazonaws.com"
}

variable "endpoint_configuration_type" {
  type    = list(string)
  default = ["EDGE"]
}

variable "route53_type" {
  type    = string
  default = "A"
}

variable "valid_DNS" {
  type    = string
  default = "DNS"
}

variable "key_alg" {
  type    = string
  default = "RSA_2048"
}

variable "item_type" {
  type    = string
  default = "S"
}

variable "origin_name" {
  type    = string
  default = "S3 Origin"
}

variable "origin_type" {
  type    = string
  default = "s3"
}

variable "signing_behavior" {
  type    = string
  default = "always"
}

variable "signing_protocol" {
  type    = string
  default = "sigv4"
}

variable "origin_id" {
  type    = string
  default = "myS3Origin"
}

variable "allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "HTML_file" {
  type    = string
  default = "index.html"
}

variable "error_HTML_file" {
  type    = string
  default = "index.html"
}

variable "redirect_policy" {
  type    = string
  default = "redirect-to-https"
}

variable "restriction_type" {
  type    = string
  default = "whitelist"
}

variable "location_list" {
  type    = list(string)
  default = ["US", "CA", "GB", "DE"]
}

variable "ssl_support_method" {
  type    = string
  default = "sni-only"
}

variable "cache_policy_id" {
  type    = string
  default = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #Disable Caching
}

variable "min_ttl" {
  type    = number
  default = 0
}

variable "default_ttl" {
  type    = number
  default = 3600
}

variable "max_ttl" {
  type    = number
  default = 86400
}

variable "true" {
  type    = bool
  default = true
}

variable "false" {
  type    = bool
  default = false
}

variable "allow" {
  type    = string
  default = "Allow"
}

variable "principal_type" {
  type    = string
  default = "Service"
}

variable "principal_identifier" {
  type    = list(string)
  default = ["lambda.amazonaws.com"]
}

variable "actions" {
  type    = list(string)
  default = ["sts:AssumeRole"]
}

variable "lambda_upd_role_name" {
  type    = string
  default = "upd_iam_for_lambda"
}

variable "lambda_ret_role_name" {
  type    = string
  default = "ret_iam_for_lambda"
}

variable "lambda_upd_policy_name" {
  type    = string
  default = "lambda_upd_policy"
}

variable "lambda_ret_policy_name" {
  type    = string
  default = "lambda_ret_policy"
}

variable "archive_type" {
  type    = string
  default = "zip"
}

variable "upd_output_path" {
  type    = string
  default = "lambda_function_upd_src.zip"
}

variable "ret_output_path" {
  type    = string
  default = "lambda_function_ret_src.zip"
}

variable "upd_function_name" {
  type    = string
  default = "visitor_counter_update_item"
}

variable "ret_function_name" {
  type    = string
  default = "visitor_counter_retrieve_item"
}

variable "upd_lambda_handler" {
  type    = string
  default = "lambda_visitor_counter.lambda_handler"
}

variable "ret_lambda_handler" {
  type    = string
  default = "lambda_visitor_counter_retrieve_item.lambda_handler"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.10"
}

variable "lambda_timeout" {
  type    = string
  default = "20"
}

variable "s3_redirect_protocol" {
  type    = string
  default = "https"
}

variable "forward_none" {
  type    = string
  default = "none"
}
#### Locals #####

locals {
  # Commonly allowed headers for browser-based fetch requests
  cors_response_headers = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  # Method response parameters must match headers in integration response
  cors_method_response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  # Method properties for all OPTIONS methods
  cors_options_method_values = {
    http_method   = "OPTIONS"
    authorization = "NONE"
  }

  # Reusable response model (Empty for mock response)
  empty_json_response_model = {
    "application/json" = "Empty"
  }

  # Simple MOCK integration that returns a 200 status
  cors_request_template = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

locals {
  lambda_upd_policy_code = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:UpdateItem",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.basic-dynamodb-table.arn
      },
    ]
  })

  lambda_ret_policy_code = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.basic-dynamodb-table.arn
      },
    ]
  })
}

locals {
  s3_root_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "s3:GetObject",
        "Effect" : "Allow",
        "Resource" : "${aws_s3_bucket.root_bucket.arn}/*",
        "Principal" : {
          Service = "cloudfront.amazonaws.com"
        }
        Condition : {
          StringEquals : {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_root_distribution.arn
          }
        }
      }
    ]
  })

  s3_sub_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "s3:GetObject",
        "Effect" : "Allow",
        "Resource" : "${aws_s3_bucket.sub_bucket.arn}/*",
        "Principal" : {
          Service = "cloudfront.amazonaws.com"
        }
        Condition : {
          StringEquals : {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_sub_distribution.arn
          }
        }
      }
    ]
  })


}