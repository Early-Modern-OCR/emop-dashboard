#!/usr/bin/env python

import json
import os
import re
import ConfigParser
import logging
import requests
import sys
from urlparse import urljoin

config_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.ini')

Config = ConfigParser.ConfigParser()
Config.read(config_path)

api_version = Config.get('emop-dashboard', 'api_version')
url_base = Config.get('emop-dashboard', 'url_base')
auth_token = Config.get('emop-dashboard', 'auth_token')
log_level = Config.get('emop-dashboard', 'log_level')

api_headers = {
    'Accept': 'application/emop; version=%s' % api_version,
    'Authorization': 'Token token=%s' % auth_token,
}

logging.basicConfig(level=getattr(logging, log_level))
logging.getLogger("requests").setLevel(logging.WARNING)
logger = logging.getLogger(__name__)

def parse_results(job_queue_results):
    results = []
    for result in job_queue_results:
        m = re.search('^SLURM JOB [0-9]+:\s(.*)$', result)
        if m:
            results.append(m.group(1))
    return results


def get_request(url_path, params={}):
    global url_base, api_headers
    json_data = {}
    full_url = urljoin(url_base, url_path)
    logger.debug("Sending GET request to %s" % full_url)
    if params:
        logger.debug("GET request params: %s" % str(params))
    get_r = requests.get(full_url, params=params, headers=api_headers)

    if get_r.status_code == requests.codes.ok:
        json_data = get_r.json()
        # print json.dumps(json_data, sort_keys=True, indent=4)
    else:
        logger.error("GET %s failed with error code %s" % (full_url, get_r.status_code))
    return json_data


job_queues = []
job_queue_results = []
page_num = 1
data_returned = True

job_status_params = {
    "name": "Failed",
}
job_status_json_data = get_request('api/job_statuses', job_status_params)
job_status_results = job_status_json_data.get("results")[0]
job_status_id = job_status_results.get("id")

while data_returned:
    params = {
        "page_num": page_num,
        "per_page": 1000,
        "job_status_id": job_status_id,
    }
    json_data = get_request('api/job_queues', params)
    data = json_data.get("results")
    # logger.debug("Processing page %s of %s" % (page_num, json_data["total_pages"]))
    logger.debug("Processing page %s" % page_num)
    if not data:
        data_returned = False
    else:
        job_queues = job_queues + data
    page_num += 1
    # Uncomment to limit to first API query for testing
    # if page_num >= 1:
    #    break

logger.debug("API queries completed")

for job_queue in job_queues:
    job_queue_results.append(job_queue["results"])

results = parse_results(job_queue_results)
logger.debug("Parsing results completed")
uniq_results = set(results)
logger.debug("Getting unique results completed")

for result in uniq_results:
    count = results.count(result)
    print "%s: %s" % (result, count)

sys.exit(0)
