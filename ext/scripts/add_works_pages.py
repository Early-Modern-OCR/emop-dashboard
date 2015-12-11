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
    'Content-Type': 'application/json',
    'Accept': 'application/emop; version=%s' % api_version,
    'Authorization': 'Token token=%s' % auth_token,
}

work_url = '%s/api/works' % url_base

work_data = {
    'work': {
        'wks_title': 'Test Book',
    }
}
work_r = requests.post(work_url, data=json.dumps(work_data), headers=headers)

if work_r.status_code == requests.codes.created:
    work_data = work_r.json()
    print("Work created")
    print(json.dumps(work_data, indent=4, sort_keys=True))
else:
    print("Error: Code %s" % work_r.status_code)
    sys.exit(1)

work_id = work_data['work']['id']

page_url = '%s/api/pages' % url_base
page_data = {
    'page': {
        'pg_ref_number': 1,
        'pg_ground_truth_file': '/dne/gt.txt',
        'pg_work_id': work_id,
        'pg_image_path': '/dne/image-1.tiff',
    }
}

page_r = requests.post(page_url, data=json.dumps(page_data), headers=headers)

if page_r.status_code == requests.codes.created:
    page_data = page_r.json()
    print("Page created")
    print(json.dumps(page_data, indent=4, sort_keys=True))
else:
    print("Error: Code %s" % page_r.status_code)
    sys.exit(1)
