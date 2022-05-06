# bay-scraper-lambda
### An AWS Lambda-compatible version of the bay-scraper script

An alternate version of the bay-scraper script found on [Github](https://github.com/donaldsimmons/scripts/). The original was formatted to be run either manually or via cron on a local machine. This version is instead designed to run using AWS Lambda, and is initally intended to be run as a scheduled event via CloudWatch.

As such, this version of the script won't be built to use various command line options and usability considerations. Instead, this script is designed to run using a set number of query terms and other options. While the script does use variable parameters, even in the Lambda version, this is not for portability, but for a small measure of obfuscation to prevent misuse of the script.

### Project

#### bay-scraper-lambda.py
The main script is located in the `bay-scraper-lambda.py` file. This is a relatively simple python file that contains all the code for searching a given URL for a set of given search parameters for `job_title` and `job_location`. An SNS `publish` trigger is fired once the script completes is run. If the script finishes successfully, an email is sent via SNS to deliver the results. If the script fails to scrape the requested page, an email containing the error message will be sent to via the same SNS topic, and will be distributed to the subscribed email addresses.

All script parameters are passed to the Lambda function through Lambda environment variables. These variables should use the following conventions:
- `TARGET_URL`: URL of the site to be scraped, without query strings or parameters
- `JOB_LOCATION`: Search term or phrase for parsing results with relevant job location
- `JOB_NAME`: Search term or phrase for parsing results with relevant job title
- `SNS_ARN`: Complete SNS Topic ARN that handles email dispatch

The Lambda IAM role should include permissions for writing CloudWatch logs, and permissions to publish SNS messages.

#### Dependencies
`bay-scraper-lambda.py` uses the `requests-html` python library to make asynchronous queries and parse returned data. The library has been slightly modified to contain an updated version of the `lxml` library that is a `requests-html` dependency. This updated version has been built on an AmazonLinux container to correctly simulate the runtime environment of AWS Lambda.

The `python` directory that is included contains the correct file structure for inclusion as a Lambda Layer. It includes `requests-html` library, and will need to be zipped before use with Lambda. Any other dependencies will need to be added to this directory as they are introduced.

### Use
1. Zip `python` and upload as a Lambda Layer
2. Zip `bay-scraper-lambda.py` and upload to Lambda function
3. Set environment variables for Lambda function
4. Create SNS Topic and subscribe desired email addresses
6. Create CloudWatch scheduled event for Lambda run
