# Lambda Function Variables
variable "job_location" {
  type = string
  description = "Search phrase for job location"
}
variable "job_title" {
  type = string
  description = "Search phrase for job title"
}
variable "target_url" {
  type = string
  description = "URL for site to be scraped"
}

# S3 Variables
variable "script_object_name" {
  type = string
  description = "The name of the S3 object containing the zipped bay-scraper-lambda function"
}
variable "script_object_source" {
  type = string
  description = "The local file path for the zipped bay-scraper-lambda function"
}
variable "dependency_object_name" {
  type = string
  description = "The name of the S3 object containing the zipped dependencies for the bay-scraper-lambda function"
}
variable "dependency_object_source" {
  type = string
  description = "The local file path for the bay-scraper-lambda function's zipped dependency package"
}

# SNS Variables
variable "sns_target_email" {
  type = string
  description = "The email address set to receive updates from the bay-scraper-lambda SNS topic"
}
