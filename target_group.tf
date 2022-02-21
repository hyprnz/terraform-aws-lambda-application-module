resource "aws_lb_target_group" "alb_lambda_target_group" {
  name        = var.service_target_group_name
  target_type = "lambda"
}

resource "aws_lambda_permission" "alb_lambda_permission" {
  statement_id  = "AllowLambdaExecutionFromAlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.lambda_application_alias["${var.lambda_alb_config.function_key}"].arn

  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.alb_lambda_target_group.arn
}

resource "aws_lb_target_group_attachment" "alb_lambda_target_group_attachment" {
  target_group_arn = aws_lb_target_group.alb_lambda_target_group.arn
  target_id        = aws_lambda_alias.lambda_application_alias["${var.lambda_alb_config.function_key}"].arn
  depends_on       = [aws_lambda_permission.alb_lambda_permission]
}

resource "aws_lb_listener_rule" "alb_lambda_listener_rule" {
  listener_arn = var.alb_lambda_listener_arn
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_lambda_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/${var.service_target_group_name}/*"]
    }
  }
  tags  = merge({ Name = format("%s-%s", var.application_name, "alb_lambda_listener_rule") }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}