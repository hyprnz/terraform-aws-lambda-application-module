provider "aws" {
  region = "us-west-2"
}

variables {
  application_name                = "test-lambda-app"
  application_runtime            = "nodejs18.x"
  application_version            = "1.0.0"
  artifact_bucket                = "test-artifact-bucket"
  artifact_bucket_key            = "test-app.zip"
  enable_api_gateway             = true

  lambda_functions_config = {
    api = {
      handler     = "api/index.handler"
      enable_vpc  = false
      description = "API handler function"
    }
  }

  api_gateway_route_config = {
    api = {
      methods = ["GET", "POST"]
      operation_name = "ApiHandler"
    }
  }

  tags = {
    Environment = "test"
    Project     = "lambda-app"
  }
}

run "api_gateway_creation" {
  command = plan

  assert {
    condition     = length(aws_apigatewayv2_api.this) > 0
    error_message = "API Gateway v2 should be created when enable_api_gateway is true"
  }

  assert {
    condition     = aws_apigatewayv2_api.this[0].name == "test-lambda-app"
    error_message = "API Gateway should have correct name"
  }

  assert {
    condition     = aws_apigatewayv2_api.this[0].protocol_type == "HTTP"
    error_message = "API Gateway should use HTTP protocol"
  }
}

run "api_gateway_stage" {
  command = plan

  assert {
    condition     = length(aws_apigatewayv2_stage.default) > 0
    error_message = "API Gateway stage should be created"
  }

  assert {
    condition     = aws_apigatewayv2_stage.default[0].name == "$default"
    error_message = "API Gateway stage should use $default name"
  }

  assert {
    condition     = aws_apigatewayv2_stage.default[0].auto_deploy == true
    error_message = "API Gateway stage should have auto_deploy enabled"
  }
}

run "api_gateway_integration" {
  command = plan

  assert {
    condition     = length(aws_apigatewayv2_integration.lambda) > 0
    error_message = "API Gateway integration should be created"
  }

  assert {
    condition = alltrue([
      for integration in aws_apigatewayv2_integration.lambda : integration.integration_type == "AWS_PROXY"
    ])
    error_message = "API Gateway integrations should use AWS_PROXY type"
  }

  assert {
    condition = alltrue([
      for integration in aws_apigatewayv2_integration.lambda : integration.integration_method == "POST"
    ])
    error_message = "API Gateway integrations should use POST method"
  }
}

run "api_gateway_routes" {
  command = plan

  assert {
    condition     = length(aws_apigatewayv2_route.lambda) > 0
    error_message = "API Gateway routes should be created"
  }

  assert {
    condition = alltrue([
      for route in aws_apigatewayv2_route.lambda : contains(["GET", "POST"], split(" ", route.route_key)[0])
    ])
    error_message = "API Gateway routes should have correct HTTP methods"
  }
}

run "api_gateway_disabled" {
  variables {
    enable_api_gateway = false
  }

  command = plan

  assert {
    condition     = length(aws_apigatewayv2_api.this) == 0
    error_message = "API Gateway should not be created when disabled"
  }

  assert {
    condition     = length(aws_apigatewayv2_stage.default) == 0
    error_message = "API Gateway stage should not be created when disabled"
  }

  assert {
    condition     = length(aws_apigatewayv2_integration.lambda) == 0
    error_message = "API Gateway integrations should not be created when disabled"
  }
}

run "api_gateway_cors_configuration" {
  variables {
    api_gateway_cors_configuration = {
      allow_credentials = false
      allow_headers     = ["Content-Type", "Authorization"]
      allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
      allow_origins     = ["*"]
      expose_headers    = []
      max_age          = 300
    }
  }

  command = plan

  assert {
    condition     = length(aws_apigatewayv2_api.this[0].cors_configuration) > 0
    error_message = "API Gateway should have CORS configuration when specified"
  }

  assert {
    condition     = aws_apigatewayv2_api.this[0].cors_configuration[0].allow_credentials == false
    error_message = "CORS should have correct allow_credentials setting"
  }

  assert {
    condition     = contains(aws_apigatewayv2_api.this[0].cors_configuration[0].allow_methods, "GET")
    error_message = "CORS should allow GET method"
  }
}

run "api_gateway_custom_domain" {
  variables {
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  command = plan

  assert {
    condition     = length(aws_apigatewayv2_domain_name.api_gateway_domain) > 0
    error_message = "Custom domain should be created when configured"
  }

  assert {
    condition     = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name == "api.example.com"
    error_message = "Custom domain should have correct domain name"
  }

  assert {
    condition     = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name_configuration[0].endpoint_type == "REGIONAL"
    error_message = "Custom domain should use REGIONAL endpoint"
  }

  assert {
    condition     = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name_configuration[0].security_policy == "TLS_1_2"
    error_message = "Custom domain should enforce TLS 1.2"
  }
}

run "api_gateway_route53_record" {
  variables {
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  command = plan

  assert {
    condition     = length(aws_route53_record.api_gateway_live) > 0
    error_message = "Route53 record should be created for custom domain"
  }

  assert {
    condition     = aws_route53_record.api_gateway_live[0].type == "A"
    error_message = "Route53 record should be type A"
  }

  assert {
    condition     = length(aws_route53_record.api_gateway_live[0].alias) > 0
    error_message = "Route53 record should have alias configuration"
  }
}

run "api_gateway_mapping" {
  variables {
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  command = plan

  assert {
    condition     = length(aws_apigatewayv2_api_mapping.this) > 0
    error_message = "API mapping should be created for custom domain"
  }
}

run "api_gateway_log_group" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_log_group.api_gateway_log_group) > 0
    error_message = "CloudWatch log group should be created for API Gateway"
  }

  assert {
    condition     = aws_cloudwatch_log_group.api_gateway_log_group[0].name == "/aws/apigateway/test-lambda-app"
    error_message = "API Gateway log group should have correct name"
  }
}

run "api_gateway_payload_format" {
  variables {
    api_gateway_payload_format_version = "2.0"
  }

  command = plan

  assert {
    condition = alltrue([
      for integration in aws_apigatewayv2_integration.lambda : integration.payload_format_version == "2.0"
    ])
    error_message = "API Gateway integrations should use specified payload format version"
  }
}


