json.page_results do
  json.imported @pg_imports.num_inserts
end
json.postproc_results do
  json.imported @pp_imports.num_inserts
end
json.font_training_results do
  json.imported @font_training_results_imports.num_inserts
end
