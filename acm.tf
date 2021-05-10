resource "aws_acm_certificate" "cert" {
  count         = var.enable_api_gateway ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags          = merge({ Name = format("%s-%s", var.application_name, "acm certificate") }, { "Lambda Application" = var.application_name }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  count         = var.enable_api_gateway ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
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
