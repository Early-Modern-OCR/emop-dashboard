json.requested @num_pages
json.reserved @job_queues.length
json.proc_id @proc_id
json.results do
  json.array! @job_queues.collect { |job_queue| job_queue.to_builder('v1').attributes! }
end
