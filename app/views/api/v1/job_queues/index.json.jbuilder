json.array! @job_queues do |job_queue|
  json.id         job_queue.id
  json.tries      job_queue.tries
  json.results    job_queue.results
  json.batch_job  job_queue.batch_job
  json.page       job_queue.page
  json.status     job_queue.status, :id, :name
  json.work_id    job_queue.work_id
  json.proc_id    job_queue.proc_id
end
