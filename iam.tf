data "aws_iam_policy_document" "lambda_application_assume_role_statement" {
  statement {
    sid = "LambdaApplicationAssumeRole"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

// data "aws_iam_policy_document" "lambda_application_execution_policy_statement" {
//   statement {
//     sid = "CloudWatchLogGroupPolicyStatement"

//     actions = [
//       "logs:CreateLogStream",
//       "logs:PutLogEvents"
//     ]

//     resources = [
//       aws_cloudwatch_log_group.lambda_application_log_group.arn
//     ]
//   }
// }


resource "aws_iam_role" "lambda_application_execution_role" {
  name = format("%s-Execution-Role", var.application_name)

  assume_role_policy = data.aws_iam_policy_document.lambda_application_assume_role_statement.json

  tags = merge(map("Name", format("%s-Execution-Role", var.application_name)), map("Lambda Application", var.application_name), var.tags)
}

// resource "aws_iam_policy" "lambda_application_cloudwatch_logs" {
//   name        = "${var.application_name}-lambda-cloudwtach-logs-policy"
//   path        = "/"
//   description = "IAM policy for logging ${var.application_name} functions to CloudWatch Log Groups"

//   policy = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
// }


resource "aws_iam_role_policy_attachment" "lambda_application_logs" {
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}