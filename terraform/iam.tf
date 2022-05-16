# IAM Role for executing bay-scraper-lambda Lambda function
resource "aws_iam_role" "bsl_lambda_role" {
  name = "BayScraperLambdaRole"
  description = "Allows invokation/execution of bay-scraper-lambda function and its output"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowAssumeLambdaRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "bsl_iam_policy" {
  name = "BayScraperLambdaExecPolicy"
  path = "/"
  description = "IAM Policy for managing BayScraperLambdaRole (bsl-lambda-role)"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement =  [
      {
        Sid = "AllowCloudWatchLogs"
        Effect = "Allow"
        Resource = "arn:aws:logs:us-east-1:*:log-group:*"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Sid = "AllowSNSMessaging"
        Effect = "Allow"
        Resource = "arn:aws:sns:us-east-1:*:*"
        Action = [
          "sns:Subscribe",
          "sns:ConfirmSubscription",
          "sns:CreateTopic",
          "sns:SetTopicAttributes",
          "sns:Publish"
        ]
      },
      {
        Sid = "AllowS3Access"
        Effect = "Allow"
        Resource = "arn:aws:s3:::bay-scraper-lambda-source/*"
        Action = [
          "s3:GetObject"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bsl_role_policy_attachment" {
  role = aws_iam_role.bsl_lambda_role.name
  policy_arn = aws_iam_policy.bsl_iam_policy.arn
}
