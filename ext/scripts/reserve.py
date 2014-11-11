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

url = '%s/api/job_queues/reserve' % url_base
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/emop; version=%s' % api_version,
    'Authorization': 'Token token=%s' % auth_token,
}

data = {
    'job_queue': { 'num_pages': '3' }
}

job_queue_r = requests.put(url, data=json.dumps(data), headers=headers)

if job_queue_r.status_code == requests.codes.ok:
    json_data = job_queue_r.json()
    requested = json_data.get('requested')
    reserved = json_data.get('reserved')
    proc_id = json_data.get('proc_id')
    results = json_data.get('results')
    print("Requested %s pages, and %s were reserved with proc_id: %s" % (requested, reserved, proc_id))
    print("Payload:")
    print(str(results))
else:
    print("Error: Code %s" % job_queue_r.status_code)
    sys.exit(1)