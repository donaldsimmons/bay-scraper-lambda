# Configs for the bay-scraper-lambda dependency layer and function
resource "aws_lambda_layer_version" "bsl_dependency_lambda_layer" {
  layer_name = "RequestsHTMLLayer"
  description = "Layer contianing requests-html python package and lambda-specific lxml package"
  compatible_runtimes = ["python3.8"]
  s3_bucket = aws_s3_bucket.bsl_source_bucket.id
  s3_key = aws_s3_object.bsl_depend_object.key
}

resource "aws_lambda_function" "bsl_lambda_function" {
  function_name = "BayScraperLambdaFunction"
  s3_bucket = aws_s3_bucket.bsl_source_bucket.id
  s3_key = aws_s3_object.bsl_script_object.key
  role = aws_iam_role.bsl_lambda_role.arn
  handler = "bay-scraper-lambda.lambda_handler"
  layers = [aws_lambda_layer_version.bsl_dependency_lambda_layer.arn]
  memory_size = 512
  timeout = 20
  runtime = "python3.8"
  depends_on = [aws_iam_role_policy_attachment.bsl_role_policy_attachment]
  environment {
    variables = {
      JOB_LOCATION = var.job_location
      JOB_TITLE = var.job_title
      SNS_ARN = aws_sns_topic.bsl_sns_topic.arn
      TARGET_URL = var.target_url
    }
  }
}

resource "aws_lambda_permission" "allow_schedule_to_trigger_bsl_function" {
  statement_id = "AllowExecutionFromCloudWatchEvent"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bsl_lambda_function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.bsl_scheduled_trigger_event_rule.arn
}
