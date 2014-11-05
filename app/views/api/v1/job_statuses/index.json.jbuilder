json.array! @job_statuses do |job_status|
  json.id   job_status.id
  json.name job_status.name
end
