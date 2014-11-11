json.page_results do
  json.imported @pg_imports.num_inserts
end
json.postproc_results do
  json.imported @pp_imports.num_inserts
end
