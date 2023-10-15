resource "aws_iam_role" "lambda_authorizer_exec" {
  name = "serverless_authorizer_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  tags = {
    App = var.application_name,
    Environment = var.environment,
    OwnerTeam = var.owner_team
  }
}

resource "aws_lambda_function" "authorizer_demo" {
  function_name = "AuthorizerDemo"

  s3_bucket = aws_s3_bucket.lambda_authorizer_bucket.id
  s3_key    = aws_s3_object.lambda_authorizer_demo.key

  runtime = "nodejs18.x"
  handler = "lambda_authorizer.handler"
  memory_size = 128

  source_code_hash = data.archive_file.lambda_authorizer_demo_file.output_base64sha256

  role = aws_iam_role.lambda_authorizer_exec.arn

  environment {
    variables = {
      CLIENT_ID = var.cognito_client_id,
      TOKEN_USE = "access",
      COGNITO_ID = var.cognito_user_pool_id
    }
  }

  tags = {
    App = var.application_name,
    Environment = var.environment,
    OwnerTeam = var.owner_team
  }
}

resource "aws_cloudwatch_log_group" "authorizer_demo" {
  name = "/aws/lambda/${aws_lambda_function.authorizer_demo.function_name}"
  retention_in_days = 3

  tags = {
    App = var.application_name,
    Environment = var.environment,
    OwnerTeam = var.owner_team
  }
}

resource "aws_iam_role_policy_attachment" "lambda_authorizer_policy" {
  role       = aws_iam_role.lambda_authorizer_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function_url" "authorizer_url" {
  function_name      = aws_lambda_function.authorizer_demo.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}