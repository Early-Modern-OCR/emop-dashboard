json.array! @batch_jobs.collect { |batch_job| batch_job.to_builder('v2').attributes! }
