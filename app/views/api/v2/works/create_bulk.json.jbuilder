json.works do
  json.imported @imported
  json.failed @works.failed_instances.count
  json.updated_success @updated_success
  json.updated_failed @updated_failed
  json.up_to_date @up_to_date
end
