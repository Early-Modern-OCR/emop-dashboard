#!/usr/bin/env python

import argparse
import csv
import requests
import json
import ConfigParser
import sys
import os
from sets import Set
from unidecode import unidecode

parser = argparse.ArgumentParser()
parser.add_argument('--page-csv', help='path to pages CSV', action='store', required=True)
parser.add_argument('--work-csv', help='path to works CSV', action='store', required=True)
args = parser.parse_args()

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

## Work Collection

works_collection = None
works_collection_url = '%s/api/works_collections' % url_base
works_collections_data = {
    'name': 'FirstBooks',
}

print("Querying for WorksCollection")
works_collection_get_r = requests.get(works_collection_url, params=works_collections_data, headers=headers)

if works_collection_get_r.status_code == requests.codes.ok:
    works_collection_data = works_collection_get_r.json()
    if works_collection_data["results"]:
        works_collection = works_collection_data["results"][0]
        print("WorksCollection found: %s" % json.dumps(works_collection))
    else:
        print("WorksCollection not found")
else:
    print("Error getting works collection: Code %s" % works_collection_get_r.status_code)
    print(works_collection_get_r.json())
    sys.exit(1)

if not works_collection:
    print("Creating WorksCollection")
    works_collection_post_r = requests.post("%s/api/works_collections" % url_base, data=json.dumps(works_collections_data), headers=headers)
    if works_collection_post_r.status_code == 201:
        works_collection_data = works_collection_post_r.json()
        works_collection = works_collection_data["works_collection"]
        print("WorksCollection created: %s" % json.dumps(works_collection))
    else:
        print("Error creating works collection: Code %s" % works_collection_post_r.status_code)
        print(works_collection_post_r.json())

## WORK - collect from CSV

language_ids = Set()
import_works = []
import codecs
with codecs.open(args.work_csv, 'rb', 'utf-8') as csvfile:
    csv_reader = csv.DictReader((line.encode('utf-8').strip() for line in csvfile), delimiter='|')
    for row in csv_reader:
        # Remove empty keys
        work = dict((k, v) for k, v in row.iteritems() if v)
        # Strip whitespace
        work = dict((k ,v.strip()) for k, v in work.iteritems())
        # Assign collection
        work['collection_id'] = works_collection['id']
        if work.get('language_id'):
            if isinstance(work['language_id'], unicode):
                _language_id = work['language_id']
                language_ids.add(work['language_id'])
            else:
                _language_id = unicode(work['language_id'], 'utf-8')
            work['language_id'] = _language_id
            language_ids.add(_language_id)
        import_works.append(work)

language_names = list(language_ids)
languages = {}
print "language names: %s" % language_names

language_get_r = requests.get("%s/api/languages" % url_base, headers=headers)
if language_get_r.status_code == requests.codes.ok:
    data = language_get_r.json()
    print "Language data %s" % data
    for r in data['results']:
        name = r['name']
        if isinstance(name, unicode):
            languages[name] = r['id']
        else:
            languages[name.decode("latin_1")]
        languages[r['name']] = r['id']
else:
    print("Error querying languages: code %s" % language_get_r.status_code)
    print(language_get_r.json())
    sys.exit(1)

for l in language_names:
    if l not in languages:
        language_data = {
            "name": l,
        }
        language_r = requests.post("%s/api/languages" % url_base, data=json.dumps(language_data), headers=headers)
        if language_r.status_code == 201:
            data = language_r.json()
            languages[data['language']['name']] = data['language']['id']
        else:
            print("Error failed to create language %s, code %s" % (l, language_r.status_code))
            print(language_r.json())
            sys.exit(1)

## Adjust language_id
#print "Languages: %s" % languages
for work in import_works:
    if work.get('language_id'):
        work['language_id'] = languages[work['language_id']]

## Work - Add via API

work_url = '%s/api/works/create_bulk' % url_base

work_data = {
    'works': import_works
}
print("Importing works")
work_r = requests.post(work_url, data=json.dumps(work_data), headers=headers)

if work_r.status_code == requests.codes.ok:
    work_data = work_r.json()
    print("Works created")
    print(json.dumps(work_data, indent=4, sort_keys=True))
else:
    print("Error: Code %s" % work_r.status_code)
    print(work_r.json())
    sys.exit(1)

print "Works Uploaded=%s Imported=%s Failed=%s UpdatedSuccess=%s UpdatedFailed=%s UpToDate=%s" % (
    len(import_works),
    work_data["works"]["imported"],
    work_data["works"]["failed"],
    work_data["works"]["updated_success"],
    work_data["works"]["updated_failed"],
    work_data["works"]["up_to_date"])

works = []
works_query = True
works_page_num = 1
works_per_page = 100
print("Querying works")

while works_query:
    works_query_data = {
        "page_num": works_page_num,
        "works_per_page": works_per_page,
    }
    works_get_r = requests.get('%s/api/works' % url_base, params=works_query_data, headers=headers)
    if works_get_r.status_code == requests.codes.ok:
        works_data = works_get_r.json()
        results = works_data["results"]
        if results:
            works = works + results
        else:
            works_query = False
    else:
        print("Error Failed to retrieve works: Code %s" % works_get_r.status_code)
        print works_get_r.json()
    works_page_num += 1

wks_book_ids = {}
wks_work_ids = []


for work in works:
    if work.get('id'):
        wks_work_ids.append(work['id'])

missing_works = Set()
space_pages = []
no_space_pages = []
skipped_pages = 0
import_pages = []
with open(args.page_csv, 'rb') as csvfile:
    csv_reader = csv.DictReader(csvfile, delimiter='|')
    for row in csv_reader:
        # Remove empty keys
        page = dict((k, v) for k, v in row.iteritems() if v)
        # Strip whitespace
        page = dict((k ,v.strip()) for k, v in page.iteritems())
        if not page.get('pg_work_id'):
            continue
        work_id = int(page['pg_work_id'])
        if work_id not in wks_work_ids:
            skipped_pages += 1
            missing_works.add(work_id)
            continue
        if ' ' in page['pg_image_path']:
            space_pages.append(page['pg_work_id'])
        else:
            no_space_pages.append(page['pg_work_id'])
        # Assign work
        page['pg_work_id'] = work_id
        import_pages.append(page)

#print "PAGES: with spaces: %s, without spaces: %s" % (len(space_pages), len(no_space_pages))
#print "Pages without spaces: %s" % list(set(no_space_pages))

missing_works = list(missing_works)
if missing_works:
    print("Missing Works:")
    print missing_works

page_url = '%s/api/pages/create_bulk' % url_base

page_data = {
    'pages': import_pages
}
print("Importing pages")
page_r = requests.post(page_url, data=json.dumps(page_data), headers=headers)

if page_r.status_code == requests.codes.ok:
    page_data = page_r.json()
    print("Pages created")
    print(json.dumps(page_data, indent=4, sort_keys=True))
else:
    print("Error: Code %s" % page_r.status_code)
    print page_r.json()
    sys.exit(1)

print "Pages Uploaded=%s Imported=%s Failed=%s Skipped=%s UpdatedSuccess=%s UpdatedFailed=%s UpToDate=%s" % (
    len(import_pages),
    page_data["pages"]["imported"],
    page_data["pages"]["failed"],
    skipped_pages,
    page_data["pages"]["updated_success"],
    page_data["pages"]["updated_failed"],
    page_data["pages"]["up_to_date"])
