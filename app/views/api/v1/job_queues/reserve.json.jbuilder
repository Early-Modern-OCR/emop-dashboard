json.requested @num_pages
json.reserved @job_queues.length
json.proc_id @proc_id
json.results do
  json.array! @job_queues do |job_queue|
    json.id job_queue.id
    json.proc_id job_queue.proc_id
    json.tries job_queue.tries
    json.results job_queue.results
    json.status job_queue.status.to_builder('v1')
    json.batch_job job_queue.batch_job.to_builder('v1')
    json.page job_queue.page.to_builder('v1')
    json.work job_queue.work.to_builder('v1')
    if job_queue.page_result.present?
      json.page_result do
        json.id job_queue.page_result.id
        json.ocr_text_path job_queue.page_result.ocr_text_path
        json.ocr_xml_path job_queue.page_result.ocr_xml_path
        json.corr_ocr_text_path job_queue.page_result.corr_ocr_text_path
        json.corr_ocr_xml_path job_queue.page_result.corr_ocr_xml_path
        json.ocr_completed job_queue.page_result.ocr_completed
        json.juxta_change_index job_queue.page_result.juxta_change_index
        json.alt_change_index job_queue.page_result.alt_change_index
        json.page_id job_queue.page_result.page_id
        json.batch_id job_queue.page_result.batch_id
      end
    else
      json.page_result job_queue.page_result
    end
    if job_queue.postproc_page.present?
      json.postproc_result do
        json.id job_queue.postproc_page.id
        json.pp_noisemsr job_queue.postproc_page.pp_noisemsr
        json.pp_ecorr job_queue.postproc_page.pp_ecorr
        json.pp_juxta job_queue.postproc_page.pp_juxta
        json.pp_retas job_queue.postproc_page.pp_retas
        json.pp_health job_queue.postproc_page.pp_health
        json.pp_pg_quality job_queue.postproc_page.pp_pg_quality
        json.noisiness_idx job_queue.postproc_page.noisiness_idx
        json.multicol job_queue.postproc_page.multicol
        json.skew_idx job_queue.postproc_page.skew_idx
        json.page_id job_queue.postproc_page.page_id
        json.batch_job_id job_queue.postproc_page.batch_job_id
      end
    else
      json.postproc_result job_queue.postproc_page
    end
  end
end
