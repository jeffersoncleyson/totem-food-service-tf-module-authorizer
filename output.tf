# Output value definitions


############################################### Authorizer [S3|Lambda] Outputs

output "lambda_authorizer_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_authorizer_bucket.id
}

output "function_authorizer_name" {
  description = "Name of the Authorizer Lambda function."

  value = aws_lambda_function.authorizer_demo.function_name
}

output "function_authorizer_invoke_arn" {
  description = "Name of the Authorizer Lambda function."

  value = aws_lambda_function.authorizer_demo.invoke_arn
}


output "function_authorizer_url" {
  description = "URL of the Authorizer Lambda function."

  value = aws_lambda_function_url.authorizer_url.function_url
}


###############################################