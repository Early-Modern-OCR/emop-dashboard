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

def get_averages(page_results):
    juxta_change_index_values = []
    missing_values = 0

    for page_result in page_results:
        juxta_change_index = page_result["juxta_change_index"]
        if juxta_change_index:
            juxta_change_index_values.append(juxta_change_index)
        else:
            missing_values += 1

    juxta_change_index_count = len(juxta_change_index_values)
    if juxta_change_index_count > 0:
        juxta_change_index_avg = sum(juxta_change_index_values) / juxta_change_index_count
    else:
        juxta_change_index_avg = 0
    print "juxta_change_index values: %s" % juxta_change_index_count
    print "juxta_change_index average: %s" % juxta_change_index_avg
    print "juxta_change_index missing: %s" % missing_values


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

page_results = []
page_num = 1
data_returned = True
while data_returned:
    params = {
        "page_num": page_num,
        "per_page": 1000,
        "batch_id": 2,
    }
    json_data = get_request('api/page_results', params)
    results = json_data.get("results")
    # logger.debug("Processing page %s of %s" % (page_num, json_data["total_pages"]))
    logger.debug("Processing page %s" % page_num)
    if not results:
        data_returned = False
    else:
        page_results = page_results + results
    page_num += 1
    # Uncomment to limit to first API query for testing
    # if page_num >= 1:
    #    break

get_averages(page_results)

sys.exit(0)
