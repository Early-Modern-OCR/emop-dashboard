json.pages do
  json.imported @imported
  json.failed @pages.failed_instances.count
end
