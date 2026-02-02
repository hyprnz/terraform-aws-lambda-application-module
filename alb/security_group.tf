resource "aws_security_group" "alb_lambda_access" {
  name        = "${var.application_loadbalancer_name}-alb_lambda_access"
  description = "Access for ALB"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "egress_default_ipv4" {
  security_group_id = aws_security_group.alb_lambda_access.id
  description       = "Allow IPV4 HTTPS to Lambda Targets"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "egress_default_ipv6" {
  security_group_id = aws_security_group.alb_lambda_access.id
  description       = "Allow IPV6 HTTPS to Lambda Targets"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv6         = "::/0"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_default_ipv4" {
  security_group_id = aws_security_group.alb_lambda_access.id
  description       = "Allow IPV4 HTTPS from public"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_default_ipv6" {
  security_group_id = aws_security_group.alb_lambda_access.id
  description       = "Allow IPV6 HTTPS from public"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv6         = "::/0"
}
