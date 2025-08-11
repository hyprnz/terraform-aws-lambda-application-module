
resource "aws_lb_target_group" "alb_ingress" {
  for_each = var.alb_ingress_config

  name        = "${each.value.target_group_name}"
  target_type = "lambda"
}

resource "aws_lambda_permission" "alb_ingress" {
  for_each    = var.alb_ingress_config

  statement_id  = "AllowLambdaExecutionFromAlbIngress"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_application["${each.key}"].arn
  qualifier     = aws_lambda_alias.lambda_application_alias["${each.key}"].name

  principal  = "elasticloadbalancing.amazonaws.com"
  source_arn = aws_lb_target_group.alb_ingress["${each.key}"].arn
}

resource "aws_lb_target_group_attachment" "alb_ingress" {
  for_each = var.alb_ingress_config

  target_group_arn = aws_lb_target_group.alb_ingress["${each.key}"].arn
  target_id        = aws_lambda_alias.lambda_application_alias["${each.key}"].arn
  depends_on       = [aws_lambda_permission.alb_ingress]
}

resource "aws_lb_listener_rule" "alb_ingress" {
  for_each = var.alb_ingress_config

  listener_arn = var.alb_ingress_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ingress["${each.key}"].arn
  }

  condition {
    path_pattern {
      values = ["${each.value.target_group_path}"]
    }
  }
}