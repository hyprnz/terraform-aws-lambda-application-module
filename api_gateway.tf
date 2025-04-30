locals {
  route_config_list = [for function_config_key, config in var.api_gateway_route_config : {
    for idx, method in config.methods :
    "${method} /${function_config_key}" =>
    merge(config, {
      function_config_key : function_config_key,
      method : method
    route : coalesce(try(config.route, null), "/${function_config_key}/{proxy+}") })
  }]
  route_config       = var.enable_api_gateway ? merge(flatten(local.route_config_list)...) : {}
  integration_config = var.enable_api_gateway ? var.api_gateway_route_config : {}
}

resource "aws_apigatewayv2_api" "this" {
  count         = var.enable_api_gateway ? 1 : 0
  name          = var.application_name
  protocol_type = "HTTP"

  dynamic "cors_configuration" {
    for_each = [var.api_gateway_cors_configuration]

    content {
      allow_credentials = cors_configuration.value.allow_credentials
      allow_headers     = cors_configuration.value.allow_headers
      allow_methods     = cors_configuration.value.allow_methods
      allow_origins     = cors_configuration.value.allow_origins
      expose_headers    = cors_configuration.value.expose_headers
      max_age           = cors_configuration.value.max_age
    }
  }

  tags = local.tags
}

resource "aws_apigatewayv2_stage" "default" {
  count       = var.enable_api_gateway ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group[0].arn
    format = jsonencode(
      {
        httpMethod     = "$context.httpMethod"
        ip             = "$context.identity.sourceIp"
        protocol       = "$context.protocol"
        requestId      = "$context.requestId"
        requestTime    = "$context.requestTime"
        responseLength = "$context.responseLength"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.integration_config

  api_id           = aws_apigatewayv2_api.this[0].id
  integration_type = "AWS_PROXY"
  credentials_arn  = aws_iam_role.api_gateway_execution_role[0].arn

  connection_type      = "INTERNET"
  integration_method   = "POST"
  integration_uri      = aws_lambda_alias.lambda_application_alias[each.key].arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each = local.route_config

  api_id         = aws_apigatewayv2_api.this[0].id
  route_key      = "${each.value.method} ${each.value.route}"
  operation_name = each.value.operation_name

  target = "integrations/${aws_apigatewayv2_integration.lambda[each.value.function_config_key].id}"
}

resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  count = var.enable_api_gateway ? 1 : 0

  name              = format("/aws/apigateway/%s", var.application_name)
  retention_in_days = var.aws_cloudwatch_log_group_retention_in_days

  tags = local.tags
}

resource "aws_apigatewayv2_domain_name" "api_gateway_domain" {
  count       = var.enable_api_gateway && local.enable_custom_domain_name ? 1 : 0
  domain_name = local.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert[0].arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = local.tags

  depends_on = [aws_acm_certificate_validation.cert]
}

resource "aws_route53_record" "api_gateway_live" {
  count   = var.enable_api_gateway && local.enable_custom_domain_name ? 1 : 0
  name    = local.domain_name
  type    = "A"
  zone_id = var.api_gateway_custom_domain_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.enable_api_gateway && local.enable_custom_domain_name ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  domain_name = aws_apigatewayv2_domain_name.api_gateway_domain[0].id
  stage       = aws_apigatewayv2_stage.default[0].id
}