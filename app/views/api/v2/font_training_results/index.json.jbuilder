json.array! @font_training_results do |font_training_result|
  json.id font_training_result.id
  json.path font_training_result.path
  json.work_id font_training_result.work_id
  json.batch_job_id font_training_result.batch_job_id
end
