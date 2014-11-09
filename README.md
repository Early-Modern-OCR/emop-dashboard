# eMOP Dashboard

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

## Legacy DB migration

This operation is time consuming and is intended to migrate away from using an external database.

First step is to run "legacy" migrations against the external emop database.  This makes the schema 
match the Rail's DB schema so a 1:1 copy can be performed.

The following SQL commands may need to be executed to remove constraints that prevent the migration from working:

```
ALTER TABLE batch_job DROP FOREIGN KEY batch_job_ibfk_1
ALTER TABLE batch_job DROP FOREIGN KEY batch_job_ibfk_2
ALTER TABLE batch_job DROP FOREIGN KEY batch_job_ibfk_3
```

Then run the Rails migrations against the legacy database

```
RAILS_ENV=production bundle exec rake legacy:db:migrate
```

The next step assumes all Rails migrations have been applied.

This copies the data from the legacy database into the Rails database.

```

mysqldump --extended-insert=FALSE -t emop_dev pages | sed 's/emop_dev/emop_dashboard_dev/' | mysql -Demop_dashboard_dev

tables=(
print_fonts
batch_jobs
fonts
job_queues
page_results
postproc_pages
works
)

for table in "${tables[@]}"; do
  echo "Importing ${table}"
  mysql -e "INSERT INTO emop_dashboard_dev.${table} SELECT * FROM emop_dev.${table}"
done
```
