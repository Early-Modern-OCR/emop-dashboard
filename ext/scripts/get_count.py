#!/usr/bin/env python

import requests
import json
import ConfigParser
import sys
import os

config_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.ini')

Config = ConfigParser.ConfigParser()
Config.read(config_path)

api_version = Config.get('emop-dashboard', 'api_version')
url_base = Config.get('emop-dashboard', 'url_base')
auth_token = Config.get('emop-dashboard', 'auth_token')

headers = {
    'Accept': 'application/emop; version=%s' % api_version,
    'Authorization': 'Token token=%s' % auth_token,
}

job_status_params = {
    'name': 'Not Started',
}

job_status_url = '%s/api/job_statuses' % url_base
job_status_r = requests.get(job_status_url, params=job_status_params, headers=headers)

if job_status_r.status_code == requests.codes.ok:
    json_data = job_status_r.json()
    results = json_data.get('results')[0]
    job_status_id = results.get('id')
    print("Job Status ID: %s" % job_status_id)
else:
    print("Error: Code %s" % job_status_r.status_code)
    sys.exit(1)

job_queue_params = {
    'job_status_id': "%s" % job_status_id,
}
job_queue_url = '%s/api/job_queues/count' % url_base
job_queue_r = requests.get(job_queue_url, params=job_queue_params, headers=headers)

if job_queue_r.status_code == requests.codes.ok:
    json_data = job_queue_r.json()
    results = json_data.get('job_queue')
    count = results.get('count')
    print("Job Queue Count: %s" % count)
else:
    print("Error: Code %s" % job_queue_r.status_code)
    sys.exit(1)
