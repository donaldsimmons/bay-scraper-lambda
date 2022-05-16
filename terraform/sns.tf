# Configs for the SNS email notification for bay-scraper-lambda notifications
resource "aws_sns_topic" "bsl_sns_topic" {
  name = "BayScraperLambdaSNSTopic"
  display_name = "bay-scraper-lambda-results-email"
}

resource "aws_sns_topic_subscription" "bsl_email_target" {
  topic_arn = aws_sns_topic.bsl_sns_topic.arn
  protocol = "email"
  endpoint = var.sns_target_email
}
