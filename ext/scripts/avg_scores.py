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

def get_averages(postproc_pages):
    pp_ecorr_values = []
    pp_pg_quality_values = []

    for pp in postproc_pages:
        pp_ecorr = pp["pp_ecorr"]
        pp_pg_quality = pp["pp_pg_quality"]
        if pp_ecorr:
            pp_ecorr_values.append(pp_ecorr)
        if pp_pg_quality:
            pp_pg_quality_values.append(pp_pg_quality)

    pp_ecorr_count = len(pp_ecorr_values)
    pp_ecorr_avg = sum(pp_ecorr_values) / pp_ecorr_count
    pp_pg_quality_count = len(pp_pg_quality_values)
    pp_pg_quality_avg = sum(pp_pg_quality_values) / pp_pg_quality_count
    print "ecorr values: %s" % pp_ecorr_count
    print "ecorr average: %s" % pp_ecorr_avg
    print "pg_quality values: %s" % pp_pg_quality_count
    print "pg_quality average: %s" % pp_pg_quality_avg


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
    else:
        logger.error("GET %s failed with error code %s" % (full_url, get_r.status_code))
    return json_data

postproc_pages = []
page_num = 1
data_returned = True
while data_returned:
    params = {
        "page_num": page_num,
        "per_page": 1000,
    }
    json_data = get_request('api/postproc_pages', params)
    results = json_data.get("results")
    # logger.debug("Processing page %s of %s" % (page_num, json_data["total_pages"]))
    logger.debug("Processing page %s" % page_num)
    if not results:
        data_returned = False
    else:
        postproc_pages = postproc_pages + results
    page_num += 1
    # Uncomment to limit to first API query for testing
    # if page_num >= 1:
    #     break

get_averages(postproc_pages)

sys.exit(0)
