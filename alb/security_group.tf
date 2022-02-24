resource "aws_security_group" "alb_lambda_access" {
  name        =  "${var.application_loadbalancer_name}-alb_lambda_access"
  description = "Access for ALB"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   tags = merge({ Name = var.application_loadbalancer_name }, var.tags)
}

resource "aws_security_group_rule" "alb_lambda_access_https" {
  description              = "Allow HTTPS inbound traffic"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_lambda_access.id 
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  to_port                  = 443
  type                     = "ingress"
}