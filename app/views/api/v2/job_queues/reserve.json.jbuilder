json.requested @num_pages
json.reserved @job_queues.length
json.proc_id @proc_id
json.results do
  json.array! @job_queues do |job_queue|
    json.id job_queue.id
    json.proc_id job_queue.proc_id
    json.tries job_queue.tries
    json.results job_queue.results
    json.status job_queue.status.to_builder('v2')
    json.batch_job job_queue.batch_job.to_builder('v2')
    font_training_result = FontTrainingResult.find_by(batch_job_id: job_queue.batch_job.font_training_result_batch_job_id, work_id: job_queue.work.id)
    # If batch job has font use it, otherwise try to use font training results
    if job_queue.batch_job.font.present?
      json.font job_queue.batch_job.font.to_builder('v2')
    else
      if font_training_result.present?
        json.font do
          json.path font_training_result.font_path
        end
      else
        json.font font_training_result
      end
    end
    # If batch job has language model use it, otherwise try to use font training results
    if job_queue.batch_job.language_model.present?
      json.language_model job_queue.batch_job.language_model.to_builder('v2')
    else
      if font_training_result.present?
        json.language_model do
          json.path font_training_result.language_model_path
        end
      else
        json.language_model job_queue.batch_job.language_model
      end
    end
    # If batch job has gsm use it, otherwise try to use font training results
    if job_queue.batch_job.glyph_substitution_model.present?
      json.glyph_substitution_model job_queue.batch_job.glyph_substitution_model.to_builder('v2')
    else
      if font_training_result.present?
        json.glyph_substitution_model do
          json.path font_training_result.glyph_substitution_model_path
        end
      else
        json.glyph_substitution_model job_queue.batch_job.glyph_substitution_model
      end
    end
    json.page job_queue.page.to_builder('v2')
    json.work job_queue.work.to_builder('v2')
    json.page_result job_queue.page_result
    json.postproc_result job_queue.postproc_page
    if job_queue.font_training_result.present?
      json.font_training_result job_queue.font_training_result.to_builder('v2')
    else
      json.font_training_result job_queue.font_training_result
    end
  end
end
