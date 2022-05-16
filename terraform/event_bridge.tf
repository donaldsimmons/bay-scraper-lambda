# Configs for EventBridge scheduled event trigger for bay-scraper-lambda
resource "aws_cloudwatch_event_rule" "bsl_scheduled_trigger_event_rule" {
  name = "BayScraperLambdaTriggerEventRule"
  description = "Triggers the bay-scraper-lambda script on a set schedule"
  schedule_expression = "cron(30 17 * * ? *)"
}

resource "aws_cloudwatch_event_target" "bsl_scheduled_event_target" {
  arn = aws_lambda_function.bsl_lambda_function.arn
  rule = aws_cloudwatch_event_rule.bsl_scheduled_trigger_event_rule.id
}
