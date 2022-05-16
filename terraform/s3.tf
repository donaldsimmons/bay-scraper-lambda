# Configs for handling S3 resources for Lambda function files
resource "aws_s3_bucket" "bsl_source_bucket" {
  bucket = "bay-scraper-lambda-source"
}

resource "aws_s3_object" "bsl_script_object" {
  bucket = aws_s3_bucket.bsl_source_bucket.id
  key = var.script_object_name
  source = var.script_object_source
}

resource "aws_s3_object" "bsl_depend_object" {
  bucket = aws_s3_bucket.bsl_source_bucket.id
  key = var.dependency_object_name
  source = var.dependency_object_source
}
