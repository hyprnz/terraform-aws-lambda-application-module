resource "aws_lb_listener_certificate" "alb_listener_cert" {
  listener_arn    = aws_lb_listener.alb_lambda_listener.arn
  certificate_arn = aws_acm_certificate.alb_cert.arn
}

resource "aws_acm_certificate" "alb_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "alb_route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "alb_route53_record_validation" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_route53_record : record.fqdn]
}

resource "aws_route53_record" "alb_route53_A_record" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_alb.alb_lambda.dns_name
    zone_id                = aws_alb.alb_lambda.zone_id
    evaluate_target_health = true
  }
}