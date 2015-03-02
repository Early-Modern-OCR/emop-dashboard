json.array! @job_queues.collect { |job_queue| job_queue.to_builder('v2').attributes! }
#json.array! @job_queues do |job_queue|
#  json.id job_queue.id
#  json.proc_id job_queue.proc_id
#  json.tries job_queue.tries
#  json.results job_queue.results
#  json.status_id job_queue.job_status_id
#  json.batch_id job_queue.batch_id
#  json.page_id job_queue.page_id
#  json.work_id job_queue.work_id
#end
