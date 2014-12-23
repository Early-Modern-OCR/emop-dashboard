# eMOP Dashboard

[![Build Status](https://travis-ci.org/idhmc-tamu/emop-dashboard.svg?branch=master)](https://travis-ci.org/idhmc-tamu/emop-dashboard)

[![Coverage Status](https://img.shields.io/coveralls/idhmc-tamu/emop-dashboard.svg)](https://coveralls.io/r/idhmc-tamu/emop-dashboard?branch=master)


This is the eMOP Dashboard application. It shows a table of OCR
results from a variety of OCR engines and helps track the overall
quality of the OCR.

It includes a Whenever job that will expire old juxta collations
periodically to prevent the JuxtaWS install from growing too large.

This job must be added to cron by executing:

    whenever -w

The job can be removed with:

    whenever -c

Note that on systems using RVM, jobs scheduled like this can hang. Here
is the problem and solution from the Whenever Gem README:

If your production environment uses RVM (Ruby Version Manager) you will run 
into a gotcha that causes your cron jobs to hang. This is not directly related 
to Whenever, and can be tricky to debug. Your .rvmrc files must be trusted or 
else the cron jobs will hang waiting for the file to be trusted. A solution is to 
disable the prompt by adding this line to your user rvm file in ~/.rvmrc

    rvm_trust_rvmrcs_flag=1

This tells rvm to trust all rvmrc files, which is documented here: 
http://wayneeseguin.beginrescueend.com/2010/08/22/ruby-environment-version-manager-rvm-1-0-0/

## Development

Running unit tests requires the database be created first.  See `.travis.yml` for examples.

Unit tests:

    bundle exec rake spec

Generating API doc examples from unit tests

    APIPIE_RECORD=examples bundle exec rake spec

Generate static API docs

    bundle exec rake apipie:static

## Legacy DB migration

This operation is time consuming and is intended to migrate away from using an external database.

These steps assumes all Rails migrations have been applied.

The steps below copy the data from the legacy database into the Rails database.

```
EMOP_DATABASE=emop_dev
EMOP_DASHBOARD_DATABASE=emop_dashboard

install -d -o mysql -g mysql /tmp/emop
cd /tmp/emop
mysqldump --tab=/tmp/emop --skip-extended-insert --compact ${EMOP_DATABASE} pages print_fonts fonts works
mkdir chunks
split -l 1000000 pages.txt chunks/pages_
for file in chunks/pages_* ; do  echo $file ; mysql ${EMOP_DASHBOARD_DATABASE} -e "LOAD DATA INFILE '/tmp/emop/$file' INTO TABLE pages"; done

tables=(
print_fonts
fonts
works
)

for table in "${tables[@]}"; do
  echo "Importing ${table}"
  mysqlimport --local ${EMOP_DASHBOARD_DATABASE} /tmp/emop/${table}.txt
done
```

Below is a method for comparing the database structure to ensure table columns match (position and name)

```
tables=(
pages
print_fonts
fonts
works
)

for table in "${tables[@]}"; do
  mysql ${EMOP_DATABASE} -e "SHOW FIELDS FROM ${table}" >> /tmp/${EMOP_DATABASE}_tables
  mysql ${EMOP_DASHBOARD_DATABASE} -e "SHOW FIELDS FROM ${table}" >> /tmp/${EMOP_DASHBOARD_DATABASE}_tables
done

diff -u /tmp/${EMOP_DATABASE}_tables /tmp/${EMOP_DASHBOARD_DATABASE}_tables
```
