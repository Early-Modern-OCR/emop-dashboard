json.batch_job do
  json.id         @batch_job.id
  json.name       @batch_job.name
  json.parameters @batch_job.parameters
  json.notes      @batch_job.notes
  json.job_type   @batch_job.job_type
  json.ocr_engine @batch_job.ocr_engine
  json.font       @batch_job.font
end
