provider "aws" {
  region = "us-west-2"
}

# Common variables for all tests
variables {
  application_name    = "test-lambda-app"
  application_runtime = "python3.9"
  application_version = "v1.0.0"

  lambda_functions_config = {
    api = {
      handler    = "app.handler"
      enable_vpc = false
    }
    worker = {
      handler    = "worker.handler"
      enable_vpc = false
    }
  }

  artifact_bucket     = "test-artifact-bucket"
  artifact_bucket_key = "test-app.zip"

  tags = {
    Environment = "test"
    Project     = "lambda-app"
  }
}

# Test case 1: ALB ingress disabled (default)
run "verify_no_resources_when_disabled" {
  command = plan

  assert {
    condition     = length(aws_lb_target_group.alb_ingress) == 0
    error_message = "No target groups should be created when alb_ingress_config is empty"
  }

  assert {
    condition     = length(aws_lambda_permission.alb_ingress) == 0
    error_message = "No lambda permissions should be created when alb_ingress_config is empty"
  }

  assert {
    condition     = length(aws_lb_target_group_attachment.alb_ingress) == 0
    error_message = "No target group attachments should be created when alb_ingress_config is empty"
  }

  assert {
    condition     = length(aws_lb_listener_rule.alb_ingress) == 0
    error_message = "No listener rules should be created when alb_ingress_config is empty"
  }
}

# Test case 2: Single ALB ingress configuration
run "verify_single_alb_ingress_config" {
  command = plan

  variables {
    alb_ingress_listener_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/app/my-alb/1234567890123456/1234567890123456"
    alb_ingress_config = {
      api = {
        target_group_name = "test-api-tg"
        target_group_path = "/api/*"
      }
    }
  }

  assert {
    condition     = length(aws_lb_target_group.alb_ingress) == 1
    error_message = "One target group should be created"
  }

  assert {
    condition     = aws_lb_target_group.alb_ingress["api"].name == "test-api-tg"
    error_message = "Target group name should match configuration"
  }

  assert {
    condition     = aws_lb_target_group.alb_ingress["api"].target_type == "lambda"
    error_message = "Target group should be configured for lambda targets"
  }
}

# Test case 3: Multiple ALB ingress configurations
run "verify_multiple_alb_ingress_configs" {
  command = plan

  variables {
    alb_ingress_listener_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/app/my-alb/1234567890123456/1234567890123456"
    alb_ingress_config = {
      api = {
        target_group_name = "test-api-tg"
        target_group_path = "/api/*"
      }
      worker = {
        target_group_name = "test-worker-tg"
        target_group_path = "/worker/*"
      }
    }
  }

  assert {
    condition     = length(aws_lb_target_group.alb_ingress) == 2
    error_message = "Two target groups should be created"
  }

  assert {
    condition     = length(aws_lambda_permission.alb_ingress) == 2
    error_message = "Two lambda permissions should be created"
  }

  assert {
    condition     = length(aws_lb_target_group_attachment.alb_ingress) == 2
    error_message = "Two target group attachments should be created"
  }

  assert {
    condition     = length(aws_lb_listener_rule.alb_ingress) == 2
    error_message = "Two listener rules should be created"
  }
}

# Test case 4: Lambda permissions configuration
run "verify_lambda_permissions" {
  command = plan

  variables {
    alb_ingress_listener_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/app/my-alb/1234567890123456/1234567890123456"
    alb_ingress_config = {
      api = {
        target_group_name = "test-api-tg"
        target_group_path = "/api/*"
      }
    }
  }

  assert {
    condition     = aws_lambda_permission.alb_ingress["api"].statement_id == "AllowLambdaExecutionFromAlbIngress"
    error_message = "Lambda permission should have correct statement ID"
  }

  assert {
    condition     = aws_lambda_permission.alb_ingress["api"].action == "lambda:InvokeFunction"
    error_message = "Lambda permission should allow InvokeFunction action"
  }

  assert {
    condition     = aws_lambda_permission.alb_ingress["api"].principal == "elasticloadbalancing.amazonaws.com"
    error_message = "Lambda permission should be from ELB principal"
  }
}

# Test case 5: Listener rule configuration
run "verify_listener_rules" {
  command = plan

  variables {
    alb_ingress_listener_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/app/my-alb/1234567890123456/1234567890123456"
    alb_ingress_config = {
      api = {
        target_group_name = "test-api-tg"
        target_group_path = "/api/*"
      }
      worker = {
        target_group_name = "test-worker-tg"
        target_group_path = "/worker/*"
      }
    }
  }

  assert {
    condition = alltrue([
      for rule in aws_lb_listener_rule.alb_ingress : rule.listener_arn == var.alb_ingress_listener_arn
    ])
    error_message = "All listener rules should reference the correct listener ARN"
  }

  assert {
    condition = alltrue([
      for rule in aws_lb_listener_rule.alb_ingress : alltrue([
        for action in rule.action : action.type == "forward"
      ])
    ])
    error_message = "All listener rules should have forward action type"
  }

  assert {
    condition = alltrue([
      for condition in aws_lb_listener_rule.alb_ingress["api"].condition :
      alltrue([
        for path_pattern in condition.path_pattern :
        contains(path_pattern.values, "/api/*")
      ])
    ])
    error_message = "API listener rule should have correct path pattern"
  }

  assert {
    condition = alltrue([
      for condition in aws_lb_listener_rule.alb_ingress["worker"].condition :
      alltrue([
        for path_pattern in condition.path_pattern :
        contains(path_pattern.values, "/worker/*")
      ])
    ])
    error_message = "Worker listener rule should have correct path pattern"
  }
}

# Test case 6: Target group attachments
run "verify_target_group_attachments" {
  command = plan

  variables {
    alb_ingress_listener_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/app/my-alb/1234567890123456/1234567890123456"
    alb_ingress_config = {
      api = {
        target_group_name = "test-api-tg"
        target_group_path = "/api/*"
      }
    }
  }
}

# Test case 7: No listener ARN provided
run "verify_missing_listener_arn" {
  command = plan

  variables {
    alb_ingress_config = {
      api = {
        target_group_name = "test-api-tg"
        target_group_path = "/api/*"
      }
    }
  }

  assert {
    condition = alltrue([
      for rule in aws_lb_listener_rule.alb_ingress : rule.listener_arn == ""
    ])
    error_message = "Listener rules should use empty listener ARN when not provided"
  }
}

# Test case 8: Minimal target group path
run "verify_minimal_target_group_path" {
  command = plan

  variables {
    alb_ingress_listener_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/app/my-alb/1234567890123456/1234567890123456"
    alb_ingress_config = {
      api = {
        target_group_name = "test-api-tg"
        target_group_path = "/"
      }
    }
  }

  assert {
    condition = alltrue([
      for condition in aws_lb_listener_rule.alb_ingress["api"].condition :
      alltrue([
        for path_pattern in condition.path_pattern :
        contains(path_pattern.values, "/")
      ])
    ])
    error_message = "Listener rule should accept minimal path pattern '/'"
  }
}
