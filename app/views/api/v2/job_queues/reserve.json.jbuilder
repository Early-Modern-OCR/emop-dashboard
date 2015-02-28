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
    json.page job_queue.page.to_builder('v2')
    json.work job_queue.work.to_builder('v2')
    json.page_result job_queue.page_result
    json.postproc_result job_queue.postproc_page
  end
end
