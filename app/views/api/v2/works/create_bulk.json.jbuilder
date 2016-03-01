json.works do
  json.imported @imported
  json.failed @works.failed_instances.count
end
