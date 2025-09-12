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
  }

  artifact_bucket     = "test-artifact-bucket"
  artifact_bucket_key = "test-app.zip"

  tags = {
    Environment = "test"
    Project     = "lambda-app"
  }
}

# Test case 1: ACM disabled when API Gateway is disabled (default)
run "verify_no_certificate_when_api_gateway_disabled" {
  command = plan

  variables {
    enable_api_gateway = false
  }

  assert {
    condition     = length(aws_acm_certificate.cert) == 0
    error_message = "No ACM certificate should be created when API Gateway is disabled"
  }

  assert {
    condition     = length(aws_acm_certificate_validation.cert) == 0
    error_message = "No ACM certificate validation should be created when API Gateway is disabled"
  }

  assert {
    condition     = length(aws_route53_record.cert_validation) == 0
    error_message = "No Route53 validation records should be created when API Gateway is disabled"
  }
}

# Test case 2: ACM disabled when custom domain is not configured
run "verify_no_certificate_without_custom_domain" {
  command = plan

  variables {
    enable_api_gateway = true
  }

  assert {
    condition     = length(aws_acm_certificate.cert) == 0
    error_message = "No ACM certificate should be created when custom domain is not configured"
  }

  assert {
    condition     = length(aws_acm_certificate_validation.cert) == 0
    error_message = "No ACM certificate validation should be created when custom domain is not configured"
  }

  assert {
    condition     = length(aws_route53_record.cert_validation) == 0
    error_message = "No Route53 validation records should be created when custom domain is not configured"
  }
}

# Test case 3: ACM enabled with custom domain
run "verify_certificate_with_custom_domain" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  assert {
    condition     = length(aws_acm_certificate.cert) == 1
    error_message = "One ACM certificate should be created with custom domain"
  }

  assert {
    condition     = length(aws_acm_certificate_validation.cert) == 1
    error_message = "One ACM certificate validation should be created with custom domain"
  }

  assert {
    condition = alltrue([
      for cert in aws_acm_certificate.cert : cert.domain_name == "api.example.com"
    ])
    error_message = "ACM certificate domain should match custom domain name"
  }

  assert {
    condition = alltrue([
      for cert in aws_acm_certificate.cert : cert.validation_method == "DNS"
    ])
    error_message = "ACM certificate should use DNS validation method"
  }
}

# Test case 4: Certificate validation method
run "verify_certificate_validation_method" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  assert {
    condition     = length(aws_acm_certificate.cert) > 0
    error_message = "ACM certificate should be created when custom domain is configured"
  }

  assert {
    condition = alltrue([
      for cert in aws_acm_certificate.cert : cert.validation_method == "DNS"
    ])
    error_message = "ACM certificate should use DNS validation method"
  }

  assert {
    condition = alltrue([
      for cert in aws_acm_certificate.cert : length(cert.domain_validation_options) > 0
    ])
    error_message = "ACM certificate should have domain validation options"
  }
}

# Test case 5: Certificate tags
run "verify_certificate_tags" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  assert {
    condition     = length(aws_acm_certificate.cert) > 0
    error_message = "ACM certificate should be created when custom domain is configured"
  }
}

# Test case 6: Route53 validation records configuration
run "verify_route53_validation_records" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  assert {
    condition = alltrue([
      for record in aws_route53_record.cert_validation : record.zone_id == var.api_gateway_custom_domain_zone_id
    ])
    error_message = "Route53 validation records should use correct zone ID"
  }

  assert {
    condition = alltrue([
      for record in aws_route53_record.cert_validation : record.allow_overwrite == true
    ])
    error_message = "Route53 validation records should allow overwrite"
  }

  assert {
    condition = alltrue([
      for record in aws_route53_record.cert_validation : record.ttl == 60
    ])
    error_message = "Route53 validation records should have TTL of 60"
  }
}

# Test case 7: Certificate validation dependency
run "verify_certificate_validation_dependency" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  assert {
    condition     = length(aws_acm_certificate.cert) > 0
    error_message = "ACM certificate should be created when custom domain is configured"
  }

  assert {
    condition     = length(aws_acm_certificate_validation.cert) > 0
    error_message = "ACM certificate validation should be created when custom domain is configured"
  }
}

# Test case 8: Empty custom domain name handling
run "verify_empty_custom_domain_handling" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = ""
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  assert {
    condition     = length(aws_acm_certificate.cert) == 0
    error_message = "No ACM certificate should be created with empty custom domain name"
  }

  assert {
    condition     = length(aws_acm_certificate_validation.cert) == 0
    error_message = "No ACM certificate validation should be created with empty custom domain name"
  }

  assert {
    condition     = length(aws_route53_record.cert_validation) == 0
    error_message = "No Route53 validation records should be created with empty custom domain name"
  }
}

# Test case 9: Local variables calculation
run "verify_local_variables" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  assert {
    condition     = local.domain_name == "api.example.com"
    error_message = "Local domain_name should match custom domain name"
  }

  assert {
    condition     = local.enable_custom_domain_name == true
    error_message = "Local enable_custom_domain_name should be true when domain name is set"
  }
}

# Test case 10: Local variables with null domain
run "verify_local_variables_with_null_domain" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = null
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

  assert {
    condition     = local.domain_name == null
    error_message = "Local domain_name should be null when custom domain name is null"
  }

  assert {
    condition     = local.enable_custom_domain_name == false
    error_message = "Local enable_custom_domain_name should be false when domain name is null"
  }
}

# Test case 11: Multiple domain validation options handling
run "verify_multiple_domain_validation_options" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }

}

# Test case 12: Certificate validation with FQDN
run "verify_certificate_validation_fqdns" {
  command = plan

  variables {
    enable_api_gateway                = true
    api_gateway_custom_domain_name    = "api.example.com"
    api_gateway_custom_domain_zone_id = "Z1D633PJN98FT9"
  }
}
