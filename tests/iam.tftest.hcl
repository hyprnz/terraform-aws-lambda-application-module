provider "aws" {
  region = "us-west-2"
}

variables {
  application_name    = "test-lambda-app"
  application_runtime = "nodejs18.x"
  application_version = "1.0.0"
  artifact_bucket     = "test-artifact-bucket"
  artifact_bucket_key = "test-app.zip"

  lambda_functions_config = {
    api = {
      handler     = "api/index.handler"
      enable_vpc  = false
      description = "API handler function"
    }
    worker = {
      handler     = "worker/index.handler"
      enable_vpc  = false
      description = "Worker function"
    }
  }

  tags = {
    Environment = "test"
    Project     = "lambda-app"
  }
}

run "lambda_execution_role_creation" {
  command = plan

  assert {
    condition     = aws_iam_role.lambda_application_execution_role.name == "test-lambda-app-LA-ER"
    error_message = "Lambda execution role should have correct name"
  }

  assert {
    condition     = aws_iam_role.lambda_application_execution_role.assume_role_policy != null
    error_message = "Lambda execution role should have assume role policy"
  }
}

run "lambda_execution_role_assume_policy" {
  command = plan

  assert {
    condition = length([
      for statement in jsondecode(aws_iam_role.lambda_application_execution_role.assume_role_policy).Statement :
      statement if statement.Principal.Service == "lambda.amazonaws.com"
    ]) > 0
    error_message = "Lambda execution role should allow lambda service to assume the role"
  }
}

run "assume_role_policy_conditions" {
  command = plan

  assert {
    condition = contains([
      for statement in jsondecode(aws_iam_role.lambda_application_execution_role.assume_role_policy).Statement :
      statement.Effect
    ], "Allow")
    error_message = "Assume role policy should allow Lambda service to assume the role"
  }

  assert {
    condition = length([
      for statement in jsondecode(aws_iam_role.lambda_application_execution_role.assume_role_policy).Statement :
      statement if statement.Action == "sts:AssumeRole"
    ]) > 0
    error_message = "Assume role policy should include sts:AssumeRole action"
  }
}

run "default_lambda_execution_policy" {
  command = plan

  assert {
    condition     = length(aws_iam_role_policy.event_bridge_internal_entrypoint) > 0
    error_message = "Event bridge internal entrypoint policy should be created"
  }

  assert {
    condition     = aws_iam_role_policy.event_bridge_internal_entrypoint.name == "test-lambda-app-LA-EB"
    error_message = "Event bridge internal entrypoint policy should have correct name"
  }

  assert {
    condition     = length(aws_iam_role_policy.ssm_access_policy) > 0
    error_message = "SSM access policy should be created"
  }

  assert {
    condition     = aws_iam_role_policy.ssm_access_policy.name == "test-lambda-app-LA-SSM"
    error_message = "SSM access policy should have correct name"
  }

assert {
    condition     = length(aws_iam_role_policy_attachment.lambda_insights) > 0
    error_message = "Lambda insights policy should be created by default"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.lambda_application_logs) > 0
    error_message = "Lambda application logs policy should be created by default"
  }

  assert {
    condition     = length(aws_iam_role_policy.lambda_vpc) == 0
    error_message = "VPN access policy should not be created by default"
  }

  assert {
    condition     = length(aws_iam_role_policy.msk_cluster_access) == 0 && length(aws_iam_role_policy_attachment.msk_access_policy) == 0
    error_message = "MSK access policies should not be created by default"
  }

  assert {
    condition     = length(aws_iam_role_policy.custom_lambda_policy) == 0
    error_message = "Custom policy should not be created by default"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.datastore_s3_access_policy) == 0
    error_message = "Datastore S3 access policy should not be created by default"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.datastore_dynamodb_access_policy) == 0
    error_message = "Datastore DynamoDB access policy should not be created by default"
  }

  assert {
    condition = length(aws_iam_role_policy_attachment.xray_daemon) == 0
    error_message = "Lambda execution policy should not include X-Ray permission by default"
  }

  assert {
    condition = length(aws_iam_role_policy.ssm_kms_key) == 0
    error_message = "SSM KMS key policy should not be created by default"
  }

  assert {
    condition = length(aws_iam_role_policy.event_bus_access_policy) == 0
    error_message = "Event bus access policy should not be created by default"
  }

  assert {
    condition = length(aws_iam_role_policy.invoke_lambdas) == 0
    error_message = "API Gateway invoke lambdas policy should not be created by default"
  }
}

run "custom_policy_attachment" {
  variables {
    custom_policy_document = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:ListBucket"
          ]
          Resource = "arn:aws:s3:::custom-bucket"
        }
      ]
    })
  }

  command = plan

  assert {
    condition = length([
      for statement in jsondecode(aws_iam_role_policy.custom_lambda_policy[0].policy).Statement :
      statement if contains(statement.Action, "s3:ListBucket")
    ]) > 0
    error_message = "Custom policy statements should be included in execution policy when custom_policy_document is provided"
  }
}

run "vpc_permissions_when_vpc_enabled" {
  variables {
    lambda_functions_config = {
      api = {
        handler     = "api/index.handler"
        enable_vpc  = true
        description = "API handler function"
      }
    }
  }

  command = plan

  assert {
    condition     = length(aws_iam_role_policy.lambda_vpc) == 1
    error_message = "VPN access policy should be created when VPC is enabled"
  }
}

run "tracing_permissions_when_enabled" {
  variables {
    tracking_config = "Active"
  }

  command = plan

  assert {
    condition = length(aws_iam_role_policy_attachment.xray_daemon) > 0
    error_message = "Lambda execution policy should include X-Ray permissions when tracing is active"
  }
}

run "msk_permissions_when_msk_entrypoint_provided" {
  variables {
    msk_event_source_config = {
      "worker" = [{
        event_source_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/my-cluster/12345678-1234-1234-1234-123456789012"
        topic            = "my-topic"
      }]
    }
  }

  command = plan

  assert {
    condition     = length(aws_iam_role_policy.msk_cluster_access) > 0 &&length(aws_iam_role_policy_attachment.msk_access_policy) > 0
    error_message = "MSK access policy should be created when MSK event source is configured"
  }
}

run"s3_and_ddb_permission_when_datastore_are_provisioned" {
  variables {
    enable_datastore      = true
    create_s3_bucket      = true
    create_dynamodb_table = true

    dynamodb_hash_key  = "PK"
    dynamodb_range_key = "SK"
  }

  command = plan

  assert {
    condition     = length(aws_iam_role_policy_attachment.datastore_s3_access_policy) > 0
    error_message = "Datastore S3 access policy should be created when bucket is provisioned"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.datastore_dynamodb_access_policy) > 0
    error_message = "Datastore DynamoDB access policy should be created when DynamoDB table is provisioned"
  }
}


run "ssm_kms_key_policy_for_customer_provided_ssm_kms_key" {
  variables {
    ssm_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
  }

  command = plan

  assert {
    condition = length(aws_iam_role_policy.ssm_kms_key) == 1
    error_message = "SSM KMS key policy should be created when a customer-provided KMS key is used"
  }
}

run "invoke_lambda_policy_is_created_when_api_gateway_is_enabled" {
  variables {
    enable_api_gateway = true
  }

  command = plan

  assert {
    condition = length(aws_iam_role_policy.invoke_lambdas) == 1
    error_message = "Invoke Lambda policy should be created when API Gateway is enabled"
  }
}
