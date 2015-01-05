json.batch_job do
  json.id @batch_job.id
  json.name @batch_job.name
  json.parameters @batch_job.parameters
  json.notes @batch_job.notes
  json.job_type @batch_job.job_type.to_builder('v1')
  json.ocr_engine @batch_job.ocr_engine.to_builder('v1')
  json.font @batch_job.font.to_builder('v1')
  json.page_results do
    json.array! @batch_job.page_results.collect { |page_result| page_result.to_builder('v1').attributes! }
  end
end
