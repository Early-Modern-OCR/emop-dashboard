json.array! @job_queues.collect { |job_queue| job_queue.to_builder('v1').attributes! }
