import os
import sys
import json
import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timezone
from requests_html import AsyncHTMLSession

def lambda_handler(event, context):
  query_data = setup_query()
  results = scrape_data(query_data)
  publish_results(0, results, query_data["job_title"], query_data["location"]) 

# Set query options to be used when scraping
def setup_query():
  query_info = {
    "url": os.environ.get("TARGET_URL"),
    "licensed_app_type": "00000001",
    "support_app_type": "00000002",
    "location": os.environ.get("JOB_LOCATION"),
    "job_title": os.environ.get("JOB_TITLE")
  }
  return query_info

def scrape_data(query_opts):
  session = AsyncHTMLSession()

  param_opts_sets = set_params([query_opts["licensed_app_type"], query_opts["support_app_type"]])
  page_lambdas = [lambda opts=param_opts: page(session, query_opts["url"], opts) for param_opts in param_opts_sets]
  results = session.run(*page_lambdas)

  rows = [r.html.find("tr", containing=query_opts["location"]) for r in results]
  jobs = []
  for r in rows:
    for table_row in r:
      job_type = table_row.find(".rsbuttons + .rsbuttons + td")
      job_name = table_row.find("td", containing=query_opts["job_title"])
      if job_name:
        jobs.append({"job_type": job_type[0].text, "job_name": job_name[0].text})
  return jobs

def set_params(app_types):
  param_dicts = [{"APPLICANT_TYPE_ID": app_type, "COMPANY_ID": "00009961"} for app_type in app_types]
  return param_dicts

async def page(session, url, params):
  param_string = "&".join([key + "="+ value for key, value in params.items()])
  full_url = url + "?" + param_string

  try:
    result = await session.get(full_url)
  except Exception as e:
    error_msg = "An error occurred when connecting to the given URL:"
    current_utc = datetime.now(timezone.utc)
    response_msg = "{0}\n{1}\n{2}".format(current_utc, error_msg, e)
    error_result = {"error": e, "message": response_msg}
    publish_results(1, error_result)
    print(response_msg)
    sys.exit(1)
  return result

def publish_results(success_code, results, job_title, location):
  publish_date = datetime.today().strftime("%A, %m/%d/%Y")
  aws_region = "us-east-1"
  sns_topic_arn = os.environ.get("SNS_ARN")
  sns = boto3.client("sns", region_name=aws_region)

  if success_code == 0:
    count = len(results)
    sns_subject = f"Bay Scraper: {count} Results - {publish_date}"
    intro = f"There were {count} positions found for '{job_title}' at {location}."
    job_list = ""
    for r in results:
      job_list += "{0}: {1}\n".format(r["job_type"], r["job_name"])
    message = "{0}\n{1}".format(intro, job_list)
  else:
    sns_subject = f"Bay Scraper: Error - {publish_date}."
    message = "{0}\nThe script run was aborted, and no results were found.".format(e["message"])

  try:
    sns_msg_id = sns.publish(TopicArn=sns_topic_arn, Subject=sns_subject, Message=message)["MessageId"]
  except ClientError as e:
    print("An error occurred when publishing to SNS:\n{0}".format(e))
    sys.exit(1)

  if sns_msg_id:
    results_msg = "Message {0} was published to SNS:\n"+message
    print(results_msg.format(sns_msg_id))
