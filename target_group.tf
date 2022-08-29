resource "aws_lb_target_group" "alb_lambda_target_group" {
  #  TODO: test when enable_load_balancer is true
  count       = var.enable_load_balancer ? 1 : 0
  name        = var.service_target_group_name
  target_type = "lambda"
}

resource "aws_lambda_permission" "alb_lambda_permission" {
  #  TODO: test when enable_load_balancer is true
  count         = var.enable_load_balancer ? 1 : 0
  statement_id  = "AllowLambdaExecutionFromAlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.lambda_application_alias["${var.lambda_alb_config.function_key}"].arn

  principal  = "elasticloadbalancing.amazonaws.com"
  source_arn = aws_lb_target_group.alb_lambda_target_group[0].arn
}

resource "aws_lb_target_group_attachment" "alb_lambda_target_group_attachment" {
  #  TODO: test when enable_load_balancer is true
  count            = var.enable_load_balancer ? 1 : 0
  target_group_arn = aws_lb_target_group.alb_lambda_target_group[0].arn
  target_id        = aws_lambda_alias.lambda_application_alias["${var.lambda_alb_config.function_key}"].arn
  depends_on       = [aws_lambda_permission.alb_lambda_permission]
}

resource "aws_lb_listener_rule" "alb_lambda_listener_rule" {
  #  TODO: test when enable_load_balancer is true
  count        = var.enable_load_balancer ? 1 : 0
  listener_arn = var.alb_lambda_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_lambda_target_group[0].arn
  }

  condition {
    path_pattern {
      values = ["/${var.service_target_group_path}/*"]
    }
  }
  tags = merge({ Name = format("%s-%s", var.application_name, "alb_lambda") }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}