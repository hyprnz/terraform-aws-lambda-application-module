resource "aws_lb_listener" "alb_lambda_listener" {
  load_balancer_arn = aws_alb.alb_lambda.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate_validation.alb_route53_record_validation.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Page not found"
      status_code  = "404"
    }
  }
}