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

job_queue_url = '%s/api/job_queues/reserve' % url_base

job_queue_data = {
    'job_queue': { 'num_pages': 1 }
}

job_queue_r = requests.put(job_queue_url, data=json.dumps(job_queue_data), headers=headers)

if job_queue_r.status_code == requests.codes.ok:
    json_data = job_queue_r.json()
    requested = json_data.get('requested')
    reserved = json_data.get('reserved')
    proc_id = json_data.get('proc_id')
    results = json_data.get('results')
    print("Requested %s pages, and %s were reserved with proc_id: %s" % (requested, reserved, proc_id))
else:
    print("Error: Code %s" % job_queue_r.status_code)
    sys.exit(1)

if reserved < 1:
    print("Require at least one reserved page...exiting")
    sys.exit(1)

job_queue = results[0]
job_queue_id = job_queue.get('id')
page = job_queue.get('page')
batch = job_queue.get('batch_job')
page_id = page.get('id')
batch_id = batch.get('id')

batch_job_url = '%s/api/batch_jobs/upload_results' % url_base

batch_job_data = {
    'job_queues': {
        'completed': [
            job_queue_id,
        ],
        'failed': [],
    },
    'page_results': [
        {
            'page_id': page_id,
            'batch_id': batch_id,
            'ocr_text_path': '/dh/data/shared/some/path.txt',
            'ocr_xml_path': '/dh/data/shared/some/path.xml',
            'juxta_change_index': 0.0,
            'alt_change_index': 0.0,
        }
    ],
    'postproc_results': [
        {
            'page_id': page_id,
            'batch_job_id': batch_id,
            'pp_ecorr': 0.0,
            'pp_stats': 0.0,
            'pp_juxta': 0.0,
            'pp_retas': 0.0,
            'pp_health': 0.0,
        },
    ],
}

batch_job_r = requests.put(batch_job_url, data=json.dumps(batch_job_data), headers=headers)

if batch_job_r.status_code == requests.codes.ok:
    json_data = batch_job_r.json()
    page_results = json_data.get('page_results')
    postproc_results = json_data.get('postproc_results')
    print("Page results imported: %s" % page_results.get('imported'))
    print("Postproc results imported: %s" % postproc_results.get('imported'))
else:
    print("Error: Code %s" % batch_job_r.status_code)
    sys.exit(1)
